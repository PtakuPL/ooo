# Raport diagnostyczny: logowanie WWW RedDAXE — errorCode=3

**Data**: 2026-03-09  
**Kontekst**: Kontynuacja planu `2026-03-09_website_login_fix_plan.md`

---

## 1. Wyniki analizy kodu

### Spójność hashowania haseł — OK

| Plik | Format zapisu | Kolumna `password` | Kolumna `engine_password_sha1` |
|------|--------------|-------------------|-------------------------------|
| `register-account-lib.php` | `sha1($password)` | ✅ SHA1 hex 40 znaków | ✅ SHA1 hex 40 znaków |
| `change-password.php` | `sha1($newPassword)` | ✅ SHA1 hex 40 znaków | ❌ NIE AKTUALIZUJE |
| `reset-password.php` | `sha1($newPass)` | ✅ SHA1 hex 40 znaków | ✅ SHA1 hex 40 znaków |

**Uwaga**: `change-password.php` nie aktualizuje `engine_password_sha1` — to drobna niespójność, ale nie wpływa na logowanie (login.php czyta tylko `password`).

### Walidacja w login.php — OK

```
1. SHA1 (40-char hex) → hash_equals(strtolower($stored), strtolower(sha1($plain)))
2. bcrypt/argon2       → password_verify($plain, $stored)
3. plaintext fallback  → hash_equals($stored, $plain)
```

### Email handling — OK

| Warstwa | Lowercasing | Co wysyła |
|---------|-------------|-----------|
| `register-account-lib.php` | `strtolower(trim($email))` | Zapisuje lowercase do DB |
| `account-login.php` (RedDAXE WWW) | `strtolower(trim($_POST['email']))` | Wysyła lowercase do login.php |
| `login.php` (API) | `trim($email)` — bez strtolower | Ale email z WWW już jest lowercase |
| Launcher (Rust) | Wysyła email as-is (user input) | Potencjalnie case-sensitive |

### Payload RedDAXE WWW vs Launcher

| Pole | RedDAXE WWW | Launcher |
|------|------------|---------|
| `type` | `"login"` | `"login"` |
| `email` | email z formularza (lowercase) | email z user input |
| `password` | password z formularza | password z user input |
| `gameMode` | `"all"` | zależne od wybranego trybu |
| `freshInstall` | `true` | brak (launcher nie wysyła) |
| `launchToken` | opcjonalny (z reddaxe_issue_launch_token) | wymagany (z launcher-token.php) |

---

## 2. Weryfikacja na żywym serwerze

### Test bezpośredni curl — DZIAŁA

```bash
curl -s -X POST https://tibia.reddaxe.pl/apik/v1/login.php \
  -H 'Content-Type: application/json' \
  -d '{"type":"login","email":"ratetate807@gmail.com","password":"test123",...}'
# Wynik: HTTP 200, pełna sesja z postaciami
```

### Test PHP curl (symulacja reddaxe_post_json) — DZIAŁA

```php
# gethostbyname('tibia.reddaxe.pl') → '127.0.0.1' → skipTls = true
# curl → HTTP 200 → Session key OK
```

### Test SSL bez skip — DZIAŁA

```bash
curl -s (bez -k) → HTTP 200 → Certyfikat zaufany systemowo
```

### Stan konta w DB

```
id=1021, name=ptaku123, email=ratetate807@gmail.com
password=7288edd0fc3ffcbe93a0cf06e3568e28521687bc (= sha1('test123'))
hash_type=SHA1 ✅
```

---

## 3. Wnioski

### Co już działa poprawnie:
- Warstwa SSL/TLS — certyfikat zainstalowany w trust store OS
- `reddaxe_skip_tls_verify_for_url()` — ma gethostbyname() fallback (live)
- `reddaxe_internal_api_base_url()` — istnieje w live bootstrap.php
- `freshInstall => true` — bypass CLIENT_LOCKED (live login.php + live account-login.php)
- Hashowanie haseł — spójne SHA1 wszędzie
- Endpoint login.php — poprawnie waliduje SHA1/bcrypt/argon2/plain

### Co wymaga weryfikacji z przeglądarki:

**Nie udało się odtworzyć `errorCode=3` z linii poleceń.** Logowanie działa poprawnie z curl, PHP CLI i bezpośrednio. Podejrzenia:

1. **Autofill / stare hasło** — przeglądarka może wstawiać cached hasło, które NIE jest aktualne
2. **Znaki specjalne / layout klawiatury** — jeśli hasło zawiera znaki spoza ASCII, encoding może się różnić
3. **Inny email / inne konto** — test mógł być robiony na innym koncie niż `ratetate807@gmail.com`
4. **Rate limiting** — po wielu nieudanych próbach konto mogło być tymczasowo zablokowane (10/min per email)

---

## 4. Dodane debug logging

### `/var/www/html/apik/v1/login.php`:
Dodano bezpieczne logowanie do `/tmp/login_debug.log`:
- `email` — jaki email przyszedł
- `accountFound` — czy konto znaleziono (true/false)
- `hashType` — typ hasha (`sha1`/`bcrypt`/`argon2`/`plain`)
- `storedHashPrefix` — pierwsze 8 znaków hasha
- `storedHashLen` / `plainLen` — długości (nie wartości)
- `passwordMatch` — true/false
- `hasFreshInstall` / `hasLaunchToken` / `hasSource` — co przyszło w requescie
- `userAgent` — aby odróżnić przeglądarkę od launchera
- NIE loguje plaintext hasła ani pełnego hasha

### `/var/www/html/reddaxe/account-login.php`:
Dodano logowanie payloadu i odpowiedzi API:
- `payloadSent` — z zamaskowanym hasłem `***(N chars)`
- `httpCode` / `apiOk` / `errorCode` / `errorMessage` / `lchCode`
- `hasSessionKey` — czy sesja została zwrócona
- `launchTokenOk` / `launchTokenError` — status tokenu

**Log**: `/tmp/login_debug.log`  
**Podgląd**: `cat /tmp/login_debug.log | python3 -m json.tool`

---

## 5. Następny krok

**Proszę zalogować się przez przeglądarkę** na `https://tibia.reddaxe.pl/reddaxe/account-login.php` i przesłać wynik:

```bash
cat /tmp/login_debug.log
```

Log pokaże:
- Czy email się zgadza z tym co w DB
- Czy konto zostało znalezione
- Czy hash pasuje
- Czy problem jest w launchToken / freshInstall
- Jak długie hasło zostało wysłane (wykluczenie autofill z innym hasłem)

Po zebraniu logów z przeglądarki będziemy mogli jednoznacznie wskazać przyczynę.
