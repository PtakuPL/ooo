# Pełny audyt projektu ticket-gate — PHP, SQL, GHA, konfiguracja

**Data:** 2025-06-18  
**Commit:** `d95e5ebb1` (FIX-AUDIT)  
**Poprzedni commit:** `365fe958b` (FIX-GUARDS — C++ protocolgame.cpp)  
**Branch:** `feature/ticket-gate`

---

## Podsumowanie

Pełny przegląd **wszystkich plików** zmienionych na branchu `feature/ticket-gate` (80+ plików).  
Znaleziono i naprawiono **4 dodatkowe błędy** (łącznie z poprzednią sesją: **15 błędów**).

---

## 1. Znalezione i naprawione błędy

### BUG 1 — GHA Workflows: brak `feature/ticket-gate` w triggers (7 plików)

**Pliki:**
- `canary_test/.github/workflows/build-ubuntusr.yml`
- `canary_test/.github/workflows/build-linuxsr.yml`
- `canary_test/.github/workflows/build-windowssr.yml`
- `canary_test/testyy/.github/workflows/build-windows.yml`
- `canary_test/testyy/.github/workflows/build-linux.yml`
- `canary_test/testyy/.github/workflows/build-android.yml`
- `canary_test/testyy/.github/workflows/build-wasm.yml`

**Problem:** Wszystkie 7 workflow miało trigger `push` i `pull_request` tylko na `master`/`main` (i ewentualnie `feature/i18n-multilanguage`). **Żaden build nie uruchamiał się** przy push na `feature/ticket-gate`.

**Naprawa:** Dodano `- 'feature/ticket-gate'` do sekcji `branches:` w `push` i `pull_request` triggers we wszystkich 7 plikach.

**Wpływ:** GHA nie budowało canary ani testyy po żadnym pushu na ten branch — żadna kompilacja nie była weryfikowana.

---

### BUG 2 — SQL: `ticket_gate_migration.sql` — DATETIME zamiast INT UNSIGNED

**Plik:** `canary_test/sql/ticket_gate_migration.sql`

**Problem:**
- `ticket_sessions.expires_at` — używał `DATETIME`
- `ticket_nonces.expires_at` — używał `DATETIME`

Ale kod PHP zapisuje `bind_param('i', time() + $ttl)` — to jest **integer** (Unix timestamp).  
MySQL z DATETIME wstawiłby `0000-00-00 00:00:00` lub rzucił błąd w trybie STRICT.  
Kod C++ porównuje `expires_at < time(nullptr)` — też integer.

**Naprawa:**
- Zmieniono oba `DATETIME` → `INT UNSIGNED NOT NULL COMMENT 'Unix timestamp ...'`
- Zaktualizowano `EVENT` cleanup: `expires_at < UNIX_TIMESTAMP()` zamiast `< NOW()`

**Zgodność:** Schema `schema_ticket_gate.sql` już miała poprawne `INT UNSIGNED` — teraz migration jest spójna.

---

### BUG 3 — PHP: `login.php` — `$worlds` użyte przed zdefiniowaniem

**Plik:** `canary_test/html_copy/apik/v1/login.php`

**Problem:** Linia 268 używa `array_column($worlds, 'id')`, ale `$worlds = getWorldsForGameMode()` było definiowane dopiero na linii 303.

**Efekt:** PHP Warning: Undefined variable `$worlds` → `array_column(null, 'id')` → pusta tablica → żaden character nie miał przydzielonego `world_id`.

**Naprawa:** Przeniesiono `$worlds = getWorldsForGameMode($gameMode, $ENV);` i `$worldIdsAvailable = array_column($worlds, 'id');` **przed** pętlę `foreach ($characters as ...)`, usunięto duplikat.

---

### BUG 4 — PHP: `launcher-token.php` — brakujący `$stmt->execute()`

**Plik:** `canary_test/html_copy/apik/v1/launcher-token.php`

**Problem:** W gałęzi kodu dla pustego `manifestVersion` (linia ~157):
```php
$stmt->bind_param('s', $launcherVersion);
$mvRes = $stmt->get_result();  // ← BEZ execute()!
```

**Efekt:** Query nigdy się nie wykonuje → `$mvRes->num_rows` = 0 → trafia w ścieżkę FIX21 BLOCKED → **każdy token request bez manifestVersion jest odrzucany** (choć powinien pobrać ostatnią wersję).

**Naprawa:** Dodano `$stmt->execute();` między `bind_param` a `get_result`.

---

## 2. Sprawdzone pliki — status

### PHP API (`canary_test/html_copy/apik/v1/`)

| Plik | Linie | Status | Uwagi |
|------|-------|--------|-------|
| `login.php` | ~361 | **FIXED** | $worlds use-before-define |
| `ticket.php` | 197 | ✅ OK | HMAC-SHA256, nonce, B1/B2, FIX-AUD17 |
| `common.php` | 165 | ✅ OK | loadEnvFiles, fail-closed DB config |
| `launcher-token.php` | 209 | **FIXED** | Brakujący execute() |
| `launcher-version.php` | 50 | ✅ OK | Wersja + min_version |
| `generate_manifest.php` | 183 | ✅ OK | SHA256, recursive scan |
| `update.php` | 50 | ✅ OK | Patch manifest endpoint |

### SQL schemas

