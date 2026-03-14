# Incydent: Konto 1021 (ratetate807@gmail.com) — nie można się zalogować

**Data**: 2026-03-09  
**Status**: ✅ NAPRAWIONE (2026-03-09 ~21:00)  
**Konto**: id=1021, name=ptaku123, email=ratetate807@gmail.com  
**Objaw**: Logowanie na RedDAXE WWW zwraca `errorCode=3` / `LCH_WRONG_CREDENTIALS`  
**Oczekiwane hasło**: `12345678Pt` (10 znaków)  
**Diagnoza prowadzona przez**: Copilot (debug login.php + audyt DB) + Codex (wskazanie ryzykownego momentu w planie gildii)

---

## 1. Dowody z debug logu (`/tmp/login_debug.log`)

| Czas | Źródło | Email | plainLen | passwordMatch |
|------|--------|-------|----------|---------------|
| 20:22:43 | curl (test) | ratetate807@gmail.com | 7 (test123) | ✅ true |
| 20:29:29 | przeglądarka RedDAXE | ratetate807@gmail.com | 10 (12345678Pt) | ❌ false |
| 20:35:09 | przeglądarka RedDAXE | cardriverkt@gmail.com | 10 (12345678Pt) | ✅ true |
| 20:39:04 | przeglądarka RedDAXE | ratetate807@gmail.com | 10 (12345678Pt) | ❌ false |
| 20:39:04 | przeglądarka RedDAXE | cardriverkt@gmail.com | 10 (12345678Pt) | ✅ true |

**Wniosek**: To samo hasło `12345678Pt` działa na nowym koncie (1022), nie działa na starym (1021).

---

## 2. Przyczyna: rozjazd hash w kolumnie `password`

### Stan baz danych

| Baza | Kolumna | Wartość | Odpowiada hasłu |
|------|---------|---------|-----------------|
| **global_accounts** (login.php czyta) | `password` | `7288edd0fc3f...` | `test123` ❌ |
| **global_accounts** | `engine_password_sha1` | `b374cb0ba109...` | `12345678Pt` ✅ |
| **canaryaac** (engine) | `password` | `7288edd0fc3f...` | `test123` ❌ |
| **canaryaac** (engine) | `engine_password_sha1` | `7288EDD0FC3F...` (UPPER) | `test123` ❌ |

### Kolumna `password` (której używa `login.php`) = `sha1("test123")`

```
sha1("test123")    = 7288edd0fc3ffcbe93a0cf06e3568e28521687bc  ← TO JEST W DB
sha1("12345678Pt") = b374cb0ba1094cc7f672a24d63f39b59f47e6de2  ← TO POWINNO BYĆ
```

`login.php` porównuje `sha1($plain)` z kolumną `password`.  
User wpisuje `12345678Pt` → `sha1("12345678Pt")` ≠ `sha1("test123")` → **FAIL**.

### Jak do tego doszło — rekonstrukcja

1. **2026-03-06 18:55:46**: Konto id=1021 stworzone (przez `register-account-lib.php` lub test API) z hasłem **"test123"**
   - `password` = `sha1("test123")` → `7288edd0...`
   - `engine_password_sha1` = `sha1("test123")` → `7288edd0...`
   - Obie bazy (canaryaac + global_accounts) otrzymały identyczne dane

2. **Między 2026-03-06 a 2026-03-09**: Prace nad globalnymi gildiami weszły w warstwę kont:
   - `plan-globalne-gildie-i-topki.md` (linia 39): mirror local accounts + GLOBAL_DB
   - `plan-globalne-gildie-i-topki.md` (linia 41): register-account-lib.php dotknięty
   - `plan-globalne-gildie-i-topki.md` (linia 129): register-account-lib.php **częściowo spięty**
   - `plan-globalne-gildie-i-topki-taski.md` (linia 211): WWW mirror = wdrożony
   - `plan-globalne-gildie-i-topki-taski.md` (linia 212): API/RedDAXE mirror = **nadal otwarty**

3. **W trakcie tych prac**: Kolumna `engine_password_sha1` w **global_accounts** została nadpisana na `sha1("12345678Pt")`, prawdopodobnie przez:
   - backfill/sync między bazami, który dotknął `engine_password_sha1` ale nie `password`
   - lub ręczną aktualizację SQL
   - lub zmianę hasła przez ścieżkę, która aktualizuje tylko `engine_password_sha1`
   
4. **Kolumna `password` NIE została zaktualizowana** — nadal zawiera `sha1("test123")` w obu bazach.

5. **canaryaac.engine_password_sha1** też nie została zaktualizowana — nadal `sha1("test123")` (uppercase), co oznacza, że sync/backfill dotknął TYLKO global_accounts.

---

## 3. Dlaczego nowe konto (1022) działa

Konto 1022 (cardriverkt@gmail.com) zostało stworzone **po** ustabilizowaniu systemu, z hasłem `12345678Pt`:
- `password` = `sha1("12345678Pt")` = `b374cb0ba109...` ✅
- `engine_password_sha1` = `sha1("12345678Pt")` = `b374cb0ba109...` ✅
- Obie kolumny spójne → login działa.

---

## 4. Naprawa — wykonana 2026-03-09

