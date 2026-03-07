# Plan: Launcher (Rust/Tauri) — Zadania i Poprawki
**Data planu:** 2026-03-06  
**Realizacja:** 2026-03-07  
**Priorytet:** P0/P1

---

## Stan obecny (audyt 2026-03-06)

### Struktura kodu
```
launcher-rust/
├── Cargo.toml                   (workspace root)
├── apps/
│   ├── launcher-cli/            (CLI — headless launcher)
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── main.rs
│   │       ├── flow.rs
│   │       └── cli.rs
│   └── launcher-tauri/          (GUI — Tauri desktop app)
│       ├── Cargo.toml
│       ├── build.rs
│       ├── src/
│       │   ├── main.rs
│       │   ├── commands.rs      (352 linii: pre_launch, lang packs, error report)
│       │   └── state.rs
│       └── ui/
│           ├── index.html
│           └── app.js
└── crates/
    └── launcher-core/           (shared library)
        ├── Cargo.toml
        └── src/
            ├── lib.rs
            ├── state.rs
            ├── artifact_verify.rs
            ├── challenge.rs
            ├── file_index.rs
            ├── font_pack_download.rs
            ├── hmac_rotation.rs
            ├── integrity.rs
            ├── language_pack_download.rs
            ├── manifest_signature.rs
            ├── patcher.rs
            ├── planner.rs
            ├── process_runner.rs
            ├── repair.rs
            ├── self_update.rs
            ├── serverlist_sync.rs
            └── telemetry.rs
```

### Git status (canary repo, branch feature/ticket-gate)
- Commit `6421c9631`: 32 pliki launcher-rust, 4217+/155-
- Commit `8fbe846d4` (HEAD): fix CI .cargo/config.toml + cargo fmt

### Wersja
- `Cargo.toml`: `version = "1.0.0"`
- `.env LAUNCHER_VERSION`: `1.0.0`
- `tauri.conf.json`: `version = "1.0.0"`
- `ui/app.js` (mock status): `launcherVersion = "1.0.0-dev"`
- `launcher-api` user-agent: `TwoyaGra-Launcher/1.0.0`
- **Status:** wersje runtime i launcher UI/API są spójne na `1.0.0`.

---

## Aktualizacja statusu (2026-03-06 10:55)

### Zakończone
- `LAU-01`: zsynchronizowano wersje w kluczowych miejscach launchera (`Cargo.toml`, `tauri.conf.json`, UI mock status, API user-agent) z `LAUNCHER_VERSION=1.0.0`.

### W trakcie
- `LAU-02`/`LAU-03`/`LAU-04`: gotowy backend API i RedDAXE flow do testów integracyjnych launchera, ale brak pełnego smoke testu z uruchomieniem GUI launchera.

### Otwarte
- `LAU-05..LAU-16` bez zmian w tej paczce (kolejne etapy po pełnym teście GUI + ticket-gate).

---

## Zadania

### LAU-01 (P0): Zsynchronizować wersję Cargo.toml ↔ .env ✅
**Pliki:**
- `launcher-rust/Cargo.toml` → ustawić `version = "1.0.0"` (lub `0.2.0`)
- `/var/www/html/apik/v1/.env` → `LAUNCHER_VERSION` musi == Cargo.toml
- `launcher-rust/apps/launcher-tauri/Cargo.toml` — też
- `launcher-rust/apps/launcher-cli/Cargo.toml` — też

### LAU-02 (P0): Weryfikacja login flow w launcherze
**Plik:** `launcher-rust/apps/launcher-tauri/src/commands.rs`
- Komenda login → POST `/apik/v1/login.php`
- Powinno zwracać `sessionKey` + lista światów + postacie
- Sprawdzić: czy launcher poprawnie parsuje response z 2 światami
- Sprawdzić: czy launcher pokazuje wybór serwera gdy mode=all

### LAU-03 (P0): Weryfikacja account-context w launcherze
**Plik:** `launcher-rust/crates/launcher-core/src/serverlist_sync.rs`
- Po loginie → GET/POST `/apik/v1/account-context.php`
- Launcher musi wiedzieć:
  - Które serwery istnieją
  - Jakie postacie gracz ma na każdym serwerze
  - Czy może kliknąć "Graj" (ma postać) czy "Utwórz postać" (nie ma)

