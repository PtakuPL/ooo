# Plan naprawy logowania na stronie WWW (reddaxe.pl)

**Data**: 2026-03-09  
**Priorytet**: Krytyczny — logowanie na stronie nie działa  
**Dotyczy**: Wszystkie wewnętrzne wywołania API z PHP (16 endpointów)

---

## 1. Diagnoza — prawdziwa przyczyna

### Objawy
- Logowanie na `https://tibia.reddaxe.pl/reddaxe/account-login.php` nie działa
- Użytkownik widzi błąd "API unreachable" lub podobny

### Pierwotne podejrzenie (błędne)
`CLIENT_LOCKED=true` w `.env` blokuje logowanie ze strony WWW.

### Prawdziwa przyczyna: self-signed SSL + hostname mismatch w PHP curl

**Przepływ logowania na stronie:**
```
[Przeglądarka] → POST /reddaxe/account-login.php
    → PHP: reddaxe_issue_launch_token()
        → reddaxe_http_get_json('/apik/v1/update.php?channel=stable')
        → reddaxe_post_json('/apik/v1/launcher-token.php', ...)
    → PHP: reddaxe_post_json('/apik/v1/login.php', {freshInstall:true, ...})
    → PHP: reddaxe_post_json('/apik/v1/account-context.php', ...)
```

Każde z tych wywołań to **PHP → curl → HTTPS → ten sam serwer**.

**Problem w łańcuchu:**
1. `reddaxe_public_base_url()` generuje URL z `$_SERVER['HTTP_HOST']` → `https://tibia.reddaxe.pl`
2. `reddaxe_skip_tls_verify_for_url($url)` sprawdza czy host to `127.0.0.1`/`localhost`/`::1`
3. Host w URL to `tibia.reddaxe.pl` → **NIE matchuje** → `CURLOPT_SSL_VERIFYPEER = true`
4. Certyfikat SSL jest **self-signed** → PHP curl ODRZUCA połączenie
5. Wynik: `curl error: SSL certificate problem: self-signed certificate`

### Dowód (testy wykonane na serwerze)

```bash
# Z SSL verify ON (jak robi strona):
php -r '... CURLOPT_SSL_VERIFYPEER => true ...'
# Wynik: HTTP: 0, Error: SSL certificate problem: self-signed certificate

# Z SSL verify OFF:
php -r '... CURLOPT_SSL_VERIFYPEER => false ...'
# Wynik: HTTP: 200, Error: (puste) — DZIAŁA

# Bezpośredni curl z -k (skip SSL):
curl -sk -X POST https://tibia.reddaxe.pl/apik/v1/login.php -d '{"type":"login","email":"...","password":"...","freshInstall":true}'
# Wynik: 200 OK — pełna odpowiedź z sesją i postaciami
```

### Stan kodu — co JUŻ działa poprawnie
- `login.php` linia 200: `$sourceIsWeb` bypass istnieje
- `login.php` linia 202: `$freshInstall` bypass istnieje
- `account-login.php` linia 173: `'freshInstall' => true` — strona WYSYŁA ten parametr
- `account-login.php` linia 70-110: `reddaxe_issue_launch_token()` — próbuje pobrać launch token jako bonus
- Cała logika CLIENT_LOCKED jest **poprawna** i **nie blokuje** strony WWW

---

## 2. Skala problemu

### Dotknięte pliki (16 wywołań API z PHP)

| Plik | Endpoint | Funkcja |
|------|----------|---------|
| `reddaxe/account-login.php` | `/apik/v1/update.php` | GET manifest |
| `reddaxe/account-login.php` | `/apik/v1/launcher-token.php` | Pobranie tokenu |
| `reddaxe/account-login.php` | `/apik/v1/login.php` | Logowanie |
| `reddaxe/account-login.php` | `/apik/v1/account-context.php` | Kontekst sesji |
| `reddaxe/account-create.php` | `/apik/v1/...` | Rejestracja |
| `reddaxe/post-login.php` | `/apik/v1/account-context.php` | Post-login |
| `reddaxe/account-manage.php` | `/apik/v1/account-context.php` | Zarządzanie kontem |
| `reddaxe/account-manage.php` | `/apik/v1/change-password.php` | Zmiana hasła |
| `reddaxe/account-manage.php` | `/apik/v1/change-account-name.php` | Zmiana nazwy |
| `reddaxe/account-manage.php` | `/apik/v1/change-character-name.php` | Zmiana nazwy postaci |
| `reddaxe/reset-password.php` | `/apik/v1/request-password-reset.php` | Reset hasła |
| `reddaxe/reset-password.php` | `/apik/v1/reset-password.php` | Wykonanie resetu |
| `reddaxe/guilds.php` | `/apik/v1/global-guilds-assign-local-leader.php` | Gildie |
| `reddaxe/guild-found.php` | `/apik/v1/account-context.php` | Zakładanie gildii |

