# Plan: Lekki Launcher (Bootstrap) — Dwupoziomowy System Dystrybucji

**Data planu:** 2026-03-07  
**Priorytet:** P0/P1  
**Dotyczy:** Nowy lekki launcher bootstrap + pelny launcher Rust/Tauri + workflow GHA + API + RedDAXE/WWW

---

## 1. Koncepcja

Zamiast jednego duzego launchera do pobrania ze strony, system dystrybucji ma 3 warstwy:

```
WARSTWA 1: Lekki Launcher (Bootstrap)
  - Rozmiar: kilka KB (jak plik .torrent)
  - Pobierany ze strony www/reddaxe
  - Jedyne zadanie: pobrac i zainstalowac pelny launcher
  - Minimalistyczny GUI (progress bar, ewentualnie logo)

WARSTWA 2: Pelny Launcher (Rust/Tauri)
  - Rozmiar: ~5-20 MB
  - Pobierany przez lekki launcher z bazy artefaktow API
  - Pelnoprawny launcher: login, aktualizacje, ticket-gate, start klienta, i18n

WARSTWA 3: Klient gry (OTClient + dane)
  - Rozmiar: ~100-500 MB
  - Pobierany przez pelny launcher z manifestu API
  - Wlasciwa gra
```

### Flow uzytkownika

```
[1] Gracz wchodzi na www/reddaxe → klika "Pobierz grę"
        │
        ▼
[2] Pobiera lekki launcher (~50-200 KB)
        │
        ▼
[3] Uruchamia lekki launcher
        │
        ▼
[4] Lekki launcher:
    a. GET /apik/v1/installer-catalog.php?channel=stable&type=launcher
    b. Sprawdza platform/arch
    c. Pobiera pelny launcher (~5-20 MB) z progress barem
    d. Weryfikuje SHA-256
    e. Rozpakowuje do docelowego katalogu
    f. Tworzy launcher_config.json
    g. Tworzy skrot na pulpicie (opcjonalnie)
    h. Uruchamia pelny launcher
    i. Zamyka sie (jednorazowe uzycie)
        │
        ▼
[5] Pelny launcher startuje:
    a. Self-update check
    b. Login/rejestracja
    c. Pobiera klienta gry z manifestu (~100-500 MB)
    d. Gracz gra
```

### Diagram artefaktow

```
┌─────────────────────────────────┐
│       www/reddaxe               │
│  ┌───────────────────────┐      │
│  │ [Pobierz grę]         │      │
│  │  → lekki-launcher.exe │      │
│  │    (~50-200 KB)        │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│  API: installer-catalog.php     │
│  ┌───────────────────────┐      │
│  │ Pelny launcher        │      │
│  │  launcher-tauri.exe    │      │
│  │  (~5-20 MB)            │      │
│  └───────────────────────┘      │
│  ┌───────────────────────┐      │
│  │ Klient gry            │      │
│  │  otclient.exe + data/  │      │
│  │  (~100-500 MB)         │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
```

---

## 2. Architektura lekkiego launchera

### Technologia

| Opcja | Jezyk | Rozmiar exe | Zalety | Wady |
|-------|-------|-------------|--------|------|
| **A. Rust (bez GUI frameworka)** | Rust | ~100-300 KB | Maly, szybki, bez runtime | Brak natywnego GUI |
| **B. Rust + ratatui (TUI)** | Rust | ~200-400 KB | Terminal UI z progress barem | Wyglada terminalowo |
| **C. Rust + minimalny Win32 API** | Rust | ~100-200 KB | Natywne okno Windows | Wiecej kodu, platform-specific |
| **D. Rust + iced (minimal GUI)** | Rust | ~1-3 MB | Ladny GUI cross-platform | Wiekszy niz minimum |
| **E. C (raw Win32 + libcurl)** | C | ~50-100 KB | Najmniejszy mozliwy | Trudniejszy w utrzymaniu |

**Rekomendacja:** Opcja A lub C — Rust z minimalnym natywnym oknem Windows (MessageBox + progress bar). Na Linuxie analogicznie z GTK lub TUI. Cel: ponizej 500 KB.

### Struktura kodu lekkiego launchera