### LAU-04 (P0): UI — wybór serwera i postaci
**Plik:** `launcher-rust/apps/launcher-tauri/ui/app.js`
- Po zalogowaniu wyświetlić:
```
┌────────────────────────────────────────┐
│  Witaj, ptakukolo!                     │
│                                        │
│  Serwery:                              │
│  ┌──────────────────────────────────┐  │
│  │ ★ Classic 7.4  [ONLINE]         │  │
│  │   Postacie: GOD (Lv1)           │  │
│  │   [GRAJ]  [Utwórz postać]       │  │
│  ├──────────────────────────────────┤  │
│  │ ★ Modern  [ONLINE]              │  │
│  │   Postacie: Ptaku Modern (Lv8)  │  │
│  │   [GRAJ]  [Utwórz postać]       │  │
│  └──────────────────────────────────┘  │
│                                        │
│  [Moje konto]  [Ustawienia]  [Wyjdź]  │
└────────────────────────────────────────┘
```

### LAU-05 (P0): "Utwórz postać" → otwiera browser z sync tokenem
**Pliki:**
- `commands.rs` — komenda `open_create_character`
- Flow:
  1. Launcher → POST `/apik/v1/account-sync-www-token.php` → token
  2. Launcher → `open::that("https://server/account/characters/create?mode=classic74&sync_token=TOKEN")`
  3. WWW odbiera token → auto-login → formularz tworzenia postaci

### LAU-06 (P0): "GRAJ" → ticket-gate → start klienta
**Pliki:**
- `commands.rs` — komenda `launch_game`
- `launcher-core/src/process_runner.rs`
- Flow:
  1. Launcher → POST `/apik/v1/launcher-token.php` → launchToken
  2. Launcher → POST `/apik/v1/ticket.php` → ticket (z characterId + worldId)
  3. Launcher → uruchamia `otclient.exe --login-token=TICKET --host=IP --port=PORT`
  4. Klient łączy się do serwera z ticketem

### LAU-07 (P0): Blokada "GRAJ" gdy brak postaci
**Plik:** `launcher-rust/apps/launcher-tauri/ui/app.js`
- Jeśli `characters.classic74.length === 0` → przycisk "GRAJ" disabled, tooltip "Brak postaci"
- CTA: "Utwórz postać na Classic 7.4"

### LAU-08 (P1): Auto-login przy starcie launchera
**Plik:** `launcher-rust/crates/launcher-core/src/state.rs`
- Przy starcie: sprawdzić zapisane credentials
- Jeśli ważne → auto-login → od razu ekran wyboru serwera
- Jeśli expired → próba refresh → jeśli fail → ekran logowania
- **Bezpieczeństwo:** NIE zapisywać hasła plain text. Zapisać sessionKey z TTL.

### LAU-09 (P1): Rejestracja w launcherze
**Plik:** `launcher-rust/apps/launcher-tauri/ui/app.js` + `commands.rs`
- Ekran rejestracji: email, hasło, powtórz hasło
- → POST `/apik/v1/register-account.php`
- Po sukcesie → auto-login → ekran wyboru serwera
- Link: "Już masz konto? Zaloguj się"

### LAU-10 (P1): Self-update check
**Plik:** `launcher-rust/crates/launcher-core/src/self_update.rs`
- Przy starcie: GET `/apik/v1/launcher-version.php`
- Porównać z lokalną wersją Cargo → jeśli nowsza → pobierz update
- `LAUNCHER_MIN_VERSION` → jeśli launcher < min → wymuś update (blokuj start)

### LAU-11 (P1): Manifest → aktualizacja plików klienta
**Pliki:** `launcher-core/src/patcher.rs`, `manifest_signature.rs`, `planner.rs`
- GET `/apik/v1/manifests/stable/manifest.json`
- Porównać hashe lokalne vs manifest
- Pobrać zmienione pliki (delta update)
- Zweryfikować podpis manifestu (Ed25519)
- Wyświetlić progress bar

### LAU-12 (P1): i18n w launcherze
**Plik:** `launcher-rust/apps/launcher-tauri/ui/app.js`
- Już jest wsparcie dla 5 języków (pl/en/ar/he/fa)
- Sprawdzić: czy wszystkie klucze mają tłumaczenia
- Sprawdzić: czy domyślny język = PL
- Sprawdzić: czy przełączanie działa bez restartu

### LAU-13 (P1): Error reporting
**Plik:** `launcher-rust/crates/launcher-core/src/telemetry.rs`
- Błędy launchera → POST `/apik/v1/error-report.php`
- Dane: error type, stack trace, version, OS
- **BEZ:** credentials, tokens, IP (anonimizacja)

