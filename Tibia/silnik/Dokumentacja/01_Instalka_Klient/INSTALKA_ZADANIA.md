# Instalka — Pozostałe Zadania

> **Data:** 2026-03-07  
> **Zakres:** Tylko instalka (OTClient C++, Lua, PHP API, build workflow). BEZ launchera Rust.  
> **Weryfikacja:** Każdy punkt sprawdzony w kodzie — fałszywe alarmy usunięte.

---

## FAZA Q: PHP API — Hardening

### Q-01: verify-email.php — brak transakcji DB ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/verify-email.php` linie 58-63  
**Problem:** `UPDATE accounts SET email_verified = 1` i `DELETE FROM email_verification_tokens` to dwie osobne operacje. Jeśli DELETE się nie powiedzie (timeout, crash), token zostaje w DB i jest reużywalny.  
**Fix:** Wrap w `$db->beginTransaction()` / `$db->commit()` z rollback na wyjątek.  
**Podzadania:**
- [x] Q-01a: Dodaj transakcję opakowującą UPDATE + DELETE
- [x] Q-01b: Dodaj try/catch z rollback + log błędu

---

### Q-02: launcher-token.php — brak walidacji `channel` ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/launcher-token.php` linia 131  
**Problem:** `$requestChannel = trim((string)$req['channel'])` — akceptuje dowolny string. Trafia do SQL query WHERE channel = ?, więc brak SQL injection, ale logicznie powinien być whitelist.  
**Fix:** Whitelist: `['stable', 'beta', 'dev']`. Odmów z 400 jeśli nieznany.  
**Podzadania:**
- [x] Q-02a: Dodaj walidację channel po lini 131 (whitelist)

---

### Q-03: games-manage.php — brak try/catch na dynamic UPDATE ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/games-manage.php` linia ~254  
**Problem:** `$db->prepare($sql)->execute($params)` — jeśli DB rzuci wyjątek (np. duplicate slug, constraint violation), odpowiedź to generic 500 zamiast informatywnego błędu.  
**Fix:** try/catch z logowaniem PDOException i zwróceniem czytelnego komunikatu.  
**Podzadania:**
- [x] Q-03a: Wrap handleUpdate() SQL w try/catch
- [x] Q-03b: Wrap handleCreate() SQL w try/catch (ten sam wzorzec)
- [x] Q-03c: Zwróć sensowny komunikat przy duplicate slug / constraint (kod SQLSTATE 23xxx → 409)

---

### Q-04: pwcheck.php — debug endpoint bez zabezpieczeń ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/pwcheck.php`  
**Problem:** Endpoint diagnostyczny — zwraca `password_get_info()` (algorytm hashowania), ID konta, i weryfikuje hasła. Zero autoryzacji, zero rate-limit. Na produkcji to wektor brute-force.  
**Fix:** Albo usunąć, albo: (1) tylko DEV_MODE, (2) wymagać admin key, (3) rate-limit.  
**Podzadania:**
- [x] Q-04a: Dodaj blokadę `if DEV_MODE !== 'true' → 404`
- [x] Q-04b: Dodaj rate-limit (5/min per IP, plik w /tmp)
- [x] Q-04c: Usuń zwracanie info o algorytmie hasza (`$out['algo']`) + usunięto `$out['id']`

---

## FAZA R: Build Workflow — Poprawki

### R-01: build-client-package.yml — operator precedence w find ✅ DONE 2026-03-07
**Plik:** `canary_test/testyy/.github/workflows/build-client-package.yml`  
**Problem:** Operator precedence w find bez nawiasów.  
**Fix:** Dodano `\( ... \)` + zmieniono na `-delete`.  
**Podzadania:**
- [x] R-01a: Popraw find w strip step (Windows) — `\( ... \) -delete`
- [x] R-01b: Popraw find w verify step (Windows) — `\( ... \)` (tylko wc, bez delete)

---

### R-02: build-client-package.yml — brak weryfikacji sed ✅ DONE 2026-03-07
**Plik:** `canary_test/testyy/.github/workflows/build-client-package.yml`  
**Problem:** sed milcząco nie zmienia niczego jeśli wzorzec nie pasuje.  
**Fix:** Dodano check po sed: `grep -q "CLIENT_LOCKED = true" || echo WARNING`.  
**Podzadania:**
- [x] R-02a: Dodaj check po sed z WARNING jeśli nie zadziałał

---