```
launcher-rust/
├── apps/
│   ├── launcher-bootstrap/          ← NOWY
│   │   ├── Cargo.toml
│   │   ├── build.rs                 (ikona, manifest Windows)
│   │   └── src/
│   │       ├── main.rs              (entry point)
│   │       ├── downloader.rs        (HTTP GET + progress + SHA-256)
│   │       ├── installer.rs         (rozpakowanie, config, skrot)
│   │       ├── platform.rs          (Windows/Linux detekcja)
│   │       └── ui.rs                (minimal GUI: okno + progress bar)
│   ├── launcher-cli/
│   └── launcher-tauri/
```

### Cargo.toml (bootstrap)

```toml
[package]
name = "launcher-bootstrap"
version = "1.0.0"
edition = "2021"

[dependencies]
reqwest = { version = "0.12", features = ["blocking", "rustls-tls"], default-features = false }
sha2 = "0.10"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
zip = "2"

# Minimalizacja rozmiaru:
[profile.release]
opt-level = "z"       # optymalizacja na rozmiar
lto = true            # link-time optimization
codegen-units = 1     # lepsza optymalizacja
panic = "abort"       # mniej kodu paniki
strip = true          # usun symbole debug
```

### Minimalne API lekkiego launchera

Lekki launcher potrzebuje JEDNEGO endpointu:

```
GET /apik/v1/installer-catalog.php?channel=stable&type=launcher
```

Response (z istniejacego kontraktu LR-004, rozszerzony o type):

```json
{
  "channel": "stable",
  "version": "1.0.0",
  "artifacts": [
    {
      "platform": "windows",
      "arch": "x86_64",
      "filename": "launcher-tauri-1.0.0-win64.zip",
      "url": "https://api.serwer.pl/releases/launcher-tauri-1.0.0-win64.zip",
      "sha256": "abc123...",
      "size": 15000000,
      "type": "launcher"
    },
    {
      "platform": "linux",
      "arch": "x86_64",
      "filename": "launcher-tauri-1.0.0-linux.tar.gz",
      "url": "https://api.serwer.pl/releases/launcher-tauri-1.0.0-linux.tar.gz",
      "sha256": "def456...",
      "size": 12000000,
      "type": "launcher"
    }
  ]
}
```

---

## 3. Workflow GHA — kompilacja lekkiego launchera

### Nowy workflow: `build-bootstrap-launcher.yml`

```yaml
name: Build Bootstrap Launcher
on:
  workflow_dispatch:
  push:
    paths:
      - 'launcher-rust/apps/launcher-bootstrap/**'
    branches: [master]

jobs:
  build-bootstrap-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - name: Build bootstrap (release, minimized)
        run: cargo build --release --manifest-path launcher-rust/apps/launcher-bootstrap/Cargo.toml
      - name: Check size
        run: |
          $size = (Get-Item target/release/launcher-bootstrap.exe).Length
          echo "Bootstrap size: $size bytes ($([math]::Round($size/1024, 1)) KB)"
          if ($size -gt 524288) { echo "WARNING: > 512 KB!" }
      - uses: actions/upload-artifact@v4
        with:
          name: bootstrap-launcher-windows
          path: target/release/launcher-bootstrap.exe

  build-bootstrap-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - name: Build bootstrap (release, minimized)
        run: cargo build --release --manifest-path launcher-rust/apps/launcher-bootstrap/Cargo.toml
      - name: Check size
        run: |
          SIZE=$(stat -c%s target/release/launcher-bootstrap)
          echo "Bootstrap size: $SIZE bytes ($((SIZE/1024)) KB)"
          if [ "$SIZE" -gt 524288 ]; then echo "WARNING: > 512 KB!"; fi
      - uses: actions/upload-artifact@v4
        with:
          name: bootstrap-launcher-linux
          path: target/release/launcher-bootstrap
```

### Istniejacy workflow `build-launcher.yml` — bez zmian

Pelny launcher (Tauri) budowany jest jak dotychczas. Po zbudowaniu artefakt jest umieszczany w bazie artefaktow API.

---

## 4. Publikacja artefaktow

### Gdzie co lezy

| Artefakt | Gdzie jest do pobrania | Kto wrzuca |
|----------|------------------------|------------|
| Lekki launcher (.exe / binary) | www/reddaxe — strona "Pobierz gre" | Deploy po GHA build |
| Pelny launcher (ZIP) | API: `installer-catalog.php` → URL do pliku na serwerze | Deploy po GHA build |
| Klient gry (pliki) | API: `update.php` → manifest z URLami plikow | Deploy po GHA build klienta |

### Flow publikacji