**WSZYSTKIE te endpointy failują** z tego samego powodu (self-signed SSL cert).

### Konfiguracja serwera

- **Nginx**: dwa server bloki — `127.local.conf` (tibia.reddaxe.pl) + `myaac.conf` (catch-all)
- **SSL cert**: self-signed, issuer=RedDaxe, CN=tibia.reddaxe.pl
- **SAN**: DNS:tibia.reddaxe.pl, DNS:tibia1.reddaxe.pl, DNS:localhost, IP:127.0.0.1
- **DNS**: `/etc/hosts` → `127.0.0.1 tibia.reddaxe.pl tibia1.reddaxe.pl`
- **HTTP 80**: redirect → HTTPS 443

---

## 3. Rozwiązania — analiza opcji

### Opcja A: Dodać `tibia.reddaxe.pl` do listy skip-TLS w `reddaxe_skip_tls_verify_for_url()`

**Opis**: Rozszerzyć listę hostów, dla których pomijamy weryfikację SSL.

```php
// bootstrap.php — reddaxe_skip_tls_verify_for_url()
$host = strtolower((string)($parts['host'] ?? ''));
return in_array($host, ['127.0.0.1', 'localhost', '::1', 'tibia.reddaxe.pl', 'tibia1.reddaxe.pl'], true);
```

| Kryterium | Ocena |
|-----------|-------|
| Złożoność | ⭐ (2 linijki, 1 plik) |
| Bezpieczeństwo | ⚠️ Zahardkodowane domeny, ale to loopback (127.0.0.1) |
| Skalowalność | ❌ Przy zmianie domeny trzeba pamiętać o aktualizacji |
| Czas naprawy | ~1 minuta |

**Werdykt**: Quick-fix, ale zbyt kruchy — hardkodowane domeny.

---

### Opcja B: Zmienić `reddaxe_public_base_url()` na `http://127.0.0.1` dla lokalnych wywołań

**Opis**: Wywołania PHP→PHP powinny iść przez loopback HTTP, nie przez publiczne HTTPS.

```php
// Nowa funkcja: reddaxe_internal_api_base_url()
function reddaxe_internal_api_base_url(): string
{
    return 'http://127.0.0.1';  // localhost, port 80, bez SSL
}
```

I użyć jej w `reddaxe_post_json()` / `reddaxe_http_get_json()` zamiast `reddaxe_public_base_url()`.

| Kryterium | Ocena |
|-----------|-------|
| Złożoność | ⭐⭐ (nowa funkcja + zmiana 2 istniejących) |
| Bezpieczeństwo | ✅ Loopback nie wychodzi z maszyny, nie potrzebuje SSL |
| Skalowalność | ✅ Działa niezależnie od domeny |
| Czas naprawy | ~15 minut |

**Problem**: HTTP port 80 w Nginx robi `return 301 https://...` → redirect! Trzeba by dodać osobny server block lub location dla localnej API.

**Werdykt**: Dobry pomysł, ale wymaga zmiany Nginx.

---

### Opcja C: Zainstalować self-signed cert jako zaufany w systemie (ca-certificates)

**Opis**: Dodać certyfikat do `/usr/local/share/ca-certificates/` i `update-ca-certificates`.

```bash
sudo cp /etc/nginx/ssl/server.crt /usr/local/share/ca-certificates/reddaxe-local.crt
sudo update-ca-certificates
```

| Kryterium | Ocena |
|-----------|-------|
| Złożoność | ⭐ (2 komendy) |
| Bezpieczeństwo | ✅ Cert jest zaufany systemowo, PHP curl go weryfikuje poprawnie |
| Skalowalność | ✅ Działa dla wszystkich domen w SAN certa |
| Czas naprawy | ~2 minuty |
| Portowalność | ⚠️ Trzeba powtórzyć po reinstalacji systemu |

**Werdykt**: Poprawne rozwiązanie na poziomie infrastruktury.

---

### Opcja D (REKOMENDOWANA): Opcja C + Opcja B jako fallback + konfigurowalny internal URL

**Opis**: Wielowarstwowe rozwiązanie:

