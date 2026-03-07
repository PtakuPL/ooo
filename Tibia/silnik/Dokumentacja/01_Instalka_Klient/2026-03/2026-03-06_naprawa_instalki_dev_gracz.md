# Naprawa plików instalki OTClient — DEV i GRACZ
## Data: 2026-03-06

## PROBLEMY ZNALEZIONE

### 1. KRYTYCZNY: Protocol 1420 vs assets 1412
- `init.lua` miał `protocol = 1420` w obu GameModes
- `data/setup.otml` ma `last-supported-version: 1412`
- Assets klienta istnieją TYLKO w `data/things/1412/`
- Klient odrzucał wersję 1420 jako nieobsługiwaną → błąd "Client version not supported"
- **FIX**: Zmieniono protocol na 1412 w obu GameModes (classic74, modern)

### 2. CLIENT_LOCKED bez launchera → login odrzucony
- `CLIENT_LOCKED=true` w init.lua i .env
- Brak działającego launchera → brak OTC_LAUNCH_TOKEN
- login.php odrzucał: "Launch token required. Please use the official launcher."
- **FIX**: Dodano DEV_MODE via `OTC_DEV_MODE=1` env var → CLIENT_LOCKED=false w trybie deweloperskim

### 3. tryHttpLogin nie parsował URL gdy CLIENT_LOCKED=false
- Parsowanie httpLoginUrl było wewnątrz `if CLIENT_LOCKED then` → w DEV mode (CLIENT_LOCKED=false) klient próbował parsować G.host jak "host/path" co nie działało
- **FIX**: Zmieniono na użycie httpLoginUrl z GameModes niezależnie od CLIENT_LOCKED

### 4. GameMode selection nie pokazywany w DEV mode
- `if CLIENT_LOCKED and GameModes then` → DEV_MODE omijał panel wyboru trybu
- Bez wybranego trybu gry httpLoginUrl nie był dostępny → login fail
- **FIX**: Zmieniono na `if GameModes then` — panel wyboru trybu pokazywany zawsze gdy GameModes zdefiniowane

### 5. doLogin blokował na gameModeSelected tylko przy CLIENT_LOCKED
- Analogicznie: `if CLIENT_LOCKED and not gameModeSelected then` → DEV_MODE pomijał sprawdzenie
- **FIX**: Zmieniono na `if GameModes and not gameModeSelected then`

### 6. Domyślny clientVersion fallback 1420
- Dwa miejsca w entergame.lua miały fallback `1420` → niezgodne z assets
- **FIX**: Zmieniono oba na `1412`

---

## ZMIANY W PLIKACH

### init.lua (testyy/ + client_pack/ + launcher_test/)
- Dodano DEV_MODE via `os.getenv("OTC_DEV_MODE")`
- Protocol: 1420 → 1412 w obu GameModes
- Dodano log `[CONFIG] CLIENT_LOCKED=... DEV_MODE=...`

### entergame.lua (testyy/ + client_pack/ + launcher_test/)
- clientVersion default: 1420 → 1412 (dwa miejsca)
- GameMode selection: `if CLIENT_LOCKED and GameModes` → `if GameModes`
- doLogin gameMode check: `if CLIENT_LOCKED and not gameModeSelected` → `if GameModes and not gameModeSelected`
- tryHttpLogin URL: usunięto `if CLIENT_LOCKED` z parsowania httpLoginUrl — zawsze używa GameModes gdy dostępne

### Nowe pliki
- `start_dev.sh` — skrypt uruchomieniowy DEV (Linux, OTC_DEV_MODE=1)
- `start_dev.bat` — skrypt uruchomieniowy DEV (Windows)
- `start_player.bat` — skrypt uruchomieniowy produkcyjny (Windows, CLIENT_LOCKED=true)
- `.env.dev` — szablon .env dla trybu deweloperskiego (CLIENT_LOCKED=false)

---

## ARCHITEKTURA DEV vs GRACZ

### Tryb DEV (deweloper)
```
Skrypt: start_dev.sh / start_dev.bat
Env:    OTC_DEV_MODE=1
.env:   CLIENT_LOCKED=false
Flow:   klient → GameMode → email/hasło → login.php (bez launchToken) → session → character list → bezpośrednie połączenie (bez ticket-gate)
```

### Tryb GRACZ (produkcyjny)  
```
Skrypt: przez Launcher (Rust/Tauri)
Env:    OTC_LAUNCH_TOKEN=<token_z_API>
.env:   CLIENT_LOCKED=true
Flow:   launcher → launcher-token.php → OTC_LAUNCH_TOKEN → klient → GameMode → email/hasło → login.php (z launchToken) → session → character list → ticket.php → HMAC ticket → połączenie z serwerem gry
```

---

## REJESTRACJA KONTA (WWW vs API)

### CanaryAAC (strona WWW /createaccount)
- Tworzy konto z argon2 hasłem
- login.php weryfikuje argon2 przez `password_verify()` ✅
- BEZ `engine_password_sha1` (nie potrzebne dla HTTP login + ticket flow)
- ⚠ UWAGA: CanaryAAC używa `FILTER_SANITIZE_SPECIAL_CHARS` na haśle — znaki specjalne (&<>) mogą być zmienione

### API (register-account.php)
- Tworzy konto z argon2 + SHA1 hash
- Pełna kompatybilność z login.php i game serwerem
- Rekomendowane dla nowych kont

---

## STAN USŁUG (weryfikacja)
- Apache HTTPS :443 → ✅ działa, cacert.pem waliduje certyfikat
- PHP API :8080 → ✅ login.php, register-account.php, ticket.php dostępne
- Game Classic :7171/:7172 → ✅ serwer Canary nasłuchuje
- Game Modern :7173/:7174 → ✅ serwer Canary nasłuchuje
- MySQL → ✅ 5 migracji, 9+ tabel, konta istnieją