```
1. GHA buduje lekki launcher → artefakt bootstrap-launcher-windows
2. Pobranie artefaktu z GHA → upload na serwer WWW do folderu reddaxe/downloads/
3. Strona RedDAXE wskazuje link do pobrania lekkiego launchera

4. GHA buduje pelny launcher → artefakt launcher-tauri-windows  
5. Pobranie artefaktu z GHA → upload na serwer API do folderu releases/
6. Aktualizacja installer-catalog.php (wersja, SHA-256, URL)

7. GHA buduje klienta → artefakt client-package
8. Pobranie artefaktu z GHA → upload na serwer API do folderu client-files/
9. Generowanie nowego manifestu (generate_manifest.php)
```

---

## 5. Modyfikacje istniejacego kodu/API

### 5.1 installer-catalog.php — rozszerzenie

Dodac parametr `type` do endpointu:
- `type=launcher` — zwraca artefakty pelnego launchera (dla lekkiego launchera)
- `type=installer` — zwraca artefakty instalatora (jak dotychczas)
- `type=all` — zwraca wszystko (domyslne, backward compatible)

### 5.2 RedDAXE/WWW — nowy przycisk pobierania

Zamiast linkowania do pelnego launchera/ZIP, strona pobran wskazuje na lekki launcher:
- Przycisk "Pobierz gre" → `reddaxe/downloads/launcher-bootstrap.exe` (~200 KB)
- Dodatkowy link "Wersja portable (pelny launcher)" → ZIP z pelnym launcherem (~5 MB)

### 5.3 launcher_config.json — tworzony przez lekki launcher

Lekki launcher po zainstalowaniu pelnego launchera tworzy config:
```json
{
  "apiBaseUrl": "https://twojserwer.pl/apik/v1",
  "channel": "stable",
  "launcher_version_check": true,
  "client_dir": "client",
  "launcher_data_dir": "launcher_data",
  "installed_by_bootstrap": true,
  "bootstrap_version": "1.0.0"
}
```

---

## 6. Zadania — lista krok po kroku

### FAZA A: Przygotowanie kodu lekkiego launchera

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-01 | Utworzyc strukture katalogu `launcher-bootstrap` | P0 | `apps/launcher-bootstrap/` z Cargo.toml, src/main.rs | ✅ |
| BL-02 | Implementacja `downloader.rs` | P0 | HTTP GET z progress callback, SHA-256 verify, retry 3x | ✅ |
| BL-03 | Implementacja `installer.rs` | P0 | Rozpakowanie ZIP, utworzenie katalogu, zapis config JSON | ✅ |
| BL-04 | Implementacja `platform.rs` | P0 | Detekcja OS/arch, sciezka docelowa instalacji | ✅ |
| BL-05 | Implementacja `ui.rs` (Windows) | P1 | Minimalne okno Win32: logo + progress bar + tekst statusu | ✅ (faza 1: console + MessageBox) |
| BL-06 | Implementacja `ui.rs` (Linux) | P1 | TUI lub GTK minimal: progress bar + tekst statusu | ✅ (faza 1: console) |
| BL-07 | Implementacja `main.rs` | P0 | Orchestracja: katalog → fetch catalog → download → verify → install → launch | ✅ |
| BL-08 | Cargo.toml z optymalizacja rozmiaru | P0 | `opt-level=z, lto=true, strip=true, panic=abort` | ✅ (workspace profile) |
| BL-09 | Profil release — weryfikacja rozmiaru < 500 KB | P0 | Sprawdzic czy exe miesci sie w limicie | ⬜ |
| BL-10 | Obsluga bledow i komunikaty uzytkownika | P1 | Brak internetu, timeout, zly hash, brak miejsca, brak uprawnien | ✅ |

### FAZA B: Workflow GHA

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-11 | Utworzyc workflow `build-bootstrap-launcher.yml` | P0 | Budget Windows + Linux, upload artefaktu | ⬜ |
| BL-12 | Dodac krok weryfikacji rozmiaru w workflow | P0 | `if size > 512KB then WARNING` | ⬜ |
| BL-13 | Dodac krok SHA-256 hash w workflow | P1 | Generowanie pliku `.sha256` obok artefaktu | ⬜ |
| BL-14 | Test smoke w workflow (opcjonalnie) | P2 | Uruchom bootstrap z mock API → sprawdz exit code | ⬜ |

