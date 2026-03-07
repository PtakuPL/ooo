# Ticket-Gate — PEŁNA DOKUMENTACJA WSZYSTKICH ZMIAN

**Gałąź:** `feature/ticket-gate`  
**Commit range:** `master..1bb129588` (702 commity, w tym automatyczne i18n guardian)  
**Data:** 2026-03-05  
**Status:** Wszystkie zmiany zpushowane — oczekuje na green CI build  

---

## SPIS TREŚCI

1. [Przegląd systemu](#1-przegląd-systemu)
2. [Architektura komponentów](#2-architektura-komponentów)
3. [Commit log — kluczowe commity](#3-commit-log)
4. [Launcher Rust — pełna budowa](#4-launcher-rust)
5. [PHP API — endpointy](#5-php-api)
6. [Baza danych — schematy](#6-bazy-danych)
7. [Serwer Canary C++ — zmiany ticket-gate](#7-canary-cpp)
8. [CI/CD — GitHub Actions](#8-cicd)
9. [Frontend UI — Tauri + HTML/JS](#9-frontend)
10. [Otwarte problemy i dług techniczny](#10-otwarte-problemy)

---

## 1. PRZEGLĄD SYSTEMU

### Cel ticket-gate
System zabezpieczeń kontrolujący uruchomienie klienta gry (OTClient):

```
[Gracz] → [Launcher (Rust/Tauri)] → [PHP API] → [Serwer Canary C++]
            ↓                           ↓              ↓
         Weryfikuje pliki           Generuje          Weryfikuje
         klienta (SHA256)          ticket+token      ticket HMAC
```

**Flow logowania:**
1. Launcher pobiera manifest z API → porównuje z lokalnymi plikami → aktualizuje brakujące
2. Launcher oblicza `filesHash` (SHA-256 wszystkich plików klienta)
3. Launcher wysyła `filesHash` + `launcherVersion` + `channel` → API `/launcher-token.php`
4. API weryfikuje, generuje token HMAC, zapisuje do MySQL `launch_tokens`
5. Launcher uruchamia OTClient z tokenem jako env var
6. OTClient loguje się na serwer → serwer wysyła `challenge` → klient odpowiada
7. API `/ticket.php` generuje ticket z nonce (HMAC-SHA256)
8. Canary C++ weryfikuje ticket: HMAC, nonce, expiry, replay protection

### Dlaczego jest to potrzebne
- **Anti-cheat:** Gwarantuje, że pliki klienta nie zostały zmodyfikowane
- **Anti-piracy:** Wymusza użycie oficjalnego launchera (nie można uruchomić ręcznie)
- **Version control:** Serwer odrzuca starsze wersje klienta
- **Replay protection:** Jednorazowe nonce'y zapobiegają ponownemu użyciu ticketów

---

## 2. ARCHITEKTURA KOMPONENTÓW

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SYSTEM SerwerCanary                         │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Launcher    │  │   PHP API    │  │ Serwer Canary│             │
│  │  Rust/Tauri   │  │  nginx+PHP   │  │    C++ 14.20 │             │
│  │              │  │              │  │              │             │
│  │ common-models│  │ /apik/v1/    │  │ protocolGame │             │
│  │ launcher-api │  │              │  │ ticket_gate  │             │
│  │ launcher-core│  │ launcher-    │  │              │             │
│  │ launcher-cli │  │  version.php │  │              │             │
│  │ launcher-    │  │ update.php   │  │              │             │
│  │  tauri (GUI) │  │ launcher-    │  │              │             │
│  │ launcher-    │  │  token.php   │  │              │             │
│  │  helper      │  │ ticket.php   │  │              │             │
│  │              │  │ challenge.php│  │              │             │
│  │              │  │ server-      │  │              │             │
│  │              │  │  status.php  │  │              │             │
│  │              │  │ installer-   │  │              │             │
│  │              │  │  catalog.php │  │              │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
│         │                 │                 │                      │
│         │     HTTPS       │     MySQL       │                      │
│         └────────────────►│◄────────────────┘                      │
│                           │                                        │
│                    ┌──────┴───────┐                                │
│                    │   MySQL DB   │                                │
│                    │              │                                │
│                    │ launch_tokens│                                │
│                    │ ticket_nonces│                                │
│                    │ ticket_      │                                │
│                    │  sessions    │                                │
│                    │ manifest_    │                                │
│                    │  versions    │                                │
│                    │ accounts     │                                │
│                    │ players      │                                │
│                    └──────────────┘                                │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐                               │
│  │   OTClient   │  │   Strona WWW │                               │
│  │  (instalka)  │  │  HTML/PHP    │                               │
│  │              │  │              │                               │
│  │ modules/     │  │ /var/www/    │                               │
│  │  game_*      │  │  html/       │                               │
│  │ serverlist   │  │              │                               │
│  └──────────────┘  └──────────────┘                               │
└─────────────────────────────────────────────────────────────────────┘
```

### Ścieżki na serwerze (WSL Ubuntu)

| Komponent | Ścieżka |
|-----------|---------|
| Git repo root | `/home/ptaku/serweryt/` |
| Serwer Canary (kod) | `/home/ptaku/serweryt/Tibia/silnik/canary/src/` |
| Serwer Canary (test build) | `/home/ptaku/serweryt/Tibia/silnik/canary_test/` |
| Launcher Rust workspace | `/home/ptaku/serweryt/Tibia/silnik/launcher-rust/` |
| PHP API (live) | `/var/www/html/apik/v1/` |
| MySQL DB | `localhost:3306`, baza `canary` |
| nginx config | `/etc/nginx/sites-enabled/` |
| Dokumentacja | `/home/ptaku/serweryt/Dokumentacja/` |
| Manifesty klienta | `/var/www/html/apik/v1/manifests/` |

---

## 3. COMMIT LOG — KLUCZOWE COMMITY

### Sprint 1-2: Fundament launchera (LR-001..LR-030)
| Commit | Opis |
|--------|------|
| `28499ce41` | Sprint 1: workspace + common-models + integrity + CI |
| `5c11b4490` | Sprint 2: launcher-core + launcher-api HTTP client |
| `8933db7af` | LR-010 + LR-026 + LR-030 — CLI flow, contract tests |
| `5cd6ff278` | LR-064 + LR-065 + LR-079 + LR-080 — CI matrix, DTO layer, thin frontend |

### Sprint 3: Tauri GUI (LR-031..LR-040)
| Commit | Opis |
|--------|------|
| `10bd31073` | Tauri UI v1 — pełny frontend HTML/CSS/JS |

### Sprint 4: Hardening (LR-041..LR-051)
| Commit | Opis |
|--------|------|
| `e18170e3c` | Self-update, artifact verify, challenge-response |

### Sprint 5: Security + Migration (LR-052..LR-061)
| Commit | Opis |
|--------|------|
| `2c5ecc431` | Ed25519 manifest signatures, HMAC rotation, telemetry, runbooks |

### Edge cases + Validation
| Commit | Opis |
|--------|------|
| `4aca821ed` | validation.rs ~310 LOC, 20 testów, grace period logic |

### Canary C++ fix
| Commit | Opis |
|--------|------|
| `365fe958b` | FIX-GUARDS: 11 błędów kompilacji protocolgame.cpp (guardy D2-D10) |
| `652c0e033` | RSA→CanaryRSA (OpenSSL conflict) + ticket nonce hardening |

### CI/CD fixes (10+ commitów)
| Commit | Opis |
|--------|------|
| `be1bfd8cd` | Workflows w repo root `.github/workflows/` |
| `7c5ae6f8f` | clippy + contract tests + nlohmann_json |
| `b6e9671ea` | Uproszczenie do 1 joba na platformę |

### Tauri frontend fixes
| Commit | Opis |
|--------|------|
| `a46ca05d9` | frontendDist `../ui` → `./ui` (ERR_CONNECTION_REFUSED) |
| `f01b6871a` | Wymuś embed frontendu, usunięto devUrl, dodano clean + Cargo.lock |

### API + dev_mode (najnowsze)
| Commit | Opis |
|--------|------|
| `a03d440bd` | Lista serwerów w UI, przycisk Strona WWW, graceful errors |
| `1bb129588` | Server-status API + dev_mode (self-signed certs) |

---

## 4. LAUNCHER RUST — PEŁNA BUDOWA

### Workspace (`Tibia/silnik/launcher-rust/Cargo.toml`)

```
launcher-rust/
├── Cargo.toml              # Workspace root
├── Cargo.lock              # Committed (deterministic builds)
├── launcher_config.json    # DEV ONLY — config dla lokalnego testowania
│
├── apps/
│   ├── launcher-tauri/     # GUI (Tauri v2.10.3)
│   │   ├── Cargo.toml
│   │   ├── tauri.conf.json # Tauri config
│   │   ├── build.rs
│   │   ├── src/
│   │   │   ├── main.rs     # Entry point, 13 commands registered
│   │   │   ├── state.rs    # AppState + AppStateInner (shared state)
│   │   │   └── commands.rs # Tauri command handlers (~800 LOC)
│   │   └── ui/
│   │       ├── index.html  # Single page app
│   │       ├── app.js      # Frontend logic (~500 LOC)
│   │       └── style.css   # Dark theme CSS
│   │
│   └── launcher-cli/       # CLI (headless, dla CI/automatyzacji)
│       ├── Cargo.toml
│       └── src/main.rs
│
├── crates/
│   ├── common-models/      # Shared data types
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── api_responses.rs   # API response structs (9 typów)
│   │       ├── dto.rs             # Frontend DTOs (6 typów)
│   │       ├── error_codes.rs     # LCH_* error codes
│   │       ├── installed_state.rs # Persistent state (JSON on disk)
│   │       ├── launcher_config.rs # LauncherConfig + discover()
│   │       ├── manifest.rs        # Manifest v1/v2 parser
│   │       ├── rollout_config.rs  # A/B bucketing per channel
│   │       ├── update_plan.rs     # Plan: download/delete/verify
│   │       └── validation.rs      # URL, semver, hash validators
│   │
│   ├── launcher-api/       # HTTP client (reqwest + rustls)
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── lib.rs
│   │       └── client.rs   # ApiClient + ApiClientConfig
│   │
│   ├── launcher-core/      # Business logic
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── artifact_verify.rs   # SHA-256 + size check
│   │       ├── challenge.rs         # Challenge-response (LR-052)
│   │       ├── file_index.rs        # Local file scanner
│   │       ├── hmac_rotation.rs     # HMAC key rotation (LR-056)
│   │       ├── integrity.rs         # filesHash computation
│   │       ├── manifest_signature.rs# Ed25519 verify (LR-053)
│   │       ├── patcher.rs           # Atomic staging + apply + rollback
│   │       ├── planner.rs           # Manifest diff → UpdatePlan
│   │       ├── process_runner.rs    # Spawn OTClient with token
│   │       ├── repair.rs            # Diagnose + repair mode
│   │       ├── self_update.rs       # Launcher self-update (LR-048..051)
│   │       ├── serverlist_sync.rs   # Write serverlist.lua/json
│   │       ├── state.rs             # load/save installed_state.json
│   │       └── telemetry.rs         # Opt-in metrics (LR-054)
│   │
│   └── launcher-helper/    # Background updater service
│       ├── Cargo.toml
│       └── src/main.rs
│
├── docs/                   # Kontrakty i runbooki
│   ├── contracts/          # 14 plików .md
│   ├── runbooks/           # rollback.md
│   └── 2026-03-03_launcher_sprint5_hardening_migration.md
│
└── tests/
    ├── contract_tests.rs
    ├── edge_case_tests.rs
    └── integration_tests.rs
```

### 13 Tauri Commands (zarejestrowane w `main.rs`)

| # | Command | Moduł | Opis |
|---|---------|-------|------|
| 1 | `get_status` | state | Zwraca LauncherStatusDto (ready/checking/error) |
| 2 | `check_for_updates` | api+planner | Pobiera manifest, skanuje lokalne, tworzy plan |
| 3 | `start_update` | patcher | Pobiera pliki, staging, backup, apply, finalize |
| 4 | `launch_game` | process_runner | Pobiera token z API, uruchamia OTClient |
| 5 | `repair_installation` | repair | Diagnoza SHA-256, zwraca corrupted/missing |
| 6 | `get_installation_info` | state | Podsumowanie installed_state.json |
| 7 | `change_channel` | state | Zmiana kanału (stable/test/dev) |
| 8 | `export_logs` | filesystem | Eksport logów do .txt |
| 9 | `get_installer_catalog` | api | Pobiera listę artefaktów do pobrania |
| 10 | `download_and_verify_artifact` | api+verify | Pobiera + SHA-256 verify + save |
| 11 | `check_launcher_update` | api+self_update | Sprawdza nową wersję launchera |
| 12 | `perform_self_update` | self_update | Stage + helper → restart |
| 13 | `get_server_status` | api | Status serwerów (online/offline/players) |

### LauncherConfig (`launcher_config.json`)

```json
{
  "apiBaseUrl": "https://api.serwercanary.pl/client/",
  "channel": "stable",
  "clientDir": "client",
  "launcherDataDir": ".launcher",
  "devMode": false
}
```

- `discover()` szuka: `{exe_dir}/launcher_config.json` → `{exe_dir}/../launcher_config.json`
- `devMode: true` → reqwest akceptuje self-signed certy (TYLKO do dev!)
- Domyślne wartości gdy brak pliku: `apiBaseUrl` = `https://api.serwercanary.pl/client/`

### Kluczowe typy danych

**`InstalledState`** (persystowany w `.launcher/installed_state.json`):
```rust
struct InstalledState {
    install_id: String,           // UUID instalacji
    channel: String,
    client_dir: String,
    launcher_version: String,
    api_base_url: String,
    current_manifest_version: Option<String>,
    current_manifest_id: Option<String>,
    current_files_hash: Option<String>,
    last_update_success: Option<String>,  // ISO timestamp
    update_transaction: UpdateTransaction,
}
```

**`NormalizedManifest`** (z API):
```rust
struct NormalizedManifest {
    version: String,
    manifest_id: String,
    schema_version: String,     // "1-compat" lub "2.0"
    generated_at_utc: String,
    files: Vec<ManifestFile>,   // path, sha256, size, url
    servers: Vec<ServerEntry>,  // dla serverlist_sync
}
```

**`UpdatePlan`**:
```rust
struct UpdatePlan {
    is_up_to_date: bool,
    to_download: Vec<FileAction>,    // nowe/zmienione
    to_delete: Vec<String>,          // usunięte z serwera
    total_download_bytes: u64,
}
```

---

## 5. PHP API — ENDPOINTY

### Lokalizacja: `/var/www/html/apik/v1/`

| Endpoint | Metoda | Opis | Kto wywołuje |
|----------|--------|------|-------------|
| `launcher-version.php` | GET | Wersja launchera + URL paczki | Launcher (self-update) |
| `update.php?channel=X` | GET | Manifest JSON (7791 plików) | Launcher (check_for_updates) |
| `launcher-token.php` | POST | Generuje launch token (HMAC) | Launcher (launch_game) |
| `ticket.php` | POST | Generuje ticket z nonce | OTClient → serwer |
| `challenge.php` | GET | HMAC challenge nonce | Launcher (integrity) |
| `server-status.php` | GET | Status serwerów (TCP check) | Launcher (get_server_status) |
| `installer-catalog.php?channel=X` | GET | Lista artefaktów do pobrania | Launcher (Download Center) |
| `login.php` | POST | Logowanie konta gracza | OTClient |

### Wspólne pliki

| Plik | Opis |
|------|------|
| `common.php` | `loadEnvFiles()`, `getOnlinePlayers()`, DB connect helper |
| `.env` | Sekrety: `HMAC_SECRET`, `DB_*`, `WORLD_*` porty, `MANIFEST_PATH` |
| `schema_ticket_gate.sql` | Tabele: `ticket_nonces`, `ticket_sessions` |
| `schema_launcher.sql` | Tabele: `launch_tokens`, `manifest_versions` |

### Szczegóły endpointów

#### `launcher-token.php` (POST)
```
Request:  { launcherVersion, filesHash, channel, manifestVersion, nonce?, challengeResponse? }
Response: { token: "hex64", expiresInSeconds: 300 }
```
- Weryfikuje `filesHash` vs aktualny manifest
- Generuje HMAC-SHA256 token
- Zapisuje do `launch_tokens` z TTL 5 min

#### `ticket.php` (POST)
```
Request:  { sessionKey, gameMode }
Response: { ticket: "base64(payload.hmac)", expiresAt: unix_ts }
```
- Weryfikuje `session_key` → `ticket_sessions`
- Generuje nonce, zapisuje do `ticket_nonces`
- Payload: `account_id|game_mode|nonce|expires_at`
- HMAC: SHA-256 z `HMAC_SECRET`

#### `server-status.php` (GET)
```
Response: { ts: unix, servers: [{ id, name, type, status, players, ping, host, port }] }
```
- TCP connect do `$srv['host']:$srv['port']` z 2s timeout
- Odczyt graczy z MySQL: `SELECT COUNT(*) FROM players_online WHERE ...`
- Obsługuje 2 serwery: `tibia-main` (14.20+), `tibia-retro` (7.4)

---

## 6. BAZY DANYCH

### Schematy (4 tabele launcher/ticket)

#### `launch_tokens`
```sql
CREATE TABLE launch_tokens (
    token             VARCHAR(64) NOT NULL PRIMARY KEY,
    launcher_version  VARCHAR(20) NOT NULL,
    files_hash        VARCHAR(64) NOT NULL,
    manifest_version  VARCHAR(20) NOT NULL DEFAULT '0.0.1',
    client_ip         VARCHAR(45) NOT NULL,
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at        TIMESTAMP NOT NULL,
    INDEX idx_expires (expires_at),
    INDEX idx_client_ip (client_ip)
);
```

#### `manifest_versions`
```sql
CREATE TABLE manifest_versions (
    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    version      VARCHAR(20) NOT NULL,
    channel      VARCHAR(20) NOT NULL DEFAULT 'stable',
    files_hash   VARCHAR(64) NOT NULL,
    file_count   INT UNSIGNED NOT NULL DEFAULT 0,
    total_size   BIGINT UNSIGNED NOT NULL DEFAULT 0,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY uq_version_channel (version, channel)
);
```

#### `ticket_nonces`
```sql
CREATE TABLE ticket_nonces (
    nonce       VARCHAR(64) NOT NULL PRIMARY KEY,
    account_id  INT NOT NULL DEFAULT 0,
    expires_at  INT UNSIGNED NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_expires (expires_at)
);
```

#### `ticket_sessions`
```sql
CREATE TABLE ticket_sessions (
    session_key  VARCHAR(128) NOT NULL PRIMARY KEY,
    account_id   INT NOT NULL,
    game_mode    VARCHAR(32) NOT NULL DEFAULT 'modern',
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at   INT UNSIGNED NOT NULL,
    INDEX idx_account (account_id),
    INDEX idx_expires (expires_at)
);
```

### Brakujące migracje (TODO P1)
- [ ] Rollout SQL: `schema_ticket_gate.sql` + `schema_launcher.sql` w kolejności
- [ ] Rollback SQL: `DROP TABLE IF EXISTS` w odwrotnej kolejności
- [ ] Event scheduler: `DELETE FROM ticket_nonces WHERE expires_at < UNIX_TIMESTAMP()`
- [ ] Event scheduler: `DELETE FROM launch_tokens WHERE expires_at < NOW()`

---

## 7. CANARY C++ — ZMIANY TICKET-GATE

### Pliki zmienione w Canary

| Plik | Zmiana |
|------|--------|
| `src/server/network/protocol/protocolgame.cpp` | 11 guardy (D2-D10) z `#ifdef TICKET_GATE` |
| `src/server/network/protocol/protocolgame.h` | Deklaracje metod ticket-gate |
| `src/security/rsa.h` | RSA → CanaryRSA (uniknięcie konfliktu z OpenSSL) |

### Flow w C++
1. `ProtocolGame::onRecvFirstMessage()` — sprawdza `TICKET_GATE` ifdef
2. Odczytuje ticket z pakietu
3. Weryfikuje HMAC-SHA256 (klucz z `HMAC_SECRET` env var)
4. Sprawdza expiry (`expires_at > now()`)
5. Sprawdza nonce (in-memory set, replay protection)
6. Jeśli OK → kontynuuje logowanie; jeśli nie → disconnect z kodem błędu

### Guardy kompilacji
```cpp
#ifdef TICKET_GATE
    // ... ticket verification code ...
#endif
```
- Domyślnie wyłączone — trzeba dodać `-DTICKET_GATE=ON` w CMake
- Pozwala na budowanie bez ticket-gate (np. testy, dev)

---

## 8. CI/CD — GITHUB ACTIONS

### Lokalizacja: `.github/workflows/` (repo root)

| Workflow | Opis | Trigger |
|----------|------|---------|
| `build-launcher.yml` | Build CLI+Tauri+Helper (Linux+Windows) | push feature/ticket-gate |
| `launcher-ci.yml` | fmt + clippy + test + contract tests | PR |
| `release-launcher.yml` | Release builds + checksums | tag |

### `build-launcher.yml` — szczegóły
```yaml
jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-22.04, windows-latest]
    steps:
      - Install Rust 1.82
      - Install Tauri system deps (Linux: libgtk-3-dev, libwebkit2gtk-4.1-dev, ...)
      - cargo clean -p launcher-tauri    # force re-embed frontend
      - Verify frontend files exist (ui/index.html)
      - cargo build --release -p launcher-cli
      - cargo build --release -p launcher-tauri
      - cargo build --release -p launcher-helper
      - zip + upload artifacts

  checksums:
    needs: build
    steps:
      - Download all artifacts
      - sha256sum + upload checksum file
```

### Znane problemy CI
- Windows: transient CDN issues z vcpkg (retry pomaga)
- Ubuntu 22.04: wymaga starszego libwebkit2gtk-4.1 (nie 4.0)
- `cargo clean -p launcher-tauri` konieczny aby przebudować embed frontend

---

## 9. FRONTEND UI — TAURI + HTML/JS

### Architektura
- Single Page App: `index.html` + `app.js` + `style.css`
- Komunikacja: `window.__TAURI__.invoke("command_name", { args })` → Rust backend
- Dark theme, responsive, 5 zakładek

### Zakładki UI

| Tab | ID | Funkcja |
|-----|-----|---------|
| Status | `tab-status` | Status serwerów (auto-refresh 30s), wersja launchera |
| Aktualizacja | `tab-update` | Sprawdź manifest → pobierz → zastosuj |
| Naprawa | `tab-repair` | Diagnoza SHA-256 → lista corrupted/missing |
| Pobieranie | `tab-download` | Download Center — lista artefaktów + verify |
| Ustawienia | `tab-settings` | Kanał, eksport logów, self-update, strona WWW |

### Kluczowe funkcje JS

```javascript
loadServerStatus()     // GET server-status → wyświetl tabelę online/offline
checkForUpdates()      // invoke("check_for_updates") → pokaż plan
startUpdate()          // invoke("start_update") → progress bar
repairInstallation()   // invoke("repair_installation") → lista plików
loadInstallerCatalog() // invoke("get_installer_catalog") → karty pobierania
```

### Auto-refresh
- `loadServerStatus()` wywoływane co 30 sekund (`setInterval`)
- Graceful error handling — tab nie crashuje gdy API niedostępne

---

## 10. OTWARTE PROBLEMY I DŁUG TECHNICZNY

### Krytyczne (blokujące produkcję)

| # | Problem | Priorytet | Plik |
|---|---------|-----------|------|
| K1 | Manifest musi mieć prawdziwe pliki klienta (7791 → trzeba wygenerować z realnego OTClient build) | P0 | `generate_manifest.php` |
| K2 | Brak DNS `api.serwercanary.pl` — potrzebny publiczny cert | P0 | nginx + certbot |
| K3 | OTClient musi obsługiwać ticket z env var | P0 | `modules/game_ticket/` |
| K4 | `TICKET_GATE` ifdef nie jest włączony w CMake Canary | P0 | CMakeLists.txt |

### Ważne (wymagane przed release)

| # | Problem | Opis |
|---|---------|------|
| W1 | SQL migration rollout/rollback (P1) | Brak automatycznych migracji |
| W2 | Testy replay/expired/clock-skew (P2) | Ticket system bez testów e2e |
| W3 | Structured logging odrzuceń (P3) | Brak metrics/alertów na odrzucone tickety |
| W4 | Runbook fresh install (P4) | Brak procedury instalacji od zera |
| W5 | Hardening packaging (P5) | Artefakty bez podpisu cyfrowego |
| W6 | apiPort/gamePort rozdzielenie (P6) | Jeden port dla API i game w config |

### Średnie (ulepszenia)

| # | Problem | Opis |
|---|---------|------|
| S1 | Progress bar w UI (update) | Brak real-time progress (TODO w `start_update`) |
| S2 | Tauri events zamiast polling | `app.emit("update-progress", ...)` |
| S3 | i18n w launcherze | 60h pracy, 5 faz (patrz osobny plan) |
| S4 | Android support | Brak — wymaga kompletnie innego podejścia |
| S5 | Logo/branding | Brak logo SerwerCanary |
| S6 | Cleanup `.env` hardcoded portów | Lepsze zarządzanie konfiguracją |

### WWW CanaryAAC — Odkrycia i zadania (2026-03-06)

| # | Problem | Priorytet | Opis |
|---|---------|-----------|------|
| W7 | **Brakujący `<div id="Loginbox">` w szablonie tibiacom** | P1 | Szablon `templates/tibiacom/index.php` NIGDY nie miał wrappera `<div id="Loginbox">`. CSS `basic.css` zawiera 13 reguł z selektorem `#Loginbox` (wymiary, pozycjonowanie login boxa). Bez wrappera login box ma 0px wymiarów — GIF-y z tekstem "You are not logged in", przycisk "Login", link "Create account" są niewidoczne. **Tymczasowy fix:** dodane fallbackowe reguły CSS z `#MenuColumn` jako rodzicem na końcu `basic.css`. **Docelowy fix:** dodać `<div id="Loginbox">` w szablonie między zamknięciem `LeftArtwork` a `LoginTop`, oraz zamykający `</div>` przed `<div id="Menu">` — z uwagą na balance div-ów. |
| W8 | **CSS case mismatch: `#LoginBox` vs `#Loginbox`** | P2 | W `basic.css` linia 290 (oryginał) miała `#LoginBox #LoginButtonContainer` (wielkie B) podczas gdy reszta reguł używa `#Loginbox` (małe b). Naprawione na `#Loginbox`. |
| W9 | **SHA256 widoczny publicznie na portalu RedDAXE** | P1 | `/reddaxe/index.php` wyświetlał `sha256` hash artefaktu launchera jako `<code class="hash">` widoczny dla WSZYSTKICH odwiedzających (gości). **Naprawione** — usunięto 3 linie HTML z sha256 display. Hash dostępny nadal przez API katalogu. |
| W10 | **i18n.js domyślny język EN zamiast PL** | P2 | `resources/i18n/i18n.js` miał 4 miejsca z fallbackiem na `'en'`. Na polskim serwerze powinien być `'pl'`. **Naprawione** — zmieniono `DEFAULT_LANG`, `resolveLanguage()`, `loadDictionary()` fallback na `'pl'`. |
| W11 | **Content strony Creatures pusty — "No Monsters on the server"** | P2 | Strona `?subtopic=creatures` wyświetla "No Monsters on the server" — brak danych monsterów w bazie `canaryaac`. Prawdopodobnie wymaga importu z plików `.xml` serwera lub z tabeli `monster_type` klasycznego serwera. |
| W12 | **Szablon tibiacom — brak `<head>` `<title>` polskich tłumaczeń** | P3 | Strona generuje tytuł "Potwory - Tibia 7.4 test" z PHP — brak server-side tłumaczeń nagłówków contentbox (`headline.php?t=Potwory`). i18n client-side nie zmienia `<title>` bo `data-i18n-title` klucz `site.title` jest ogólny. |

### Niskie (nice-to-have)

| # | Problem | Opis |
|---|---------|------|
| N1 | Telemetry dashboard | Dane zbierane ale brak UI |
| N2 | A/B rollout | Kod gotowy (`rollout_config.rs`) ale nieużywany |
| N3 | Multi-language serverlist | `serverlist_sync.rs` obsługuje ale brak danych |
| N4 | Dark/Light theme toggle | Tylko dark mode |

---

## PODSUMOWANIE METRYK

| Metryka | Wartość |
|---------|---------|
| Commity na branchu | 702 (w tym ~650 auto i18n guardian) |
| Kluczowe commity ręczne | ~52 |
| Pliki Rust (launcher) | ~35 |
| Pliki PHP (API) | ~12 |
| Linie kodu Rust | ~5000+ |
| Linie kodu PHP | ~730 |
| Tabele MySQL | 4 (launcher-specific) |
| Tauri commands | 13 |
| Unit tests | 210+ |
| Integration tests | 559 linii |
| Acceptance tests | 15 (AT-001..AT-015) |
| CI workflows | 3 |