### LAU-14 (P1): launcher_config.json — poprawna konfiguracja
**Plik:** `launcher-rust/apps/launcher-tauri/launcher_config.json` (lub gdzie jest)
```json
{
  "apiBaseUrl": "https://twojserwer.pl/apik/v1",
  "manifestUrl": "https://twojserwer.pl/apik/v1/manifests/stable",
  "language": "pl",
  "updateChannel": "stable",
  "clientDir": "./client",
  "signaturePublicKey": "..."
}
```
- Sprawdzić: czy URL-e wskazują na prawdziwy serwer (nie localhost w produkcji)

### LAU-15 (P2): Kompilacja launchera
**Workflow:** `build-launcher.yml` w GHA
- Linux: `launcher-cli` + `launcher-tauri`
- Windows: `launcher-cli.exe` + `launcher-tauri.exe` (+ `WebView2Loader.dll`)
- Test: czy zbudowany launcher uruchamia się na czystym Windows

### LAU-16 (P2): Smoke test na czystym Windows
1. Rozpakuj ZIP z launcherem
2. Uruchom launcher.exe
3. Ekran logowania → zaloguj
4. Widzi serwery → widzi postacie
5. "GRAJ" → klient się uruchamia
6. "Utwórz postać" → otwiera przeglądarkę → działa

---

## Matryca testów Launcher

| # | Test | Oczekiwany wynik | Status |
|---|---|---|---|
| T-LAU-01 | Login w launcherze | sessionKey + lista serwerów | ⬜ |
| T-LAU-02 | Account context po loginie | Postacie per serwer | ⬜ |
| T-LAU-03 | "GRAJ" Classic → klient startuje | OTClient uruchomiony z ticketem | ⬜ |
| T-LAU-04 | "GRAJ" Modern → klient startuje | OTClient uruchomiony z ticketem | ⬜ |
| T-LAU-05 | "GRAJ" bez postaci → zablokowane | Button disabled + komunikat | ⬜ |
| T-LAU-06 | "Utwórz postać" → browser | Browser otwiera www z sync tokenem | ⬜ |
| T-LAU-07 | Self-update check | Wykrywa nową wersję | ⬜ |
| T-LAU-08 | Manifest diff → update 1 pliku | Pobiera tylko zmieniony plik | ⬜ |
| T-LAU-09 | Auto-login po restarcie | Bez ekranu logowania | ⬜ |
| T-LAU-10 | Rejestracja w launcherze | Nowe konto + auto-login | ⬜ |
| T-LAU-11 | i18n PL w launcherze | Wszystkie teksty po polsku | ⬜ |
| T-LAU-12 | Error report | POST do API z danymi błędu | ⬜ |

---

# CZĘŚĆ 2: Lekki Launcher Bootstrap — Dwupoziomowy System Dystrybucji

**Data dopisania:** 2026-03-07  
**Priorytet:** P0/P1  
**Szczegółowy plan:** `25_PLAN_LEKKI_LAUNCHER_BOOTSTRAP.md`

---

## Koncepcja — 3 warstwy dystrybucji

```
WARSTWA 1: Lekki Launcher (Bootstrap)
  - Rozmiar: kilka KB (jak plik .torrent)
  - Pobierany ze strony www/reddaxe
  - Jedyne zadanie: pobrać i zainstalować pełny launcher
  - Minimalistyczny GUI (progress bar, ewentualnie logo)

WARSTWA 2: Pełny Launcher (Rust/Tauri) — obecny LAU-01..LAU-16
  - Rozmiar: ~5-20 MB
  - Pobierany przez lekki launcher z bazy artefaktów API
  - Pełnoprawny launcher: login, aktualizacje, ticket-gate, start klienta, i18n

WARSTWA 3: Klient gry (OTClient + dane)
  - Rozmiar: ~100-500 MB
  - Pobierany przez pełny launcher z manifestu API
  - Właściwa gra
```

### Flow użytkownika

```
[1] Gracz wchodzi na www/reddaxe → klika "Pobierz grę"
        ▼
[2] Pobiera lekki launcher (~50-200 KB)
        ▼
[3] Uruchamia lekki launcher
        ▼
[4] Lekki launcher:
    a. GET /apik/v1/installer-catalog.php?channel=stable&type=launcher
    b. Sprawdza platform/arch
    c. Pobiera pełny launcher (~5-20 MB) z progress barem
    d. Weryfikuje SHA-256
    e. Rozpakowuje do docelowego katalogu
    f. Tworzy launcher_config.json
    g. Tworzy skrót na pulpicie (opcjonalnie)
    h. Uruchamia pełny launcher
    i. Zamyka się (jednorazowe użycie)
        ▼
[5] Pełny launcher startuje (flow LAU-01..LAU-16):
    a. Self-update check
    b. Login/rejestracja
    c. Pobiera klienta gry z manifestu (~100-500 MB)
    d. Gracz gra
```