### R-03: build-client-package.yml — brak SHA256 sumy paczki ✅ ALREADY EXISTS
**Plik:** `canary_test/testyy/.github/workflows/build-client-package.yml`  
**Status:** Sign job (linia ~570) JUŻ generuje SHA256 checksums dla wszystkich artefaktów.  
**Podzadania:**
- [x] R-03a: ~~Dodaj step generujący SHA256~~ — już istnieje w sign job

---

## FAZA S: Synchronizacja 3 kopii Lua

### S-01: Inwentaryzacja różnic między kopiami ✅ DONE 2026-03-07
**Kopie:**
1. `canary_test/testyy/modules/` — aktywny development (ŹRÓDŁO PRAWDY)
2. `client_pack/1.1.0/modules/` — paczka klienta
3. `launcher_test/test_client/modules/` — test suite

**Wyniki diff:**  
- `entergame.lua`: testyy vs client_pack — 287 linii diff (brak launcher/auto-login w kopii)
- `entergame.lua`: testyy vs launcher_test — 249 linii diff
- `serverlist.lua`: testyy vs client_pack — 6 linii diff (tylko komentarz INS-66)
- `characterlist.lua`: testyy vs client_pack — 45 linii diff
- `characterlist.lua`: testyy vs launcher_test — 45 linii diff

**Podzadania:**
- [x] S-01a: Porównaj diff trzech kopii
- [x] S-01b: Zsynchronizuj pliki (skopiowano z testyy → client_pack + launcher_test)
- [ ] S-01c: Rozważ symlinki lub skrypt sync (TODO na przyszłość — niski priorytet)

---

## FAZA T: PHP Diagnostyka — DEV_MODE Guard (audyt 2026-03-07) ✅ DONE

> **Problem:** 4 endpointy diagnostyczne dostępne publicznie bez żadnych zabezpieczeń.

### T-01: peek_env.php — DEV_MODE guard ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/peek_env.php`  
**Problem:** Ujawnia zmienne .env (host, port, DB name, długość hasła DB). Zero auth.  
**Fix:** DEV_MODE guard → 404 na produkcji.  
- [x] T-01a: Dodaj DEV_MODE guard

### T-02: diag_players.php — DEV_MODE guard + rate-limit ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/diag_players.php`  
**Problem:** Wykonuje SELECT na kontach/graczach po GET parameter `?login=`. Zero auth, zero rate-limit.  
**Fix:** DEV_MODE guard + rate-limit 5/min/IP.  
- [x] T-02a: Dodaj DEV_MODE guard
- [x] T-02b: Dodaj rate-limit 5/min/IP

### T-03: echo.php — DEV_MODE guard ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/echo.php`  
**Problem:** Zwraca surowe dane POST/input. Zero auth.  
**Fix:** DEV_MODE guard → 404 na produkcji.  
- [x] T-03a: Dodaj DEV_MODE guard

### T-04: auth_probe.php — DEV_MODE guard + rate-limit ✅ DONE 2026-03-07
**Plik:** `canary_test/html_copy/apik/v1/auth_probe.php`  
**Problem:** Weryfikuje hasła na dwóch bazach (AAC + engine), zwraca account ID/name. Zero auth, zero rate-limit.  
**Fix:** DEV_MODE guard + rate-limit 5/min/IP.  
- [x] T-04a: Dodaj DEV_MODE guard
- [x] T-04b: Dodaj rate-limit 5/min/IP

---

## Podsumowanie

| Faza | Zadań | Podzadań | Priorytet |
|------|-------|----------|-----------|
| **Q** (PHP API) | 4/4 ✅ | 9/9 ✅ | DONE |
| **R** (Build) | 3/3 ✅ | 3/3 ✅ | DONE |
| **S** (Sync Lua) | 1/1 ✅ | 2/3 ✅ | DONE (S-01c niski priorytet) |
| **T** (PHP Diagnostyka) | 4/4 ✅ | 6/6 ✅ | DONE |
| **RAZEM** | **12/12** | **20/21** | ✅ |

### Odrzucone fałszywe alarmy:
| Zgłoszenie | Powód odrzucenia |
|------------|-----------------|
| characterlist.lua brak nil check | Linia 23: `if not isWorldAllowedForMode then` — JUŻ sprawdza |
| serverlist.lua brak table check | Linia 22: `if mode.server and mode.server.host then` — JUŻ sprawdza |
| change-character-name.php brak max length | Linia 47: `strlen($newName) > 29` — JUŻ waliduje |
| entergame.lua case-sensitive errors | Linia 27: `msg = tostring(message or ""):lower()` — JUŻ lowercase |
| launcher-token.php nieużyte nonce/challenge | Linie 224-310: SĄ użyte gdy `$requireChallenge = true` |
