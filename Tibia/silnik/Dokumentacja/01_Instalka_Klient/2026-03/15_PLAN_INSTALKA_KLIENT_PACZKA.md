# Plan: Instalka (Klient OTClient) — Paczka Gracza + DevPack
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0/P1

---

## Koncepcja — brak instalatora NSIS, launcher = instalator

```
Paczka gracza (ZIP):
├── launcher.exe              ← Tauri launcher (GUI)
├── launcher_config.json      ← konfiguracja (API URL, klucze, język)
├── client/                   ← PUSTY przy pierwszym uruchomieniu
│   └── (tu launcher pobierze pliki klienta z manifestu)
└── logs/                     ← logi launchera i klienta
```

**Flow "instalacji":**
1. Gracz pobiera ZIP (~5 MB) z RedDAXE/WWW
2. Rozpakowuje do folderu (np. `C:\Games\TibiaServer\`)
3. Uruchamia `launcher.exe`
4. Launcher pobiera pliki klienta z serwera (~200-500 MB)
5. Po pobraniu → "GRAJ" → uruchamia `client/otclient.exe`

**Aktualizacja:**
1. Launcher porównuje lokalne hashe z manifestem serwera
2. Pobiera TYLKO zmienione pliki (delta update)
3. Klient zawsze aktualny

---

## Stan obecny

### Artefakty do kompilacji:
| Artefakt | Workflow | Source | Output |
|---|---|---|---|
| Serwer Canary | build-ubuntusr.yml / build-windowssr.yml | canary_test/src/ | canary / canary.exe |
| OTClient (dev) | build-windows.yml | canary_test/testyy/src/ | otclient.exe |
| OTClient (gracz) | build-client-package.yml | canary_test/testyy/ | ZIP z czystą paczką |
| Launcher CLI | build-launcher.yml | launcher-rust/apps/launcher-cli/ | launcher-cli |
| Launcher Tauri | build-launcher.yml | launcher-rust/apps/launcher-tauri/ | launcher-tauri.exe |

### Konfiguracja klienta:
- `init.lua` — CLIENT_LOCKED=true, GameModes classic74+modern
- `config.lua` — Classic worldId=0 port 7171/7172, Modern worldId=1 port 7173/7174

---

## Zadania

### INS-01 (P0): Definicja zawartości paczki gracza
**Plik:** `canary_test/testyy/.github/workflows/build-client-package.yml`
```yaml
# Allowlist plików do paczki:
include:
  - otclient.exe
  - data/              # sprite, dat, map files
  - modules/           # Lua modules klienta
  - init.lua           # konfiguracja
  - config.lua         # serwery
  - i18n/              # tłumaczenia
  
# Blocklist (NIE pakować):
exclude:
  - *.pdb              # debug symbols
  - *.log              # logi
  - test*/             # testy
  - src/               # źródła
  - CMake*             # build system
  - .github/           # workflow
  - .git/              # repo
```

### INS-02 (P0): Brak sekretów w paczce gracza
**Walidacja przed pakowanie:**
```bash
# Sprawdzić że paczka nie zawiera:
grep -rl 'TICKET_SECRET\|DB_PASS\|PAYPAL_CLIENT_SECRET\|HMAC\|private_key' ./package/ && echo "FAIL: sekrety w paczce!" || echo "PASS: czysto"
```

### INS-03 (P0): init.lua — produkcyjne wartości
**Plik:** `canary_test/testyy/init.lua`
```lua
-- CLIENT_LOCKED = true (wymusza ticket-gate)
CLIENT_LOCKED = true

-- API URL (produkcja, nie localhost)
API_BASE_URL = "https://twojserwer.pl/apik/v1"

-- GameModes
GAME_MODES = {
    { id = 0, name = "Classic 7.4", loginPort = 7171, gamePort = 7172 },
    { id = 1, name = "Modern", loginPort = 7173, gamePort = 7174 }
}
```

### INS-04 (P0): config.lua klienta — zgodność z serwerem
**Plik:** `canary_test/testyy/config.lua` (lub data/config.lua)
- Serwery:
  - Classic: host=IP_SERWERA, loginPort=7171, gamePort=7172
  - Modern: host=IP_SERWERA, loginPort=7173, gamePort=7174
- **NIE hardcodować 127.0.0.1** w paczce gracza!

### INS-05 (P0): Launcher → Klient — przekazanie tokenu sesji
**Problem:** Jak launcher przekazuje ticket do klienta OTClient?
**Opcje:**
1. Argumenty CLI: `otclient.exe --account-session=TOKEN --game-host=IP --game-port=7172`
2. Plik tymczasowy: `client/.session` z tokenem (launcher zapisuje, klient czyta i kasuje)
3. Env variable: `GAME_SESSION_TOKEN=TOKEN`

**Rekomendacja:** Opcja 1 (argumenty CLI) — najprostsze, klient parsuje argv
**Plik do sprawdzenia:** `launcher-rust/crates/launcher-core/src/process_runner.rs`

### INS-06 (P0): Klient NIE pyta o login (ticket-gate)
**Plik:** `canary_test/testyy/modules/` — moduł logowania
- Jeśli klient uruchomiony z ticketem → pomijaj ekran logowania
- Automatycznie: connect → ticket → in-game
- Jeśli ticket expired/invalid → komunikat + "Wróć do launchera"

### INS-07 (P1): Manifest generowanie — pliki klienta
**Plik:** `/var/www/html/apik/v1/generate_manifest.php`
- Skanuje katalog `CLIENT_FILES_DIR` z .env
- Generuje manifest JSON z hashami SHA256
- Podpisuje Ed25519
- Umieszcza w `/apik/v1/manifests/stable/manifest.json`

**Test:**
```bash
php /var/www/html/apik/v1/generate_manifest.php
cat /var/www/html/apik/v1/manifests/stable/manifest.json | python3 -m json.tool | head -20
```

### INS-08 (P1): CLIENT_FILES_DIR — przygotowanie katalogu
**Plik .env:** `CLIENT_FILES_DIR=/home/ptaku/serweryt/Tibia/silnik/client_pack/1.1.0`
- Ten katalog musi zawierać pliki klienta po kompilacji
- Po build na GHA → pobrać artefakt → rozpakować do tego katalogu
- Wygenerować manifest

### INS-09 (P1): Test aktualizacji — zmiana 1 pliku
**Scenariusz:**
1. Paczka bazowa v1.0.0 → manifest z hashami
2. Zmień 1 plik (np. config.lua) → nowy manifest v1.0.1
3. Launcher widzi diff → pobiera TYLKO zmieniony plik
4. Weryfikuje hash → PASS

### INS-10 (P1): Repair mode
**Plik:** `launcher-rust/crates/launcher-core/src/repair.rs`
- Komenda w launcherze: "Napraw pliki"
- Sprawdza WSZYSTKIE hashe vs manifest
- Pobiera uszkodzone/brakujące pliki
- Wyświetla raport: "Naprawiono 3 pliki, 247 OK"

### INS-11 (P1): Paczka DEV vs paczka GRACZA — różnice
| Element | Paczka DEV | Paczka GRACZA |
|---|---|---|
| Debug symbols (.pdb) | TAK | NIE |
| Konsola debugowa | TAK | NIE |
| Logi verbose | TAK | NIE |
| Pliki źródłowe | TAK | NIE |
| CLIENT_LOCKED | false | true |
| API URL | localhost | produkcja |
| Profiler | TAK | NIE |

### INS-12 (P1): Layout paczki gracza (finalna)
```
TibiaServer-v1.0.0/
├── launcher.exe                 (3-5 MB, Tauri)
├── launcher_config.json         (< 1 KB)
├── WebView2Loader.dll           (wymagane przez Tauri na Windows)
├── README.txt                   ("Uruchom launcher.exe")
├── client/                      (PUSTY — launcher pobierze)
└── logs/                        (PUSTY — logi przy runtime)
```

### INS-13 (P2): Windows Defender / AV compatibility
- Skompilowany .exe może triggerować antywirus
- Rozwiązanie: code signing certificate (opcjonalnie, $$)
- Alternatywa: whitelist instrukcja w README

### INS-14 (P2): Portable — brak instalacji, brak uprawnień admina
- ZIP rozpakowywany gdziekolwiek
- Brak wpisów do rejestru Windows
- Brak uprawnień administratora
- Logi i cache w katalogu gry (nie AppData)

---

## Matryca testów Instalka/Klient

| # | Test | Oczekiwany wynik | Status |
|---|---|---|---|
| T-INS-01 | Paczka gracza nie zawiera sekretów | PASS | ⬜ |
| T-INS-02 | Paczka gracza nie zawiera plików dev | PASS | ⬜ |
| T-INS-03 | Launcher pobiera pliki klienta z manifestu | Pliki w client/ | ⬜ |
| T-INS-04 | Klient uruchamia się z ticketem | In-game bez logowania | ⬜ |
| T-INS-05 | Delta update — 1 plik zmieniony | Pobrany TYLKO 1 plik | ⬜ |
| T-INS-06 | Repair mode | Naprawione uszkodzone pliki | ⬜ |
| T-INS-07 | Portable install (brak admin) | Działa z folderu user | ⬜ |
| T-INS-08 | CLIENT_LOCKED=true w paczce | Klient wymaga ticketu | ⬜ |