---

## Struktura kodu lekkiego launchera

```
launcher-rust/
├── apps/
│   ├── launcher-bootstrap/          ← NOWY
│   │   ├── Cargo.toml
│   │   ├── build.rs                 (ikona, manifest Windows)
│   │   └── src/
│   │       ├── main.rs              (entry point + orchestracja)
│   │       ├── downloader.rs        (HTTP GET + progress + SHA-256)
│   │       ├── installer.rs         (rozpakowanie, config, skrót)
│   │       ├── platform.rs          (Windows/Linux detekcja)
│   │       └── ui.rs                (minimal GUI: okno + progress bar)
│   ├── launcher-cli/
│   └── launcher-tauri/
```

---

## Zadania — Lekki Launcher Bootstrap

### FAZA A: Kod lekkiego launchera

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-01 | Utworzyć strukturę katalogu `launcher-bootstrap` | P0 | `apps/launcher-bootstrap/` z Cargo.toml, src/main.rs | ✅ |
| BL-02 | Implementacja `downloader.rs` | P0 | HTTP GET z progress callback, SHA-256 verify, retry 3x | ✅ |
| BL-03 | Implementacja `installer.rs` | P0 | Rozpakowanie ZIP, utworzenie katalogu, zapis config JSON | ✅ |
| BL-04 | Implementacja `platform.rs` | P0 | Detekcja OS/arch, ścieżka docelowa instalacji | ✅ |
| BL-05 | Implementacja `ui.rs` (Windows) | P1 | Minimalne okno Win32: logo + progress bar + tekst statusu | ✅ (faza 1: console + MessageBox) |
| BL-06 | Implementacja `ui.rs` (Linux) | P1 | TUI lub GTK minimal: progress bar + tekst statusu | ✅ (faza 1: console) |
| BL-07 | Implementacja `main.rs` | P0 | Orchestracja: katalog → fetch catalog → download → verify → install → launch | ✅ |
| BL-08 | Cargo.toml z optymalizacją rozmiaru | P0 | `opt-level=z, lto=true, strip=true, panic=abort` | ✅ (workspace profile) |
| BL-09 | Profil release — weryfikacja rozmiaru < 500 KB | P0 | Sprawdzić czy exe mieści się w limicie | ⬜ |
| BL-10 | Obsługa błędów i komunikaty użytkownika | P1 | Brak internetu, timeout, zły hash, brak miejsca, brak uprawnień | ✅ |

### FAZA B: Workflow GHA

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-11 | Utworzyć workflow `build-bootstrap-launcher.yml` | P0 | Build Windows + Linux, upload artefaktu | ⬜ |
| BL-12 | Dodać krok weryfikacji rozmiaru w workflow | P0 | `if size > 512KB then WARNING` | ⬜ |
| BL-13 | Dodać krok SHA-256 hash w workflow | P1 | Generowanie pliku `.sha256` obok artefaktu | ⬜ |
| BL-14 | Test smoke w workflow (opcjonalnie) | P2 | Uruchom bootstrap z mock API → sprawdź exit code | ⬜ |

### FAZA C: API — rozszerzenie installer-catalog

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-15 | Rozszerzyć `installer-catalog.php` o parametr `type` | P0 | `type=launcher` filtruje artefakty per typ | ✅ |
| BL-16 | Dodać wpisy pełnego launchera do katalogu API | P0 | Po buildzie: wersja, SHA-256, URL, rozmiar | ⬜ |
| BL-17 | Utworzyć skrypt deploy do publikacji artefaktów | P1 | Skrypt pobiera artefakt z GHA → upload na serwer → update katalogu | ⬜ |
| BL-18 | Endpoint health-check artefaktów | P2 | Sprawdzenie czy pliki w katalogu istnieją i mają poprawny hash | ⬜ |

### FAZA D: RedDAXE/WWW — strona pobierania

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-19 | Przygotować folder `reddaxe/downloads/` na lekki launcher | P0 | Katalog + link do pobrania | ⬜ |
| BL-20 | Zaktualizować przycisk "Pobierz grę" na RedDAXE | P0 | Link do lekkiego launchera zamiast pełnego ZIP | ⬜ |
| BL-21 | Dodać alternatywny link "Wersja portable" | P1 | Dla zaawansowanych: pełny launcher ZIP bez bootstrapa | ⬜ |
| BL-22 | i18n dla strony pobierania (PL/EN) | P1 | Tłumaczenia przycisków i opisu | ⬜ |
| BL-23 | Dodać info o rozmiarze i co robi lekki launcher | P1 | "Pobierz (~200 KB) — automatycznie zainstaluje pełną wersję" | ⬜ |