### A. ✅ Naprawione hasło konta 1021 (SQL)
```sql
-- global_accounts:
UPDATE accounts SET password = SHA1('12345678Pt') WHERE id = 1021;
-- canaryaac:
UPDATE accounts SET password = SHA1('12345678Pt'), engine_password_sha1 = SHA1('12345678Pt') WHERE id = 1021;
```
**Weryfikacja po naprawie**: curl + RedDAXE → login OK, sessionkey zwrócony.

### B. ✅ Audyt spójności haseł — wszystkie konta
Wykonano pełny audyt `global_accounts.accounts` — wynik:
- **Wszystkie konta (42)**: status `OK` lub `BRAK_ENG` (legacy konta 3,7 bez `engine_password_sha1` — nie wpływa na login)
- **0 kont z rozjazdem** po naprawie konta 1021

### C. Propozycja na przyszłość: fallback na `engine_password_sha1` w login.php
```php
// Jeśli password nie matchuje, sprawdź engine_password_sha1 jako fallback
if (!$ok && !empty($acc['engine_password_sha1'])) {
    $engineSha1 = (string)$acc['engine_password_sha1'];
    if (strlen($engineSha1) === 40 && ctype_xdigit($engineSha1)) {
        $ok = hash_equals(strtolower($engineSha1), strtolower(sha1($plain)));
        if ($ok) {
            // Auto-napraw: zsynchronizuj password z engine_password_sha1
            $fixStmt = $globalDb->prepare("UPDATE accounts SET password = ? WHERE id = ?");
            $fixStmt->execute([sha1($plain), (int)$acc['id']]);
        }
    }
}
```
**Status**: NIE wdrożone — audyt wykazał brak dalszych rozjazdów. Można wdrożyć jako zabezpieczenie na przyszłość.

---

## 5. Powiązanie z pracami nad globalnymi gildiami

Codex trafnie wskazał, że:
- moment ryzyka to wejście w warstwę kont globalnych (mirror local→GLOBAL_DB)
- `register-account-lib.php` jest **częściowo spięty** (linia 129 planu gildii)
- WWW mirror = wdrożony, API/RedDAXE mirror = **otwarty** (taski linia 211-212)
- brak formalnego wpisu postmortem/rollback w dokumentacji

To nie jest bug w bieżącym kodzie logowania — `login.php` działa poprawnie. Problem to **dane** — hash w kolumnie `password` pochodzi ze starego hasła testowego "test123" i nigdy nie został zaktualizowany do aktualnego hasła "12345678Pt".

---

## 6. Wniosek Codexa — granica odpowiedzialności

Codex potwierdził diagnozę Copilota i wyciągnął wniosek procesowy:

> *Przy taskach gildii weszliśmy za blisko warstwy kont. Dalej będę trzymał twardą granicę: bez Twojej zgody nie dotykam loginu, rejestracji, sesji ani mirroru kont.*

Ustalenia:
- Diagnoza Copilota (debug login.php, audyt DB, porównanie hash) + diagnoza Codexa (wskazanie momentu ryzyka w planie gildii) wspólnie doprowadziły do pełnej identyfikacji problemu
- Konto nie było zablokowane — miało niespójny rekord danych (stare hasło testowe `test123` w kolumnie `password`)
- **Lepiej jest się zapytać niż zrobić potencjalnie destrukcyjną zmianę** w warstwie kont/sesji/logowania

---

## 7. Zasady na przyszłość

1. **Taski gildii nie powinny dotykać warstwy kont** bez osobnego review/approvalu
2. **Każdy backfill/sync MUSI aktualizować obie kolumny** (`password` + `engine_password_sha1`) lub żadnej
3. **Zmiana hasła** przez dowolną ścieżkę musi być atomowa — aktualizacja WSZYSTKICH baz i WSZYSTKICH kolumn hasła
4. **Po migracji danych** → automatyczny audit spójności haseł (query z sekcji 4.B)
5. **Konta testowe** powinny mieć znane, udokumentowane hasła (nie "test123" na produkcji)
6. **Copilot i Codex** przed zmianą w warstwie logowania/rejestracji/sesji MUSZĄ pytać o zgodę — nie robić zmian samodzielnie

---

## 8. Dlaczego czasem nie można się zalogować — podsumowanie dla przyszłej diagnostyki

Jeśli ktoś nie może się zalogować a konto istnieje, sprawdź **w tej kolejności**:

1. **Czy hasło się zgadza?**
   ```bash
   cat /tmp/login_debug.log   # plainLen, passwordMatch
   ```
2. **Czy `password` i `engine_password_sha1` są spójne?**
   ```sql
   SELECT id, email, LOWER(password) = LOWER(engine_password_sha1) as ok
   FROM global_accounts.accounts WHERE email = '...';
   ```
3. **Czy konto jest w `global_accounts` czy tylko w `canaryaac`?**
   - `login.php` czyta z `global_accounts.accounts`
   - MyAAC login czyta z `canaryaac.accounts`
4. **Czy rate limiting nie zablokował prób?** (10/min per email, 30/min per IP)
5. **Czy `CLIENT_LOCKED=true` wymaga `launchToken` lub `freshInstall=true`?**
   - RedDAXE WWW wysyła `freshInstall: true` → bypass
   - Launcher wysyła `launchToken` → standard flow
   - Bezpośredni curl bez obu → zablokowany jeśli CLIENT_LOCKED=true