1. **Warstwa 1 — Infrastruktura**: Zainstalować self-signed cert jako zaufany w OS (`update-ca-certificates`)
2. **Warstwa 2 — Konfiguracja**: Dodać `INTERNAL_API_BASE_URL` do `.env` (opcjonalny override, domyślnie pusty = użyj `reddaxe_public_base_url()`)
3. **Warstwa 3 — Kod**: Zmienić `reddaxe_skip_tls_verify_for_url()` aby matchowała **każdy** host rozwiązujący się na loopback (127.0.0.0/8, ::1)

```
Hierarchia rozwiązywania URL wewnętrznych wywołań:
  1. .env INTERNAL_API_BASE_URL (jeśli ustawiony)
  2. reddaxe_public_base_url() + SSL skip jeśli host → 127.0.0.0/8
  3. System trust store (zainstalowany cert)
```

| Kryterium | Ocena |
|-----------|-------|
| Złożoność | ⭐⭐⭐ (3 warstwy, ale każda prosta) |
| Bezpieczeństwo | ✅✅ Wielowarstwowe, bez naruszenia bezpieczeństwa |
| Skalowalność | ✅✅ Działa przy zmianie domeny, certyfikatu, konfiguracji |
| Portowalność | ✅ .env override działa wszędzie, cert trust jest bonusem |
| Czas naprawy | ~30 minut |

**Werdykt**: Najlepsze połączenie solidności i prostoty.

---

## 4. Implementacja — Opcja D (rekomendowana)

### Krok 1: Zainstalować self-signed cert jako zaufany (infrastruktura)

```bash
sudo cp /etc/nginx/ssl/server.crt /usr/local/share/ca-certificates/reddaxe-local.crt
sudo update-ca-certificates
# Restart PHP-FPM aby pobrał nowy trust store
sudo systemctl restart php8.2-fpm
```

**Weryfikacja**: `php -r 'echo file_get_contents("https://tibia.reddaxe.pl/apik/v1/update.php?channel=stable");'`

Jeśli zwróci JSON → certyfikat jest zaufany. Sam ten krok powinien naprawić login.

### Krok 2: Ulepszyć `reddaxe_skip_tls_verify_for_url()` (kod — zabezpieczenie)

Plik: `/var/www/html/reddaxe/bootstrap.php`

**Było**:
```php
function reddaxe_skip_tls_verify_for_url(string $url): bool
{
    $parts = parse_url($url);
    if (!is_array($parts)) return false;
    $scheme = strtolower((string)($parts['scheme'] ?? ''));
    if ($scheme !== 'https') return false;
    $host = strtolower((string)($parts['host'] ?? ''));
    return in_array($host, ['127.0.0.1', 'localhost', '::1'], true);
}
```

**Ma być**:
```php
function reddaxe_skip_tls_verify_for_url(string $url): bool
{
    $parts = parse_url($url);
    if (!is_array($parts)) return false;
    $scheme = strtolower((string)($parts['scheme'] ?? ''));
    if ($scheme !== 'https') return false;
    $host = strtolower((string)($parts['host'] ?? ''));

    // Jawna lista loopback
    if (in_array($host, ['127.0.0.1', 'localhost', '::1'], true)) {
        return true;
    }

    // Host rozwiązujący się na loopback (np. tibia.reddaxe.pl → 127.0.0.1 w /etc/hosts)
    $resolved = gethostbyname($host);
    if ($resolved !== $host && str_starts_with($resolved, '127.')) {
        return true;
    }

    return false;
}
```

**Dlaczego to bezpieczne**: `gethostbyname()` sprawdza lokalne DNS (`/etc/hosts`). Jeśli domena rozwiązuje się na `127.x.x.x`, to wywołanie i tak trafia na localhost — skipowanie SSL dla loopback nie obniża bezpieczeństwa.

### Krok 3 (opcjonalny): Dodać `INTERNAL_API_BASE_URL` do `.env`

Plik: `/var/www/html/apik/v1/.env`
```
# Opcjonalny: wewnętrzny URL API (pomija DNS/SSL dla PHP→PHP wywołań)
# INTERNAL_API_BASE_URL=http://127.0.0.1
```

Plik: `/var/www/html/reddaxe/bootstrap.php`
```php
function reddaxe_internal_api_base_url(): string
{
    static $cached = null;
    if ($cached !== null) return $cached;

    $env = reddaxe_env(__DIR__ . '/../apik/v1/.env');
    $override = trim((string)($env['INTERNAL_API_BASE_URL'] ?? ''));
    $cached = ($override !== '') ? $override : reddaxe_public_base_url();
    return $cached;
}
```

I zmienić `reddaxe_post_json()` / `reddaxe_http_get_json()` aby używały `reddaxe_internal_api_base_url()` zamiast `reddaxe_public_base_url()`.