### FAZA C: API — rozszerzenie installer-catalog

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-15 | Rozszerzyc `installer-catalog.php` o parametr `type` | P0 | `type=launcher` filtruje artefakty per typ | ✅ |
| BL-16 | Dodac wpisy pelnego launchera do katalogu API | P0 | Po buildzie: wersja, SHA-256, URL, rozmiar | ⬜ |
| BL-17 | Utworzyc skrypt deploy do publikacji artefaktow | P1 | Skrypt pobiera artefakt z GHA → upload na serwer → update katalogu | ⬜ |
| BL-18 | Endpoint health-check artefaktow | P2 | Sprawdzenie czy pliki w katalogu istnieja i maja poprawny hash | ⬜ |

### FAZA D: RedDAXE/WWW — strona pobierania

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-19 | Przygotowac folder `reddaxe/downloads/` na lekki launcher | P0 | Katalog + prosty index z linkiem do pobrania | ⬜ |
| BL-20 | Zaktualizowac przycisk "Pobierz gre" na RedDAXE | P0 | Link do lekkiego launchera zamiast pelnego ZIP | ⬜ |
| BL-21 | Dodac alternatywny link "Wersja portable" | P1 | Dla zaawansowanych: pelny launcher ZIP bez bootstrapa | ⬜ |
| BL-22 | i18n dla strony pobierania (PL/EN) | P1 | Tlumaczenia przyciskow i opisu | ⬜ |
| BL-23 | Dodac info o rozmiarze i co robi lekki launcher | P1 | "Pobierz (~200 KB) — automatycznie zainstaluje pelna wersje" | ⬜ |

### FAZA E: Integracja i testy

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-24 | Test E2E: bootstrap → pelny launcher → klient | P0 | Cala sciezka od pobrania do gry | ⬜ |
| BL-25 | Test: brak internetu → czytelny komunikat | P1 | Bootstrap nie crashuje, pokazuje blad | ⬜ |
| BL-26 | Test: zly hash artefaktu → odmowa instalacji | P0 | SHA-256 mismatch → "Plik uszkodzony, sprobuj ponownie" | ⬜ |
| BL-27 | Test: juz zainstalowany pelny launcher → detekcja | P1 | Bootstrap wykrywa istniejacy launcher i pyta o akcje | ⬜ |
| BL-28 | Test: Windows 10/11 bez admina | P0 | Bootstrap instaluje w folderze usera bez UAC | ⬜ |
| BL-29 | Test: antywirusy (Windows Defender) | P2 | Brak false positive lub instrukcja wyłączenia | ⬜ |

### FAZA F: Dokumentacja i kontrakty

| ID | Zadanie | Priorytet | Opis | Status |
|----|---------|-----------|------|--------|
| BL-30 | Zaktualizowac kontrakt `installer-bootstrap.md` | P0 | Nowy model: lekki launcher zamiast 10-50 MB instalatora | ⬜ |
| BL-31 | Zaktualizowac kontrakt `installer-catalog.md` | P0 | Parametr `type`, nowe wpisy w katalogu | ⬜ |
| BL-32 | Dodac ADR: decyzja o dwupoziomowej dystrybucji | P1 | Dlaczego lekki launcher, jakie alternatywy rozpatrzono | ⬜ |
| BL-33 | Zaktualizowac README launchera | P1 | Opis nowej architektury 3-warstwowej | ⬜ |

---

## 7. Kolejnosc realizacji

### Etap 1 — Fundament (BL-01..BL-09)
Cel: kompilujacy sie lekki launcher w Rust, ktory pobiera pelny launcher z testowego URL i instaluje go.

1. `BL-01`: Struktura katalogu
2. `BL-08`: Cargo.toml z optymalizacja
3. `BL-04`: Detekcja platformy
4. `BL-02`: Downloader (HTTP + SHA-256)
5. `BL-03`: Installer (ZIP + config)
6. `BL-07`: Main (orchestracja)
7. `BL-09`: Weryfikacja rozmiaru

### Etap 2 — GUI minimalne (BL-05, BL-06, BL-10)
Cel: lekki launcher z minimalnym GUI (okno z progress barem).

1. `BL-05`: Win32 GUI
2. `BL-06`: Linux GUI
3. `BL-10`: Obsluga bledow

### Etap 3 — API i publikacja (BL-15..BL-18)
Cel: API zwraca artefakty pelnego launchera, lekki launcher wie skad pobrac.

1. `BL-15`: Rozszerzenie installer-catalog.php
2. `BL-16`: Wpisy launchera w katalogu
3. `BL-17`: Skrypt deploy
4. `BL-18`: Health-check

### Etap 4 — Workflow GHA (BL-11..BL-14)
Cel: automatyczna kompilacja lekkiego launchera na GHA.

