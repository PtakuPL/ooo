# LAUNCHER — Jak działa pobieranie/aktualizacja/naprawa klienta

**Data:** 2026-03-05  
**Dotyczy:** Launcher Rust/Tauri (`Tibia/silnik/launcher-rust/`)

---

## SPIS TREŚCI

1. [Jak launcher pobiera klienta (fresh install)](#1-fresh-install)
2. [Jak launcher aktualizuje klienta](#2-update)
3. [Jak launcher naprawia klienta](#3-repair)
4. [Jak launcher uruchamia klienta](#4-launch)
5. [Self-update launchera](#5-self-update)
6. [Windows vs Linux vs Android](#6-platformy)
7. [Brakujące elementy](#7-brakujące)

---

## 1. FRESH INSTALL (Pobieranie klienta)

### Obecny flow:

```
[Użytkownik uruchamia launcher.exe]
        │
        ▼
[state.rs: AppState::new()]
  - Szuka launcher_config.json obok exe
  - Ładuje apiBaseUrl, channel, devMode
  - Tworzy AppStateInner z client_dir = "client/"
        │
        ▼
[app.js: checkForUpdates()]
  - invoke("check_for_updates")
        │
        ▼
[commands.rs: check_for_updates]
  1. Lock state → pobierz api_url, channel, client_dir
  2. ApiClient::new(config) → reqwest HTTP client
  3. api.fetch_manifest(&channel) → GET update.php?channel=stable
  4. LocalFileIndex::scan_from_manifest(&manifest, &client_dir)
     - Dla każdego pliku z manifestu → sprawdź czy istnieje + SHA-256
  5. build_update_plan(&manifest, &index)
     - Porównaj: manifest pliki vs lokalne pliki
     - Wygeneruj: to_download[], to_delete[], is_up_to_date
  6. Return UpdatePlanSummaryDto
        │
        ▼
[app.js: startUpdate()]
  - invoke("start_update")
        │
        ▼
[commands.rs: start_update]
  1. Sprawdź: update_in_progress → blokada podwójnego startu
  2. Pobierz manifest (ponownie)
  3. Skanuj lokalne pliki (ponownie) 
  4. Dla każdego pliku w plan.to_download:
     a. api.download_file(&file.url) → HTTP GET plik binarny
     b. patcher::stage_file(&ctx, path, data, expected_sha256)
        - Zapisz w staging/ dir
        - Weryfikuj SHA-256
  5. patcher::apply_plan(&ctx, &plan, &staged_paths, &mut state)
     a. Backup istniejących plików → .launcher/backup/tx_id/
     b. Przenieś staged → client/
     c. Usuń pliki z to_delete
  6. compute_files_hash(&manifest, &client_dir) → SHA-256 wszystkiego
  7. installed.mark_success(version, manifest_id, files_hash, timestamp)
  8. Sync serverlist.lua / serverlist.json
  9. save_state(installed_state.json)
```

### Struktura katalogów po instalacji:

```
C:\Gry\Tibia\otland\otclient\     (Windows) lub ~/Games/OTClient/ (Linux)
├── launcher.exe                   # sam launcher (Tauri)
├── launcher_config.json           # konfiguracja (ręcznie lub z instalatora)
├── client/                        # pliki klienta gry
│   ├── otclient.exe              # główny exe klienta
│   ├── data/                     # dane gry (sprites, .dat, .spr)
│   ├── modules/                  # Lua moduły
│   ├── serverlist.lua            # lista serwerów (zsynchronizowana)
│   └── serverlist.json
├── .launcher/                     # dane launchera
│   ├── installed_state.json      # stan instalacji
│   ├── logs/                     # logi
│   ├── downloads/                # pobrane artefakty
│   └── backup/                   # backupy przed aktualizacją
│       └── {tx_id}/             # backup per transakcja
```

### Manifest (co zwraca API):

```json
{
  "version": "1.0.0",
  "manifestId": "abc123",
  "schemaVersion": "2.0",
  "generatedAtUtc": "2026-03-05T12:00:00Z",
  "fileCount": 7791,
  "files": [
    {
      "path": "otclient.exe",
      "sha256": "abc123...",
      "size": 15000000,
      "url": "https://api.serwercanary.pl/client/files/stable/otclient.exe"
    },
    {
      "path": "data/Tibia.dat",
      "sha256": "def456...",
      "size": 50000000,
      "url": "https://api.serwercanary.pl/client/files/stable/data/Tibia.dat"
    }
    // ... 7789 więcej plików
  ],
  "servers": [
    { "name": "SerwerCanary 14.20+", "host": "serwercanary.pl", "port": 7171 }
  ]
}
```

---

## 2. UPDATE (Aktualizacja istniejącego klienta)

### Różnica vs fresh install:
- Fresh install: `LocalFileIndex::scan` → wszystko brakuje → pobierz wszystko
- Update: `scan` → większość OK → pobierz tylko zmienione/nowe

### Atomic update z rollback:

```
1. BEGIN TRANSACTION (tx_id = UUID)
   - installed_state.update_transaction.begin(tx_id, ...)
   - save_state() → persystencja na dysk

2. STAGING (bezpieczne — nie dotyka client/)
   - Pobierz zmienione pliki → .launcher/staging/{tx_id}/
   - Weryfikuj SHA-256 każdego pliku
   - Jeśli verify fail → abort, nie ruszaj client/

3. BACKUP (kopiuj stare pliki)
   - .launcher/backup/{tx_id}/ ← kopie nadpisywanych plików
   - Pozwala na rollback

4. APPLY (niebezpieczne — nadpisuje client/)
   - Przenieś staging/ → client/
   - Usuń pliki z to_delete

5. FINALIZE
   - compute_files_hash() → nowy hash
   - mark_success() → zapisz wersję, hash, timestamp
   - cleanup staging/ i backup/

6. RECOVERY
   - Jeśli launcher crashnie między 3 a 5 → przy restarcie:
   - update_transaction.needs_recovery() → true
   - UI pokazuje "Wykryto przerwaną aktualizację"
   - Rollback: przywróć backup → client/
```

### Delta update (przyszłość):
Obecnie: pełne pliki (jeśli zmieniony 1 bajt → pobierz cały plik).
Przyszłość: bsdiff/zstd patche (wymaga wsparcia w manifest v3).

---

## 3. REPAIR (Naprawa)

### Flow:

```
[commands.rs: repair_installation]
  1. Pobierz manifest z API (najnowszy)
  2. diagnose_installation(&manifest, &client_dir)
     - Dla KAŻDEGO pliku z manifestu:
       a. Czy istnieje? → nie → missing_files[]
       b. SHA-256 == oczekiwany? → nie → corrupted_files[]
       c. OK → ok_files[]
  3. Zwróć RepairDiagnosticsDto:
     - corrupted_count, missing_count, ok_count
     - repair_download_bytes (ile trzeba pobrać)
     - corrupted_files[], missing_files[]
```

### Czego BRAKUJE w repair:
- **Nie naprawia automatycznie** — tylko diagnozuje!
- Aby naprawić: użytkownik musi kliknąć "Aktualizuj" → `start_update` pobierze brakujące
- TODO: Dedykowany `perform_repair` command który pobiera TYLKO corrupted+missing

---

## 4. LAUNCH (Uruchomienie klienta)

### Flow:

```
[commands.rs: launch_game]
  1. Załaduj installed_state.json
  2. Pobierz files_hash + manifest_version
  3. POST /launcher-token.php:
     {
       launcherVersion: "0.1.0",
       filesHash: "abc123...",
       channel: "stable",
       manifestVersion: "1.0.0"
     }
  4. API odpowiada: { token: "hex64", expiresInSeconds: 300 }
  5. Uruchom OTClient:
     - exe: client/otclient.exe (Win) lub client/otclient (Linux)
     - working_dir: client/
     - env: LAUNCH_TOKEN={token}
     - env: LAUNCH_CHANNEL={channel}
  6. OTClient startuje → loguje się → serwer weryfikuje ticket
```

### Co robi OTClient z tokenem (TODO — jeszcze nie zaimplementowane w OTC):
1. Czyta env `LAUNCH_TOKEN`
2. Przy `onRecvFirstMessage` wysyła token do serwera
3. Serwer (Canary C++) weryfikuje HMAC + expiry + nonce
4. Jeśli OK → normalne logowanie
5. Jeśli fail → disconnect z kodem `LCH_TOKEN_INVALID`

---

## 5. SELF-UPDATE (Aktualizacja launchera)

### Flow:

```
[check_launcher_update]
  1. GET /launcher-version.php
     Response: {
       version: "1.1.0",
       minVersion: "1.0.0",
       url: "https://api.../launcher-1.1.0-win64.zip",
       sha256: "abc...",
       notes: "Nowa wersja..."
     }
  2. Porównaj z CARGO_PKG_VERSION
  3. Zwróć: UpToDate | UpdateAvailable | UpdateRequired

[perform_self_update]
  1. Pobierz paczkę z url
  2. Weryfikuj SHA-256
  3. Stage do .launcher/staging/self-update/
  4. Uruchom launcher-helper:
     - helper czeka 2s → zamyka stary launcher → kopiuje nowy → uruchamia
  5. Helper PID zwrócony → frontend zamyka okno
```

---

## 6. PLATFORMY — Windows vs Linux vs Android

### Windows (główna platforma)

| Aspekt | Szczegóły |
|--------|-----------|
| Kompilacja CI | `windows-latest` + Rust 1.82 + MSVC |
| Artefakty | `launcher-tauri-windows-x86_64.zip`, `launcher-cli-windows-x86_64.zip` |
| Instalacja | Ręczne rozpakowanie ZIP do `C:\Gry\Tibia\otland\otclient\` |
| Launcher | `launcher-tauri.exe` (Tauri + WebView2) |
| Klient | `client\otclient.exe` |
| WebView | Microsoft Edge WebView2 (domyślnie dostępny od Win10 1809) |
| Self-update | `launcher-helper.exe` zamienia exe po restarcie |

### Linux

| Aspekt | Szczegóły |
|--------|-----------|
| Kompilacja CI | `ubuntu-22.04` + Rust 1.82 + GTK3 + WebKitGTK |
| Artefakty | `launcher-tauri-linux-x86_64.zip`, `launcher-cli-linux-x86_64.zip` |
| Instalacja | Rozpakować do `~/Games/OTClient/` |
| Launcher | `launcher-tauri` (Tauri + WebKitGTK) |
| Klient | `client/otclient` |
| WebView | WebKitGTK 4.1 |
| Self-update | `launcher-helper` (ten sam mechanizm jak Windows) |

### Android (NIE ZAIMPLEMENTOWANY)

| Aspekt | Status |
|--------|--------|
| Kompilacja | ❌ Brak wsparcia |
| Tauri | Tauri v2 ma eksperymentalny Android support, ale wymaga Android NDK |
| OTClient | OTClient nie ma natywnego Android build |
| Alternatywa | Osobna aplikacja Android (Kotlin/Flutter) z innym backendem |
| Plan | Wymaga kompletnie osobnego projektu + ~200h pracy |

### Macierz wsparcia

| Platforma | Launcher | Klient gry | Status |
|-----------|----------|------------|--------|
| Windows x86_64 | ✅ Tauri GUI | ✅ OTClient.exe | W trakcie |
| Linux x86_64 | ✅ Tauri GUI | ⚠️ OTClient (wymaga build) | W trakcie |
| macOS | ⚠️ Tauri supportuje | ❌ OTClient brak build | Nie planowane |
| Android | ❌ Brak | ❌ Brak | Daleka przyszłość |
| iOS | ❌ Brak | ❌ Brak | Nie planowane |

---

## 7. BRAKUJĄCE ELEMENTY (aby działało end-to-end)

### Aktualizacja 2026-03-05 16:03 (postęp)

- ✅ Dodano endpoint `apik/v1/challenge.php` (nonce issue + TTL + DB persist + structured logging).
- ✅ Dodano endpoint `apik/v1/server-status.php` (response kompatybilny z launcher Rust model `ServerStatusResponse`).
- ✅ `launcher-token.php` obsługuje challenge-response (`nonce`, `challengeResponse`) z flagą rolloutową `CHALLENGE_REQUIRED`.
- ⏳ Nadal do domknięcia operacyjnie: etapowe włączenie `CHALLENGE_REQUIRED=true` oraz monitoring wolumenu `ticket_nonces`.

### Aktualizacja 2026-03-05 17:xx (i18n UI — start wdrożenia)

- ✅ Launcher UI ma runtime i18n PL/EN (przełącznik języka w Ustawieniach + persist w `localStorage`).
- ✅ Przetłumaczone: statusy faz, progress update, ekran naprawy, download center, self-update, alerty eksportu logów.
- ✅ Dodane fallbacki: brak tłumaczenia nie rozbija UI (pokazuje surową wartość statusu/stage).
- ⏳ Nadal do domknięcia:
  - pełny RTL (`ar/he/fa`),
  - wydzielenie tłumaczeń do plików JSON i pipeline language-packów.

### Aktualizacja 2026-03-05 18:xx (i18n persist backend)

- ✅ Dodano `language` do `LauncherConfig` i zapis do `launcher_config.json`.
- ✅ `change_channel` zapisuje teraz `channel + language` trwale po stronie launchera.
- ✅ `get_status` zwraca `language`, więc UI synchronizuje locale z backendu przy starcie.
- ⏳ Otwarte: paczki językowe/fontowe poza Tier0 (PL/EN) i pipeline ich dystrybucji.

### Aktualizacja 2026-03-05 19:xx (RTL ar/he/fa)

- ✅ Dodano locale `ar`, `he`, `fa` w selectorze języka launchera.
- ✅ UI przełącza `dir=ltr/rtl` dynamicznie per locale.
- ✅ Dodano mirrored layout dla RTL (header, karty, listy, stopka/nawigacja).
- ✅ Dodano bazowe paczki i18n `ar.json`, `he.json`, `fa.json` pod testy RTL.

### Aktualizacja 2026-03-05 20:xx (i18n coverage + błędy frontendu)

- ✅ Nazwy światów w UI są ustawiane przez klucze i18n (bez hardcoded final label).
- ✅ Kody błędów frontendowych (`CHECK_ERROR`, `UPDATE_ERROR`, `LAUNCH_ERROR`, `REPAIR_ERROR`, `SETTINGS_ERROR`) mają mapowanie do `errors.frontend.*`.
- ✅ Dodano fallback font stack oparty o rodzinę Noto dla lepszego pokrycia Unicode.
- ⏳ Nadal otwarte: pełna gwarancja pokrycia wszystkich skryptów wymaga bundlowanych font-packów i pipeline dystrybucji.

### Krytyczne — bez tego launcher nie pobierze klienta:

| # | Co brakuje | Gdzie | Wymagany wysiłek |
|---|-----------|-------|-----------------|
| B1 | **Prawdziwy manifest z plikami OTClient** | API `update.php` + `generate_manifest.php` | Trzeba: (a) zbudować OTClient, (b) wgrać pliki na serwer/CDN, (c) wygenerować manifest z prawdziwymi SHA-256 i URL-ami |
| B2 | **CDN/storage na pliki klienta** | nginx lub S3/CloudFlare | Pliki klienta (~500MB) muszą być dostępne do HTTP download |
| B3 | **DNS + SSL certyfikat** | `api.serwercanary.pl` | Certbot/Let's Encrypt + A record |
| B4 | **OTClient ticket module** | `modules/game_ticket/` | Lua moduł odczytujący env `LAUNCH_TOKEN` i wysyłający do serwera |
| B5 | **TICKET_GATE w Canary CMake** | `CMakeLists.txt` | `-DTICKET_GATE=ON` + kompilacja |

### Ważne — wymagane przed publicznym release:

| # | Co brakuje | Opis |
|---|-----------|------|
| B6 | Instalator/setup.exe | Obecnie ZIP ręcznie rozpakowywany — potrzebny NSIS/WiX installer |
| B7 | Auto-start po instalacji | Launcher powinien sam się uruchomić po rozpakowaniu |
| B8 | Desktop shortcut | Skrót na pulpicie po instalacji |
| B9 | Progress bar (real-time) | Tauri events `app.emit()` zamiast jednego progress na końcu |
| B10 | Retry/resume download | Jeśli internet zniknie w trakcie → wznów od ostatniego pliku |
| B11 | Bandwidth throttling | Opcja ograniczenia prędkości pobierania |
| B12 | UI "pierwszy raz" wizard | Ekran powitalny, wybór katalogu instalacji, język |

### Infrastruktura:

| # | Co brakuje | Opis |
|---|-----------|------|
| B13 | Monitoring API | Health checks, alerting na 5xx/timeout |
| B14 | Rate limiting | Brak per-IP throttle na API endpoints |
| B15 | Cleanup cron | Wygasłe tokeny/nonce/sessions w DB |
| B16 | Backup DB | Regularny mysqldump |
| B17 | Log rotation | PHP/nginx logi rosną w nieskończoność |
| B18 | Language packs/font packs (poza PL/EN) | RTL jest wdrożony; brak pipeline dystrybucji paczek językowych/fontowych |

### Cel testowy na 2026-03-06 (dual-mode + security)

Docelowy wynik na jutro (2026-03-06):
- launcher uruchomiony z paczki Windows pobranej przez usera (pakiet referencyjny),
- dwa równoległe logowania: świat 7.4 i świat modern,
- potwierdzona różnica polityk bezpieczeństwa między trybami (7.4: blokady hotkeys/runy, modern: bez tej blokady),
- poprawki dostarczane do użytkowników przez update klienta i self-update launchera.

### Zasada operacyjna: package-as-source-of-truth

1. Każdy test akceptacyjny wykonujemy na tej paczce Windows, która została pobrana do testów graczy.
2. Naprawy launcher/klient uznajemy za gotowe dopiero po walidacji na tej paczce.
3. Ścieżka release dla poprawek launcherowych: `launcher-version.php` + `perform_self_update` + artefakt z poprawioną wersją.

### Checklista demonstracyjna (D1..D5)

| ID | Sprawdzenie | Oczekiwany wynik |
|----|-------------|------------------|
| D1 | Start launchera i check/update na paczce Windows | Launcher działa i pobiera właściwe artefakty |
| D2 | Równoległe uruchomienie 7.4 + modern | Obie sesje startują i łączą się z właściwym światem |
| D3 | Test hotkeys/runy w 7.4 vs modern | 7.4 blokuje zgodnie z planem, modern nie blokuje |
| D4 | Celowa modyfikacja pliku krytycznego | Launch zablokowany, naprawa możliwa przez repair/update |
| D5 | Podbicie wersji launchera i self-update | Launcher aktualizuje się i przenosi poprawkę do użytkownika |

---

## DIAGRAM FLOW — PEŁNY LIFECYCLE

```
          ┌──────────────┐
          │ FIRST LAUNCH │
          └──────┬───────┘
                 │
    ┌────────────▼────────────┐
    │ 1. Load launcher_config │
    │    (apiBaseUrl, channel) │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ 2. check_for_updates()  │
    │    GET /update.php      │──── API ERROR ──→ [Show error, retry]
    │    Parse manifest       │
    └────────────┬────────────┘
                 │
         ┌───────┴───────┐
         │               │
    [No files]      [Some files OK]
    Fresh install    Partial update
         │               │
         └───────┬───────┘
                 │
    ┌────────────▼────────────┐
    │ 3. start_update()       │
    │    Download files       │──── SHA-256 FAIL ──→ [Abort, retry]
    │    Stage → Backup →     │
    │    Apply → Finalize     │──── CRASH ──→ [Recovery on restart]
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ 4. READY TO PLAY        │
    │    "Graj" button active │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ 5. launch_game()        │
    │    POST /launcher-token │──── TOKEN FAIL ──→ [Show error]
    │    Spawn OTClient.exe   │
    │    ENV: LAUNCH_TOKEN    │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ 6. OTClient connects    │
    │    to game server       │
    │    Ticket verification  │──── TICKET FAIL ──→ [Disconnect]
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ 7. PLAYING              │
    └─────────────────────────┘
```