### FAZA E: Integracja i testy

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-24 | Test E2E: bootstrap → pełny launcher → klient | P0 | Cała ścieżka od pobrania do gry | ⬜ |
| BL-25 | Test: brak internetu → czytelny komunikat | P1 | Bootstrap nie crashuje, pokazuje błąd | ⬜ |
| BL-26 | Test: zły hash artefaktu → odmowa instalacji | P0 | SHA-256 mismatch → "Plik uszkodzony, spróbuj ponownie" | ⬜ |
| BL-27 | Test: już zainstalowany pełny launcher → detekcja | P1 | Bootstrap wykrywa istniejący launcher i pyta o akcję | ⬜ |
| BL-28 | Test: Windows 10/11 bez admina | P0 | Bootstrap instaluje w folderze usera bez UAC | ⬜ |
| BL-29 | Test: antywirusy (Windows Defender) | P2 | Brak false positive lub instrukcja wyłączenia | ⬜ |

### FAZA F: Dokumentacja i kontrakty

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-30 | Zaktualizować kontrakt `installer-bootstrap.md` | P0 | Nowy model: lekki launcher zamiast 10-50 MB instalatora | ⬜ |
| BL-31 | Zaktualizować kontrakt `installer-catalog.md` | P0 | Parametr `type`, nowe wpisy w katalogu | ⬜ |
| BL-32 | Dodać ADR: decyzja o dwupoziomowej dystrybucji | P1 | Dlaczego lekki launcher, jakie alternatywy rozpatrzono | ⬜ |
| BL-33 | Zaktualizować README launchera | P1 | Opis nowej architektury 3-warstwowej | ⬜ |

---

## Kolejność realizacji

### Etap 1 — Fundament (BL-01..BL-09)
1. `BL-01`: Struktura katalogu
2. `BL-08`: Cargo.toml z optymalizacją
3. `BL-04`: Detekcja platformy
4. `BL-02`: Downloader (HTTP + SHA-256)
5. `BL-03`: Installer (ZIP + config)
6. `BL-07`: Main (orchestracja)
7. `BL-09`: Weryfikacja rozmiaru

### Etap 2 — GUI minimalne (BL-05, BL-06, BL-10)
1. `BL-05`: Win32 GUI
2. `BL-06`: Linux GUI
3. `BL-10`: Obsługa błędów

### Etap 3 — API (BL-15..BL-18)
1. `BL-15`: Rozszerzenie installer-catalog.php
2. `BL-16`: Wpisy launchera w katalogu

### Etap 4 — Workflow GHA (BL-11..BL-14)
1. `BL-11`: Workflow YAML
2. `BL-12`: Weryfikacja rozmiaru

### Etap 5 — WWW/RedDAXE (BL-19..BL-23)
1. `BL-19..BL-23`: Strona pobierania

### Etap 6 — Testy i dokumentacja (BL-24..BL-33)
1. `BL-24`: E2E pełna ścieżka
2. `BL-30..BL-31`: Kontrakty

---

## Matryca testów Bootstrap

| # | Test | Oczekiwany wynik | Status |
|---|------|------------------|--------|
| T-BL-01 | Rozmiar exe < 500 KB | PASS | ⬜ |
| T-BL-02 | Bootstrap pobiera pełny launcher | Pobrany + rozpakowany | ⬜ |
| T-BL-03 | SHA-256 weryfikacja PASS | Instalacja kontynuuje | ⬜ |
| T-BL-04 | SHA-256 weryfikacja FAIL | Odmowa + komunikat | ⬜ |
| T-BL-05 | Brak internetu | Czytelny błąd | ⬜ |
| T-BL-06 | Pełny launcher startuje po instalacji | Okno launchera widoczne | ⬜ |
| T-BL-07 | Bez admina na Windows 10 | Działa z folderu usera | ⬜ |
| T-BL-08 | Istniejący launcher → detekcja | Pytanie o nadpisanie | ⬜ |
| T-BL-09 | GHA workflow buduje artefakt | Artefakt w releases | ⬜ |
| T-BL-10 | E2E: bootstrap → launcher → klient → gra | Gracz wchodzi do gry | ⬜ |