1. `BL-11`: Workflow YAML
2. `BL-12`: Weryfikacja rozmiaru
3. `BL-13`: SHA-256 hash
4. `BL-14`: Smoke test

### Etap 5 — WWW/RedDAXE (BL-19..BL-23)
Cel: strona pobierania wskazuje na lekki launcher.

1. `BL-19`: Folder downloads
2. `BL-20`: Przycisk "Pobierz gre"
3. `BL-21`: Link portable
4. `BL-22`: i18n
5. `BL-23`: Info o rozmiarze

### Etap 6 — Testy i dokumentacja (BL-24..BL-33)
Cel: cala sciezka przetestowana E2E, kontrakty zaktualizowane.

1. `BL-24`: E2E pelna sciezka
2. `BL-26`: SHA-256 mismatch
3. `BL-28`: Windows bez admina
4. `BL-30..BL-31`: Kontrakty
5. Reszta BL-25, BL-27, BL-29, BL-32, BL-33

---

## 8. Wymagania bezpieczenstwa

1. Lekki launcher musi komunikowac sie TYLKO przez HTTPS.
2. Weryfikacja SHA-256 jest OBOWIAZKOWA przed rozpakowaniem artefaktu.
3. Lekki launcher NIE przechowuje zadnych credentials ani tokenow.
4. Lekki launcher NIE ma dostepu do klienta gry ani do danych gracza — to rola pelnego launchera.
5. URL API jest wbudowany w binarke lekkiego launchera (nie konfigurowalny przez uzytkownika).
6. Lekki launcher MUSI odmowic dzialania jesli nie ma dostepu do internetu.
7. Lekki launcher MUSI pokazac czytelny blad jesli hash nie zgadza sie.
8. Lekki launcher NIE powinien wymagac uprawnien administratora.

---

## 9. Kryteria sukcesu

1. Skompilowany lekki launcher wazy < 500 KB (cel: < 300 KB).
2. Lekki launcher pobiera i instaluje pelny launcher w < 60 sekund na laczu 10 Mbps.
3. Po instalacji pelny launcher startuje automatycznie.
4. Gracz nie musi robic NIC oprócz: pobierz → uruchom → czekaj → graj.
5. Cala sciezka bootstrap → pelny launcher → klient dziala E2E.
6. Lekki launcher jest jednorazowy — po instalacji pelnego launchera nie jest juz potrzebny.

---

## 10. Relacja z istniejacymi dokumentami

| Dokument | Co sie zmienia |
|----------|----------------|
| `installer-bootstrap.md` (kontrakt LR-041) | Nowy model: lekki launcher (~KB) zamiast stalego instalatora (~10-50 MB) |
| `installer-catalog.md` (kontrakt LR-004) | Parametr `type=launcher` i nowe wpisy w katalogu |
| `14_PLAN_LAUNCHER_TAURI_RUST.md` | Nowy app `launcher-bootstrap` w workspace |
| `15_PLAN_INSTALKA_KLIENT_PACZKA.md` | Flow pobierania zaczyna sie od lekkiego launchera |
| `master_backlog_caly_system.md` | Nowy sub-track w TRACK D lub TRACK E |
| `podsumowanie_zadan_niedokonczonych` | Nowe zadania BL-01..BL-33 |

---

## 11. Matryca testow bootstrap

| # | Test | Oczekiwany wynik | Status |
|---|------|------------------|--------|
| T-BL-01 | Rozmiar exe < 500 KB | PASS | ⬜ |
| T-BL-02 | Bootstrap pobiera pelny launcher | Pobrany + rozpakowany | ⬜ |
| T-BL-03 | SHA-256 weryfikacja PASS | Instalacja kontynuuje | ⬜ |
| T-BL-04 | SHA-256 weryfikacja FAIL | Odmowa + komunikat | ⬜ |
| T-BL-05 | Brak internetu | Czytelny blad | ⬜ |
| T-BL-06 | Pelny launcher startuje po instalacji | Okno launchera widoczne | ⬜ |
| T-BL-07 | Bez admina na Windows 10 | Dziala z folderu usera | ⬜ |
| T-BL-08 | Istniejacy launcher → detekcja | Pytanie o nadpisanie | ⬜ |
| T-BL-09 | GHA workflow buduje artefakt | Artefakt w releases | ⬜ |
| T-BL-10 | E2E: bootstrap → launcher → klient → gra | Gracz wchodzi do gry | ⬜ |