| Plik | Status | Uwagi |
|------|--------|-------|
| `html_copy/apik/v1/schema_ticket_gate.sql` | ✅ OK | INT UNSIGNED — poprawne |
| `html_copy/apik/v1/schema_launcher.sql` | ✅ OK | launch_tokens + manifest_versions |
| `sql/ticket_gate_migration.sql` | **FIXED** | DATETIME → INT UNSIGNED |

### GHA Workflows (server: canary_test)

| Plik | Status | Uwagi |
|------|--------|-------|
| `build-ubuntusr.yml` | **FIXED** | +feature/ticket-gate (push) |
| `build-linuxsr.yml` | **FIXED** | +feature/ticket-gate (push) |
| `build-windowssr.yml` | **FIXED** | +feature/ticket-gate (push+PR) |

### GHA Workflows (client: testyy)

| Plik | Status | Uwagi |
|------|--------|-------|
| `build-windows.yml` | **FIXED** | +feature/ticket-gate (push+PR) |
| `build-linux.yml` | **FIXED** | +feature/ticket-gate (push+PR) |
| `build-android.yml` | **FIXED** | +feature/ticket-gate (push+PR) |
| `build-wasm.yml` | **FIXED** | +feature/ticket-gate (push+PR) |

### Konfiguracja

| Plik | Status | Uwagi |
|------|--------|-------|
| `.env.example` | ✅ OK | Wszystkie klucze ticket-gate obecne |
| `deploy_api.sh` | ✅ OK | CLIENT_LOCKED + TICKET_SECRET drift check |
| `launcher_config.json` | ✅ OK | Endpoints, version, hash |
| `testyy/init.lua` | ✅ OK | CLIENT_LOCKED=true, GameModes config |
| `config.lua.dist` | ✅ OK | ticketSecret, ticketTTL, ticketNonceWindow |

### C++ (audyt z commit `365fe958b`)

| Plik | Status | Uwagi |
|------|--------|-------|
| `protocolgame.cpp` | **FIXED** (11 bugs) | 18/18 guardów — patrz `audyt_protocolgame_guard_fix.md` |
| `ticket_validator.cpp` | ✅ OK | HMAC-SHA256, nonce replay, constant-time |
| `ticket_validator.hpp` | ✅ OK | Deklaracje |
| `configmanager.cpp` | ✅ OK | Ticket config keys registered |
| `config_enums.hpp` | ✅ OK | Enum entries present |
| `player.hpp` | ✅ OK | ticket/world fields |
| `protocolgame.hpp` | ✅ OK | Deklaracje parseTicket/guards |
| `CMakeLists.txt` | ✅ OK | OpenSSL dodane (canary_test only) |
| `vcpkg.json` | ✅ OK | openssl dependency |

### Porównanie canary/ vs canary_test/

| Element | Różnica | Ocena |
|---------|---------|-------|
| `CMakeLists.txt` | +OpenSSL w canary_test | ✅ Oczekiwane (ticket-gate wymaga HMAC) |
| `vcpkg.json` | +openssl w canary_test | ✅ Oczekiwane |
| `game.cpp` | Różnice i18n | ✅ Pochodzą z innego brancha |

---

## 3. Podsumowanie bugów — obie sesje

| # | Plik | Typ | Bug | Commit |
|---|------|-----|-----|--------|
| 1-3 | protocolgame.cpp | C++ korupcja | D2: parseUseItem/Ex/Creature zniszczone | `365fe958b` |
| 4-5 | protocolgame.cpp | C++ guard | D5 Prey w złych miejscach | `365fe958b` |
| 6-8 | protocolgame.cpp | C++ guard | D4 Market: osierocony/brak/duplikat | `365fe958b` |
| 9-11 | protocolgame.cpp | C++ guard | D10 Bestiary w highscores/report/charms | `365fe958b` |
| 12 | protocolgame.cpp | C++ guard | D3 Quick Loot brak | `365fe958b` |
| 13 | ticket_gate_migration.sql | SQL typ | DATETIME zamiast INT UNSIGNED | `d95e5ebb1` |
| 14 | login.php | PHP variable | $worlds use-before-define | `d95e5ebb1` |
| 15 | launcher-token.php | PHP logic | Brakujący $stmt->execute() | `d95e5ebb1` |
| — | 7× GHA workflows | CI config | Brak feature/ticket-gate w branches | `d95e5ebb1` |

**Łącznie: 15 bugów w kodzie + 7 workflow misconfigurations**

---

## 4. Otwarte zadania (wymagają wdrożenia/infra)

| Zadanie | Status | Uwagi |
|---------|--------|-------|
| A8 — GHA test kompilacji OTClient | 🟢 Gotowe do uruchomienia | Workflow triggers naprawione |
| C6 — GHA test kompilacji Canary | 🟢 Gotowe do uruchomienia | Workflow triggers naprawione |
| DB — Deploy SQL migration | ⬜ Wymaga dostępu do serwera | ticket_gate_migration.sql gotowe |
| D11 — Test integracyjny feature flags | ⬜ Po kompilacji | Wymaga działającego buildu |
| E13 — Hosting plików klienta | ⬜ Infra | Serwer plików + manifest |
| DEPLOY — Konfiguracja .env produkcja | ⬜ Wymaga ustawień | .env.example jako szablon |

---

## 5. Historia commitów audytu

```
d95e5ebb1 FIX-AUDIT: Pełny audyt ticket-gate — workflows, SQL, PHP
365fe958b FIX-GUARDS: Naprawa 11 błędów kompilacji w protocolgame.cpp
4aca821ed gap-fix: validation.rs (launcher-rust — poprzedni sprint)
```