**UWAGA**: Ten krok jest opcjonalny. Kroki 1+2 powinny wystarczyć. Krok 3 to dodatkowe zabezpieczenie na przyszłość.

---

## 5. Kolejność wdrażania

```
┌─ Krok 1 ─────────────────────────────────────┐
│ sudo cp cert → ca-certificates                │
│ sudo update-ca-certificates                   │
│ sudo systemctl restart php8.2-fpm             │
│                                               │
│ TEST: czy login na stronie działa             │
│ Jeśli TAK → gotowe (Krok 2 = bonus)          │
│ Jeśli NIE → kontynuuj                        │
└───────────────────────────────────────────────┘
              │
              ▼
┌─ Krok 2 ─────────────────────────────────────┐
│ Edytuj bootstrap.php:                         │
│   reddaxe_skip_tls_verify_for_url()           │
│   → dodaj gethostbyname() loopback check      │
│                                               │
│ TEST: czy login działa                        │
│ Powinno wystarczyć.                           │
└───────────────────────────────────────────────┘
              │
              ▼
┌─ Krok 3 (opcjonalny) ────────────────────────┐
│ INTERNAL_API_BASE_URL w .env                  │
│ reddaxe_internal_api_base_url() w bootstrap   │
│ Użyj w reddaxe_post_json / http_get_json     │
│                                               │
│ Tylko jeśli Krok 1+2 nie wystarczą            │
│ lub chcesz future-proof rozwiązanie           │
└───────────────────────────────────────────────┘
```

---

## 6. Wpływ na inne komponenty

| Komponent | Wpływ | Akcja potrzebna |
|-----------|-------|-----------------|
| Launcher (Rust) | ❌ Brak — łączy się z zewnątrz, ma własne cert handling | Brak |
| OTC Client | ❌ Brak — łączy przez `/api/v1/login` (MyAAC route), nie apik | Brak |
| MyAAC (CanaryAAC) | ❌ Brak — osobna ścieżka logowania | Brak |
| Rejestracja kont | ✅ Naprawi się automatycznie (ten sam `reddaxe_post_json`) | Brak |
| Reset hasła | ✅ Naprawi się automatycznie | Brak |
| Zarządzanie kontem | ✅ Naprawi się automatycznie | Brak |
| Gildie | ✅ Naprawi się automatycznie | Brak |

---

## 7. Bezpieczeństwo

### Co jest bezpieczne
- Skipowanie SSL dla loopback (127.0.0.0/8) — ruch nie wychodzi z maszyny
- `gethostbyname()` używa lokalnych `/etc/hosts` — nie jest podatne na DNS spoofing zewnętrznego
- `CLIENT_LOCKED=true` pozostaje aktywne — launcher/OTC nadal wymagają tokenu

### Co NIE jest zalecane
- ❌ Wyłączanie `CURLOPT_SSL_VERIFYPEER` globalnie
- ❌ Używanie `CURLOPT_SSL_VERIFYPEER => false` dla wszystkich hostów
- ❌ Wyłączanie CLIENT_LOCKED

### Uwaga na przyszłość
Gdy serwer przejdzie na prawdziwy certyfikat (Let's Encrypt / publiczny CA):
- Krok 1 stanie się zbędny (ale nie zaszkodzi)
- Krok 2 nadal będzie aktualny jako zabezpieczenie
- Krok 3 można wyłączyć (usunąć z .env)

---

## 8. Testy weryfikacyjne

Po wdrożeniu każdego kroku:

```bash
# Test 1: PHP curl z weryfikacją SSL
php -r '
$ch = curl_init("https://tibia.reddaxe.pl/apik/v1/login.php");
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_HTTPHEADER => ["Content-Type: application/json"],
    CURLOPT_POSTFIELDS => json_encode([
        "type" => "login",
        "email" => "ratetate807@gmail.com",
        "password" => "test123",
        "gameMode" => "all",
        "freshInstall" => true
    ]),
    CURLOPT_TIMEOUT => 10,
    CURLOPT_SSL_VERIFYPEER => true,
    CURLOPT_SSL_VERIFYHOST => 2,
]);
$res = curl_exec($ch);
$err = curl_error($ch);
$code = curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
curl_close($ch);
echo "HTTP: $code\nError: $err\nSession: " .
    (json_decode($res, true)["session"]["sessionkey"] ?? "BRAK") . "\n";
'

# Test 2: Pełny login na stronie (przeglądarka)
# Otwórz https://tibia.reddaxe.pl/reddaxe/account-login.php
# Wpisz email + hasło → powinno zalogować bez błędu

# Test 3: Launcher login (bez zmian — powinien nadal działać)
```

---

## 9. Aktualizacja diagnozy po kolejnym sprawdzeniu

Stan na `2026-03-09` po dodatkowej diagnostyce:

- aktualny objaw na stronie `RedDAXE` to juz nie `API unreachable`, tylko:
  - `HTTP 200`
  - `errorCode=3`
  - `errorMessage=Email or password is not correct.`
- to oznacza, ze transport `PHP -> apik/v1/login.php` dziala i endpoint odpowiada poprawnym JSON-em,
- w aktualnym kodzie `reddaxe/bootstrap.php` sa juz obecne oba elementy, ktore mialy naprawic warstwe transportowa:
  - `reddaxe_internal_api_base_url()`
  - `reddaxe_skip_tls_verify_for_url()` z obsluga hosta rozwiazywanego do `127.x.x.x`,
- konto z aktualnego flow logowania istnieje w `GLOBAL_DB.accounts`, wiec problem nie wyglada na `account_not_found`,
- launcher w aktualnym kodzie tez loguje sie przez `email + password` do tego samego `login.php`, wiec hipoteza o rozjezdzie `email` vs `account name` na warstwie klienta jest obecnie niepotwierdzona,
- obecny blocker wyglada na realne `wrong_credentials` albo rozjazd miedzy tym, czego uzywa launcher, a tym, czego oczekuje `RedDAXE`.

Wniosek:

- poprzednia diagnoza SSL byla potrzebna dla starego stanu, ale nie tlumaczy juz obecnego bledu z `errorCode=3`,
- Copilot nie powinien dalej skupiac sie na TLS / hostach dopoki objawem nie jest znowu `API unreachable`.

## 10. Zadanie dla Copilota — co ma zrobic teraz

### Cel

Ustalic, dlaczego `login.php` zwraca `LCH_WRONG_CREDENTIALS` dla strony `RedDAXE`, mimo ze konto istnieje i warstwa HTTP/HTTPS dziala.

### Zakres

Tylko diagnostyka i ewentualny fix logowania WWW. Bez ruszania globalnych gildii, launchera i bez przebudowy flow kont bez potwierdzenia.

### Konkretne kroki

1. Potwierdzic, z jakiego zrodla prawdy korzysta `RedDAXE`:
   - `reddaxe/account-login.php` loguje tylko przez `email`,
   - `apik/v1/login.php` sprawdza `GLOBAL_DB.accounts.password`,
   - launcher-rust tez wysyla `email + password` do `login.php`, wiec trzeba porownac realne payloady i wynik walidacji, a nie model identyfikatora.

2. Dodac tymczasowy, bezpieczny debug do `apik/v1/login.php` na srodowisku testowym:
   - logowac tylko:
     - `email`
     - czy konto zostalo znalezione
     - typ hasha (`sha1` / `password_hash` / `plain`)
     - czy porownanie hasla wyszlo `true/false`
     - `lchCode`
   - nie logowac plaintext hasla,
   - nie logowac pelnego hash-a hasla.

3. Sprawdzic spojnosc flow rejestracji i zmiany hasla:
   - `register-account-lib.php`
   - `change-password.php`
   - `reset-password.php`
   - potwierdzic, ze wszystkie zapisują haslo w formacie oczekiwanym przez `login.php`.

4. Zweryfikowac roznice miedzy payloadem launchera i payloadem strony:
   - `RedDAXE` lowercasuje email i wysyla haslo bez zmian,
   - launcher robi to samo,
   - jesli launcher sie loguje, a WWW nie, trzeba porownac:
     - czy w WWW nie wchodzi inne haslo z autofill / starego managera hasel,
     - czy nie ma roznicy w znaku specjalnym / layoutcie klawiatury,
     - czy request z WWW faktycznie niesie ten sam email i ten sam password length.

5. Dodac male ulepszenie diagnostyczne w `reddaxe/account-login.php`:
   - dla testowego srodowiska logowac technicznie `errorCode` do logu,
   - ale na UI nadal zostawiac przyjazny komunikat `i18n`.

### Kryterium zakonczenia

Copilot ma zakonczyc ten task dopiero wtedy, gdy bedzie wiadomo:

- czy problemem jest zle haslo,
- czy rozjazd launcher vs WWW,
- czy nieprawidlowy zapis hasha przy rejestracji / zmianie hasla,
- i bedzie wskazany konkretny plik do poprawy, a nie ogolna teoria o SSL.
