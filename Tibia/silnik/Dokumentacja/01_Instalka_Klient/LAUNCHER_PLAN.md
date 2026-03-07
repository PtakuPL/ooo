# Launcher Rust — Master Plan do Kompilacji GHA

> **Data:** 2026-03-07 | **Aktualizacja:** 2026-03-07 (BL done + CZĘŚĆ 3 + FAZA O: admin serwery + FAZA P: C++ hardening)  
> **Cel:** Launcher + Bootstrap + Instalka — kompletny system dystrybucji: update → integrity → GRAJ → (OTClient: login → play)  
> **Repo:** `PtakuPL/ooo` branch `feature/ticket-gate`  
> **Workspace:** `/home/ptaku/serweryt/Tibia/silnik/launcher-rust/`

---

## Stan Obecny

### Co działa
- **6 workspace members**: common-models, launcher-api, launcher-core, launcher-helper, launcher-cli, launcher-tauri
- **Core crates kompilują** (`cargo check` OK dla common-models, launcher-api, launcher-core, launcher-helper, launcher-cli)
- **Testy**: 183 pass, 5 fail (1 config default, 4 font-pack TLS w testach)
- **Tauri v2** z CSP, frontendem HTML/JS/CSS, i18n (5 języków)
- **Ikony**: 32x32.png, 128x128.png, icon.ico
- **Dokumentacja kontraktów**: 14 plików w `docs/contracts/`
- **Tauri app** nie kompiluje lokalnie (brakuje `libgio-2.0-dev` i powiązanych GTK libs)

### Istniejące Workflows GHA ✅
Trzy launcher workflows **istnieją już** w `.github/workflows/`:

| Workflow | Plik | Trigger | Opis |
|----------|------|---------|------|
| **Launcher CI** | `launcher-ci.yml` | push/PR na `feature/ticket-gate`, paths `Tibia/silnik/launcher-rust/**` | fmt + clippy + test (matrix Ubuntu+Windows) + contract tests |
| **Build Launcher** | `build-launcher.yml` | push na `feature/ticket-gate` + manual dispatch | Release build CLI+Tauri+Helper (Linux+Windows), artifacts + SHA-256 checksums |
| **Release Launcher** | `release-launcher.yml` | tag `v*` | Full release: build → checksums → installer-catalog.json → GitHub Release → smoke check |

### Co brakuje
- **5 failing testów** do naprawienia (L-01, L-02)
- **`[profile.release]`** w Cargo.toml — brak optymalizacji rozmiaru (L-08)
- **Ed25519 placeholder** — `manifest_signature.rs` to mock (SHA-256 zamiast prawdziwego ed25519)
- **Server status hardcoded** w app.js (placeholder)

---

## Architektura Binarki

```
Launcher (Tauri v2) ≈ 3-5 MB
├── Rust backend (commands.rs, state.rs)
│   ├── common-models (DTOs, validation)
│   ├── launcher-api (reqwest/rustls HTTP client)
│   ├── launcher-core (17 modułów logiki)
│   └── launcher-helper (self-update binary)
└── Frontend (HTML/JS/CSS) ≈ 100KB
    ├── app.js (1605 linii)
    ├── style.css
    ├── index.html
    └── i18n/ (pl, en, ar, he, fa)
```

Rozmiar po `--release` z optimizacjami:
- Linux x86_64: ~4-5 MB (statycznie zlinkowane z rustls, bez OpenSSL)
- Windows x86_64: ~3-4 MB (.exe z icon.ico embedowanym)

---

## Plan Zadań

### FAZA 1: Naprawa Testów (przed CI)

| # | Zadanie | Plik | Status | Opis |
|---|---------|------|--------|------|
| L-01 | Fix test_config_minimal_json | `crates/common-models/src/launcher_config.rs` | ✅ | Pole `profile` miało `#[serde(default)]` (= `""`) zamiast `#[serde(default = "default_profile")]` (= `"prod"`) |
| L-02 | Fix font_pack_download tests (4x) | `crates/launcher-api/src/client.rs` | ✅ | `ApiClient::new()` odrzucał HTTP na loopback (127.0.0.1) — dodano wyjątek loopback analogicznie do `font_pack_download.rs` |

### ~~FAZA 2: GitHub Actions Workflow~~ (NIEPOTRZEBNA — workflows już istnieją)

> Zadania L-03..L-07 **usunięte** — trzy pełne workflows istnieją w `.github/workflows/`:
> `launcher-ci.yml`, `build-launcher.yml`, `release-launcher.yml`

### FAZA 3: Build Config & Optymalizacja

| # | Zadanie | Plik | Status | Opis |
|---|---------|------|--------|------|
| L-08 | Dodać sekcję `[profile.release]` do Cargo.toml | `Cargo.toml` | ✅ | `opt-level = "z"`, `lto = true`, `strip = true`, `codegen-units = 1`, `panic = "abort"` |
| L-09 | Sprawdzić `.cargo/config.toml` | — | ⏭️ skip | Nie potrzebne — reqwest/rustls linkuje statycznie, brak cross-kompilacji |
| L-10 | Sprawdzić tauri-plugin-shell | `apps/launcher-tauri/Cargo.toml` | ⏭️ skip | Już obecne w zależnościach |

### FAZA 4: Weryfikacja (po push na GHA)

| # | Zadanie | Status | Opis |
|---|---------|--------|------|
| L-11 | Push na GHA i obserwacja CI | ⬜ | Sprawdzić czy `launcher-ci.yml` przechodzi po fixach |
| L-12 | Weryfikacja rozmiaru binarki | ⬜ | Sprawdzić artifact z `build-launcher.yml` czy < 5MB |
| L-13 | Smoke test | ⬜ | Pobrać artifact i uruchomić |

---

## Szczegóły Napraw Testów

### L-01: test_config_minimal_json ✅

**Problem:** Pole `profile` w `LauncherConfig` miało atrybut `#[serde(default)]` co dawało pusty string `""`.
Test `test_config_minimal_json` deserializował minimalny JSON (bez pola `profile`) i oczekiwał `profile == "prod"`.

**Root cause:** `#[serde(default)]` na `String` daje `String::default()` = `""`, a nie `"prod"`.
Funkcja `default_profile()` istniała ale nie była użyta w serde.

**Fix:** Zmieniono `#[serde(default)]` → `#[serde(default = "default_profile")]` na polu `profile`.
Teraz deserializacja bez pola `profile` daje `"prod"` — spójne z `Default::default()`.

### L-02: font_pack_download tests (4x TlsRequired) ✅

**Problem:** Testy w `font_pack_download.rs` tworzą `SingleResponseServer` nasłuchujący na `127.0.0.1:0` (HTTP).
`ApiClient::new()` odrzucał **każdy** HTTP base_url jeśli `dev_mode == false` → `Err(ApiError::TlsRequired)`.
Testy panikują na `.expect("client")`.

**Root cause:** `ApiClient::new()` nie miał wyjątku loopback, choć `font_pack_download.rs` go miał.

**Fix:** Dodano sprawdzenie `is_loopback_http()` w `ApiClient::new()` — HTTP dozwolony na `127.0.0.1`/`localhost`/`[::1]`.
Spójne z polityką bezpieczeństwa w `font_pack_download.rs::validate_font_pack_for_download()`.

---

## Profil Release (L-08) ✅

Dodany do `Cargo.toml`:

```toml
[profile.release]
opt-level = "z"        # optymalizacja pod rozmiar
lto = true             # Link-Time Optimization
strip = true           # strip debug symbols
codegen-units = 1      # lepsze LTO kosztem czasu kompilacji
panic = "abort"        # mniejszy runtime (bez unwinding)
```

Oczekiwany efekt:
- Bez optimizacji: ~15-20 MB
- Z `opt-level = "z"` + `lto` + `strip`: ~3-5 MB
- Dalsze redukcje możliwe z `upx` (kompresja binarki): ~1-2 MB

---

## Kolejność Realizacji

```
L-01 → L-02 → L-08 → L-03..L-07 → L-10 → L-11 → L-12 → L-13
 Fix     Fix   Cargo   GHA          Check   Local   Size   Smoke
 test    test   toml    workflow     deps    build   check  test
```

1. Napraw testy (L-01, L-02) — żeby CI przechodziło
2. Dodaj profil release (L-08) — żeby binarki były małe
3. Stwórz GHA workflow (L-03..L-07) — CI/CD
4. Sprawdź zależności (L-09, L-10) — budowa się nie wysypie
5. Lokalna weryfikacja (L-11..L-13) — upewnij się że działa

---

# CZĘŚĆ 2: Lekki Launcher Bootstrap — Dwupoziomowy System Dystrybucji

> **Data:** 2026-03-07  
> **Priorytet:** P0/P1  
> **Cel:** Gracz pobiera ze strony plik ~50-300 KB (jak .torrent), który jednorazowo instaluje pełny launcher

---

## Koncepcja — 3 warstwy dystrybucji

```
WARSTWA 1: Lekki Launcher (Bootstrap)
  - Rozmiar: kilka KB–300 KB (jak plik .torrent)
  - Pobierany ze strony www/reddaxe
  - Jedyne zadanie: pobrać i zainstalować pełny launcher
  - Minimalistyczny GUI (progress bar, ewentualnie logo)

WARSTWA 2: Pełny Launcher (Rust/Tauri) — obecny L-01..L-13
  - Rozmiar: ~3-5 MB
  - Pobierany przez lekki launcher z bazy artefaktów API
  - Pełnoprawny launcher: login, aktualizacje, ticket-gate, start klienta, i18n

WARSTWA 3: Klient gry (OTClient + dane)
  - Rozmiar: ~100-500 MB
  - Pobierany przez pełny launcher z manifestu API
  - Właściwa gra
  - ⚠️ GOTOWE BINARKI — launcher NIE kompiluje gry!
```

> ### ⚠️ ZASADA KLUCZOWA: Launcher pobiera GOTOWE, skompilowane paczki gry
>
> **Launcher (ani bootstrap, ani pełny) NIGDY nie kompiluje klienta gry.**
> Cały łańcuch wygląda tak:
>
> ```
> [BUILD]  Kompilacja klienta gry (OTClient)
>            → GitHub Actions / ręczny build
>            → Produkuje binarkę + dane (sprite, dat, map, itp.)
>                ▼
> [UPLOAD] Gotowa paczka wrzucana do bazy pobierania
>            → Serwer artefaktów (np. /apik/v1/releases/)
>            → Wpis w installer-catalog.php / manifest API
>            → Z hashem SHA-256 i metadanymi (wersja, platform, rozmiar)
>                ▼
> [DOWNLOAD] Launcher pobiera gotową paczkę
>            → GET manifest → porównaj wersję → pobierz ZIP/archiwum → weryfikuj hash → rozpakuj
> ```
>
> **Co to znaczy w praktyce:**
> - Klient gry jest kompilowany OSOBNO (w GHA lub lokalnie) i WRZUCANY na serwer jako gotowy artefakt
> - Launcher tylko SPRAWDZA manifest, POBIERA paczkę i ROZPAKOWUJE ją
> - Nie ma żadnego systemu kompilacji w launcherze — zero cargo build, zero cmake, zero make
> - Aktualizacje klienta = nowa paczka wrzucona do bazy → launcher ją wykrywa i pobiera
>
> **Dlaczego to ważne:**
> - Nie budujemy zbędnych systemów kompilacji wewnątrz launchera
> - Nie mieszamy pipeline buildu gry z pipeline'em launchera
> - Launcher jest KONSUMENTEM artefaktów, a nie ich PRODUCENTEM
> - Osobna odpowiedzialność: build klienta = CI/CD gry, dystrybucja = launcher

### Flow użytkownika

```
[1] Gracz wchodzi na www/reddaxe → klika "Pobierz grę"
        ▼
[2] Pobiera lekki launcher (~50-300 KB)
        ▼
[3] Uruchamia lekki launcher
        ▼
[4] Lekki launcher:
    a. GET /apik/v1/installer-catalog.php?channel=stable&type=launcher
    b. Sprawdza platform/arch
    c. Pobiera pełny launcher (~3-5 MB) z progress barem
    d. Weryfikuje SHA-256
    e. Rozpakowuje do docelowego katalogu
    f. Tworzy launcher_config.json
    g. Tworzy skrót na pulpicie (opcjonalnie)
    h. Uruchamia pełny launcher
    i. Zamyka się (jednorazowe użycie)
        ▼
[5] Pełny launcher startuje (flow L-01..L-13):
    a. Self-update check
    b. Login/rejestracja
    c. Pobiera klienta gry z manifestu (~100-500 MB)
    d. Gracz gra
```

### Diagram artefaktów

```
┌─────────────────────────────────┐
│       www/reddaxe               │
│  ┌───────────────────────┐      │
│  │ [Pobierz grę]         │      │
│  │  → launcher-bootstrap │      │
│  │    (~50-300 KB)        │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│  API: installer-catalog.php     │
│  ┌───────────────────────┐      │
│  │ Pełny launcher        │      │
│  │  launcher-tauri.exe    │      │
│  │  (~3-5 MB)             │      │
│  └───────────────────────┘      │
│  ┌───────────────────────┐      │
│  │ Klient gry            │      │
│  │  otclient.exe + data/  │      │
│  │  (~100-500 MB)         │      │
│  └───────────────────────┘      │
└─────────────────────────────────┘
```

---

## Struktura kodu lekkiego launchera

```
launcher-rust/
├── apps/
│   ├── launcher-bootstrap/          ← NOWY
│   │   ├── Cargo.toml
│   │   └── src/
│   │       ├── main.rs              (entry point + orchestracja)
│   │       ├── downloader.rs        (HTTP GET + progress + SHA-256)
│   │       ├── installer.rs         (rozpakowanie, config, skrót)
│   │       ├── platform.rs          (Windows/Linux detekcja)
│   │       └── ui.rs                (minimal GUI: console + MessageBox)
│   ├── launcher-cli/                (istniejący)
│   └── launcher-tauri/              (istniejący)
```

---

## Technologia — minimalizacja rozmiaru

| Opcja | Rozmiar | Opis |
|-------|---------|------|
| Rust + reqwest(blocking) + sha2 + zip | ~200-500 KB | Minimalne zależności, blocking HTTP, bez async runtime |
| Profile release: opt-level=z, lto, strip, panic=abort | już w workspace | Optymalizacja z istniejącego Cargo.toml workspace |

**Kluczowe ograniczenia:**
- **Brak** tokio/async — blocking reqwest (bez runtime = mniejsza binarka)
- **Brak** launcher-core, launcher-api — bootstrap jest autonomiczny
- **Brak** Tauri — to nie jest GUI app z WebView, to minimalny downloader

---

## Zadania — Lekki Launcher Bootstrap

### FAZA A: Kod lekkiego launchera

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-01 | Utworzyć `apps/launcher-bootstrap/` z Cargo.toml | P0 | Struktura katalogu + member w workspace | ✅ |
| BL-02 | Implementacja `downloader.rs` | P0 | HTTP GET z progress, SHA-256 verify, retry 3x | ✅ |
| BL-03 | Implementacja `installer.rs` | P0 | Rozpakowanie ZIP, config JSON, detekcja istniejącej instalacji | ✅ |
| BL-04 | Implementacja `platform.rs` | P0 | Detekcja OS/arch, ścieżka docelowa, nazwa exe | ✅ |
| BL-05 | Implementacja `ui.rs` (Windows) | P1 | Console progress + Win32 MessageBox na błędach | ✅ (faza 1) |
| BL-06 | Implementacja `ui.rs` (Linux) | P1 | Console progress | ✅ (faza 1) |
| BL-07 | Implementacja `main.rs` | P0 | Orchestracja: catalog → download → verify → extract → config → launch | ✅ |
| BL-08 | Cargo.toml z optymalizacją rozmiaru | P0 | Korzysta z workspace [profile.release] | ✅ |
| BL-09 | Weryfikacja rozmiaru < 500 KB po kompilacji | P0 | Sprawdzić po buildzie na GHA | ⬜ |
| BL-10 | Obsługa błędów i komunikaty | P1 | Brak internetu, timeout, zły hash, brak miejsca | ✅ |

### FAZA B: Workflow GHA

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-11 | Utworzyć workflow `build-bootstrap-launcher.yml` | P0 | Build Windows + Linux, upload artefaktu | ✅ |
| BL-12 | Krok weryfikacji rozmiaru w workflow | P0 | `if size > 512KB then WARNING` | ✅ |
| BL-13 | Krok SHA-256 hash w workflow | P1 | Generowanie pliku `.sha256` obok artefaktu | ✅ |
| BL-14 | Test smoke w workflow | P2 | Uruchom bootstrap z mock API → exit code | ✅ |

### FAZA C: API — rozszerzenie installer-catalog

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-15 | Rozszerzyć `installer-catalog.php` o parametr `type` | P0 | `type=launcher` filtruje artefakty per typ | ✅ |
| BL-16 | Dodać wpisy pełnego launchera do katalogu API | P0 | Wersja, SHA-256, URL, rozmiar po buildzie | ✅ |
| BL-17 | Skrypt deploy do publikacji artefaktów | P1 | Pobierz artefakt z GHA → upload na serwer → update katalogu | ✅ |
| BL-18 | Endpoint health-check artefaktów | P2 | Sprawdzenie czy pliki istnieją i hash OK | ✅ |

### FAZA D: RedDAXE/WWW — strona pobierania

> ### ⚠️ SYNCHRONIZACJA Z RedDaxe.pl
>
> Launcher pobiera gotowe artefakty z API. Ale **strona RedDaxe.pl** to front-end dla gracza:
> pobieranie, informacje o wersji, linki, changelog. Zmiany w launcherze MUSZĄ być zsynchronizowane
> ze stroną www — inaczej gracz widzi stare linki albo brak informacji.
>
> **Co wymaga synchronizacji RedDaxe.pl ↔ Launcher:**
>
> | Element na RedDaxe.pl | Co się zmienia | Kiedy aktualizować |
> |---|---|---|
> | Przycisk "Pobierz grę" (`download.php`, `reddaxe/index.php`) | URL wskazuje na lekki launcher zamiast pełnego ZIP | Po publikacji pierwszego bootstrapa |
> | Wersja launchera na stronie | Odczyt z `installer-catalog.php` / `.env` | Po każdym buildzie nowej wersji |
> | SHA-256 wyświetlany na stronie | Hash z katalogu API | Po każdym buildzie |
> | Informacja o rozmiarze ("~200 KB") | Rozmiar lekkiego launchera | Po zmianie binarki |
> | Strona pobierania portable | Link do pełnego launchera ZIP | Po każdym buildzie Tauri |
> | Changelog / notatki do wersji | `LAUNCHER_NOTES` w `.env` lub API | Po wydaniu nowej wersji |
> | Tłumaczenia (PL/EN) | Nowe klucze i18n w `portal/i18n/` i `reddaxe/i18n/` | Jednorazowo + przy nowych funkcjach |
> | Tekst onboardingowy | "Co robi lekki launcher" — opis na stronie | Jednorazowo |
>
> **Pliki na stronie wymagające zmian:**
> - `portal/download.php` — główna strona pobierania (czyta installer-catalog)
> - `reddaxe/index.php` — landing page MVP z sekcją Download
> - `portal/i18n/pl.php` + `en.php` — tłumaczenia (nowe klucze: bootstrap info, rozmiar)
> - `reddaxe/i18n/pl.php` + `en.php` — tłumaczenia RedDaxe MVP
> - `apik/v1/.env` — `LAUNCHER_VERSION`, `LAUNCHER_SHA256`, `LAUNCHER_DOWNLOAD_URL`
> - `apik/v1/installer-catalog.php` — endpoint API (już rozszerzony o `?type=`)
>
> **Zasada:** Każdy nowy build launchera = aktualizacja `.env` + sprawdzenie czy strona WWW
> poprawnie wyświetla nowe dane. Nie publikujemy binarki bez aktualizacji strony.

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-19 | Folder `reddaxe/downloads/` na lekki launcher | P0 | Katalog + link do pobrania | ✅ |
| BL-20 | Przycisk "Pobierz grę" wskazuje na lekki launcher | P0 | Zmiana URL w `download.php` + `reddaxe/index.php` | ✅ |
| BL-21 | Alternatywny link "Wersja portable" | P1 | Pełny launcher ZIP dla zaawansowanych | ✅ |
| BL-22 | i18n strony pobierania (PL/EN) | P1 | Nowe klucze: opis bootstrapa, rozmiar, onboarding | ✅ |
| BL-23 | Info o rozmiarze i co robi lekki launcher | P1 | "Pobierz (~200 KB) — automatycznie zainstaluje pełną wersję" | ✅ |
| BL-34 | Sync `.env` po każdym buildzie launchera | P0 | `LAUNCHER_VERSION`, `LAUNCHER_SHA256`, `LAUNCHER_DOWNLOAD_URL` | ✅ (deploy_bootstrap.sh) |
| BL-35 | Weryfikacja strony po deploy launchera | P1 | Smoke test: otwórz stronę → sprawdź czy wersja/hash/link poprawne | ⬜ |
| BL-36 | Changelog / release notes na stronie | P2 | Widoczny na stronie pobierania po wydaniu | ⬜ |

### FAZA E: Integracja i testy

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-24 | Test E2E: bootstrap → pełny launcher → klient | P0 | Cała ścieżka od pobrania do gry | ⬜ |
| BL-25 | Test: brak internetu → czytelny komunikat | P1 | Bootstrap nie crashuje, pokazuje błąd | ⬜ |
| BL-26 | Test: zły hash → odmowa instalacji | P0 | SHA-256 mismatch → komunikat | ⬜ |
| BL-27 | Test: już zainstalowany launcher → detekcja | P1 | Pytanie o akcję | ⬜ |
| BL-28 | Test: Windows 10/11 bez admina | P0 | Instalacja w folderze usera bez UAC | ⬜ |
| BL-29 | Test: antywirusy (Defender) | P2 | Brak false positive lub instrukcja | ⬜ |

### FAZA F: Dokumentacja i kontrakty

| # | Zadanie | Priorytet | Opis | Status |
|---|---------|-----------|------|--------|
| BL-30 | Zaktualizować kontrakt `installer-bootstrap.md` | P0 | Nowy model: lekki launcher (~KB) zamiast 10-50 MB | ✅ |
| BL-31 | Zaktualizować kontrakt `installer-catalog.md` | P0 | Parametr `type`, nowe wpisy | ✅ |
| BL-32 | ADR: decyzja o dwupoziomowej dystrybucji | P1 | Dlaczego lekki launcher, alternatywy | ✅ |
| BL-33 | Zaktualizować README launchera | P1 | Opis architektury 3-warstwowej | ✅ |

---

## Kolejność realizacji

### Etap 1 — Fundament (BL-01..BL-10) ✅ DONE
Kod: `platform.rs` → `downloader.rs` → `installer.rs` → `main.rs` → `ui.rs`

### Etap 2 — API (BL-15..BL-18)
1. `BL-15` ✅: Rozszerzenie installer-catalog.php o `?type=launcher`
2. `BL-16` ✅: Wpisy bootstrap + launchera w katalogu
3. `BL-17` ✅: Skrypt deploy (`deploy_bootstrap.sh`)
4. `BL-18` ✅: Health-check (`artifacts-health.php`)

### Etap 3 — Workflow GHA (BL-11..BL-14)
1. `BL-11` ✅: Workflow YAML (`build-bootstrap-launcher.yml`)
2. `BL-12` ✅: Weryfikacja rozmiaru
3. `BL-13` ✅: SHA-256 hash
4. `BL-14` ✅: Smoke test

### Etap 4 — WWW/RedDAXE (BL-19..BL-23) ✅ DONE
1. `BL-19..BL-23` ✅: Strona pobierania (bootstrap + portable + i18n)

### Etap 5 — Testy i dokumentacja (BL-24..BL-33)
1. `BL-24..BL-29`: Testy E2E
2. `BL-30` ✅: Kontrakt installer-bootstrap.md zaktualizowany
3. `BL-31` ✅: Kontrakt installer-catalog.md zaktualizowany
4. `BL-32` ✅: ADR dwupoziomowa dystrybucja
5. `BL-33` ✅: README launcher-rust

---

## Wymagania bezpieczeństwa

1. Lekki launcher komunikuje się TYLKO przez HTTPS
2. Weryfikacja SHA-256 OBOWIĄZKOWA przed rozpakowaniem
3. NIE przechowuje credentials ani tokenów
4. URL API wbudowany w binarkę (nie konfigurowalny przez usera)
5. MUSI odmówić działania bez internetu
6. NIE wymaga uprawnień administratora
7. Zabezpieczenie przed path traversal w ZIP (reject `..`)

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

---

## Kryteria sukcesu

1. Skompilowany lekki launcher waży < 500 KB (cel: < 300 KB)
2. Pobiera i instaluje pełny launcher w < 60 sekund na łączu 10 Mbps
3. Po instalacji pełny launcher startuje automatycznie
4. Gracz nie musi robić NIC oprócz: pobierz → uruchom → czekaj → graj
5. Jednorazowy — po instalacji pełnego launchera nie jest już potrzebny

---

---

# CZĘŚĆ 3: Instalka — Launcher Panel + Client Package + Blokada

> **Data:** 2026-03-07  
> **Cel:** Launcher jako prosty panel (update → integrity → GRAJ), pipeline paczki klienta, pre-launch integrity check, blokada modyfikacji  
> **Zależności:** CZĘŚĆ 1 (launcher Rust ✅) + CZĘŚĆ 2 (bootstrap ✅) + Ticket-Gate (API ✅) + Dual-Mode (Canary guardy ✅ + init.lua ✅)
>
> ### ⚠️ DECYZJA ARCHITEKTONICZNA: Login UI = OTClient, NIE Tauri
>
> **Login, wybór trybu gry (Classic 7.4 / Modern), lista postaci** — to wszystko robi OTClient w Lua:
> - `entergame.lua` — email+hasło, GameMode selection, ticket-gate HMAC flow
> - `serverlist.lua` — locked server list z GameModes
> - Już działa z `CLIENT_LOCKED=true`, dual-mode, ticket flow
>
> **Dlaczego NIE duplikujemy tego w Tauri:**
> 1. Tauri = ciągłe problemy kompilacji (webkit, GTK, frontendDist, cache)
> 2. Podwójna logika logowania = podwójne bugi + podwójna praca
> 3. OTClient login flow jest przetestowany i działa z ticket-gate
> 4. Launcher powinien być PROSTY — panel statusu, nie drugi klient
>
> **Launcher robi:**
> ```
> [Self-Update] → [Client Update/Download] → [Integrity Check] → [Launch Token] → [GRAJ]
> ```
> **OTClient robi:**
> ```
> [Login email+pw] → [Wybór trybu: Classic/Modern] → [Lista postaci] → [Ticket HMAC] → [Połączenie z serwerem]
> ```

## Przegląd Systemu

```
┌───────────────────────────────────────────────────────────────────┐
│  WARSTWA 3: Bootstrap (~300 KB)                                   │
│  Zadanie: pobierz + zainstaluj pełny launcher                     │
│  Status: ✅ kod gotowy (BL-01..BL-23, BL-30..BL-34)              │
└──────────────────────────┬────────────────────────────────────────┘
                           │ instaluje
                           ▼
┌───────────────────────────────────────────────────────────────────┐
│  WARSTWA 2: Launcher Tauri (~3-5 MB)          ← TU JESTEŚMY      │
│  ┌─────────────┐ ┌────────────┐ ┌───────────┐ ┌──────────────┐  │
│  │  Status     │ │  Download  │ │ Integrity │ │  Launch      │  │
│  │  Panel     │ │  Manager   │ │ Guard     │ │  (token+exec)│  │
│  │  (progress) │ │  (manifest)│ │ (7 files) │ │              │  │
│  └─────────────┘ └────────────┘ └───────────┘ └──────────────┘  │
│  ┌─────────────┐ ┌────────────┐ ┌───────────┐                   │
│  │  Self-      │ │  Channel   │ │  Repair   │    NIE MA TU:     │
│  │  Update     │ │  Manager   │ │  Mode     │    Login UI       │
│  └─────────────┘ └────────────┘ └───────────┘    Server Select  │
│                                                   Character List │
└──────────────────────────┬────────────────────────────────────────┘
                           │ pobiera + uruchamia
                           ▼
┌───────────────────────────────────────────────────────────────────┐
│  WARSTWA 1: OTClient (~200-500 MB)                                │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │  LOGIN UI (Lua): email+pw → tryb gry → lista postaci       │  │
│  │  CLIENT_LOCKED=true | GameModes | Ticket-Gate HMAC          │  │
│  │  18 guardów C++ | Feature flags Lua                         │  │
│  └─────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

## Bezpieczeństwo — 3 Warstwy Istniejące

| Warstwa | Komponent | Status | Opis |
|---------|-----------|--------|------|
| **UX/Speed-bump** | `CLIENT_LOCKED=true` + feature flags Lua | ✅ init.lua | Blokuje UI, ale obchodzalne przez edycję pliku |
| **Hard Server** | 18 guardów w `protocolgame.cpp` | ✅ Canary | Rune hard-block, Market/Quick-Loot/Prey guard — NIE do obejścia bez rekompilacji serwera |
| **Crypto** | Ticket-Gate HMAC-SHA256 + gameMode w payload | ✅ API + Canary | `base64.hex(HMAC)`, one-time nonces, ticket_validator.cpp |

**⚠️ LUKA:** Warstwa UX jest obchodzalna — gracz może zmodyfikować `init.lua` → `CLIENT_LOCKED=false`.  
**→ ROZWIĄZANIE:** Launcher wykonuje SHA-256 integrity check 7 krytycznych plików Lua PRZED uruchomieniem klienta (FAZA J).

---

## FAZA G: Launcher Tauri — Status Panel ✅ JUŻ ZAIMPLEMENTOWANE

> **Status:** ✅ GOTOWE — `index.html` zawiera screen-status, screen-update, screen-error, screen-repair.  
> `app.js` — i18n (5 języków), error reporting, event handling. `commands.rs` — 20+ Tauri commands.
>
> **Audyt 2026-03-07:** Pełne implementacje potwierdzone:
> - INS-01 ✅ Status panel: `#screen-status`, `#status-launcher-ver`, przycisk GRAJ
> - INS-02 ✅ Progress bar: `#screen-update`, `#progress-bar`, `#progress-stage`, `#progress-percent`
> - INS-03 ✅ Repair: `repair_installation()` Tauri command + repair screen
> - INS-04 ✅ Integrity modal: `pre_launch_check()` returns PreLaunchCheckDto (modified/missing/errors)
> - INS-05 ✅ Self-update: `check_launcher_update()` + `perform_self_update()` commands
> - INS-06 ✅ Errors (i18n): `app.js` — `t()` z PL/EN fallback, `reportError()`, `loadLocaleDictionary()`

### Flow launchera (uproszczony — BEZ logowania):
```
[Launcher Start]
     │
     ▼
[Sprawdź aktualizację launchera] ──(nowa wersja)──→ [Self-Update → restart]
     │ (aktualny)
     ▼
[Sprawdź client/ directory]
     │
     ├─(puste)─→ [First-Run: UI "Pobieranie gry..." + progress bar]
     ├─(manifest mismatch)─→ [Delta Update: UI "Aktualizacja..." + progress bar]
     │ (OK)
     ▼
[Pre-Launch Integrity Check (7 plików Lua)]
     │
     ├─(hash mismatch)─→ [BLOKADA → modal "Pliki zmodyfikowane" → "Napraw"]
     │ (OK)
     ▼
[POST /launcher-token.php → filesHash + challenge → token]
     │
     ├─(rejected)─→ [BLOKADA → "Wersja klienta nieaktualna" → "Aktualizuj"]
     │ (OK)
     ▼
[UI: "Gotowy do gry!" + przycisk "GRAJ"]
     │
     ▼ (klik "GRAJ")
[SET OTC_LAUNCH_TOKEN=token → exec otclient.exe]
     │
     ▼
[OTClient startuje → Lua login UI → email+pw → tryb gry → postać → ticket → serwer]
```

---

## FAZA H: Client Package Pipeline — Build + Manifest — ✅ WIĘKSZOŚĆ ZAIMPLEMENTOWANA

> **Cel:** GHA workflow budujący czystą paczkę klienta (bez src/, CMake, devtools) + manifest z hashami SHA-256  
> **Ref:** `15_PLAN_INSTALKA_KLIENT_PACZKA.md`, `2026-03-05_ochrona_plikow_klienta.md`
>
> **Audyt 2026-03-07:**
> - INS-10 ✅ GOTOWE — `canary_test/testyy/.github/workflows/build-client-package.yml` (630 linii):
>   Windows + Linux jobs, 7-step assemble, strip, package lint (allowlist+denylist+secret scan),
>   file manifest (SHA-256), checksum sign (Ed25519), artifact upload (90d retention)
> - INS-11 ✅ GOTOWE — Strip logika inline w YML (step 6 + lint step). Osobny `tools/strip_dev_files.sh` dodany.
> - INS-12 ✅ GOTOWE — `canary_test/html_copy/apik/v1/generate_manifest.php` (290 linii):
>   categorizeFile(), criticalFiles list, DB manifest_versions, manifests/{channel}/{version}.json
> - INS-13 ✅ GOTOWE — `canary_test/html_copy/apik/v1/update.php`: GET ?channel=stable&version=latest,
>   ETag + Cache-Control + 304 support
> - INS-14 ✅ GOTOWE — YML ma osobne jobs: windows (x64, .exe+DLLs) i linux (x64, ELF+.so)
> - INS-15 ✅ GOTOWE — `tools/deploy-client.sh` (istniejący): unzip/tar → /var/www/html/apik/v1/files/{channel}/{version}/ → manifest regen → latest symlink → old version cleanup

| ID | Zadanie | Plik/Moduł | Status |
|----|---------|-----------|--------|
| **INS-10** | **`build-client-package.yml`** — workflow GHA | `canary_test/testyy/.github/workflows/` | ✅ DONE |
| **INS-11** | **`strip_dev_files.sh`** — strip dev files z paczki | `tools/strip_dev_files.sh` + inline w YML | ✅ DONE |
| **INS-12** | **`generate_manifest.php`** — manifest z SHA-256 | `canary_test/html_copy/apik/v1/` | ✅ DONE |
| **INS-13** | **API: `/update.php`** — serwuje manifest.json | `canary_test/html_copy/apik/v1/update.php` | ✅ DONE |
| **INS-14** | **Warianty: Windows + Linux** — osobne builds | w INS-10 (2 jobs) | ✅ DONE |
| **INS-15** | **`deploy-client.sh`** — deploy paczki | `tools/deploy-client.sh` | ✅ DONE |

### Struktura paczki klienta (po strip):
```
client-v1.0.0/
├── otclient.exe / otclient          # binarka gry
├── init.lua                          # CLIENT_LOCKED=true, GameModes
├── data/
│   ├── things/1412/                  # assety protokołu
│   ├── fonts/
│   ├── images/
│   └── locales/
├── modules/
│   ├── client_entergame/             # login flow (ticket-gate)
│   ├── client_serverlist/            # server list (locked)
│   ├── client_terminal/
│   └── ...
├── mods/                             # opcjonalne mody (preserve_user)
└── otclientrc.lua                    # ustawienia gracza (preserve_user)
```

### manifest.json (format):
```json
{
  "version": "1.0.0",
  "channel": "stable",
  "platform": "windows",
  "generatedAt": "2026-03-07T12:00:00Z",
  "files": [
    {
      "path": "init.lua",
      "sha256": "abc123...",
      "size": 4096,
      "managed": true,
      "critical": true,
      "overwritePolicy": "if_hash_differs"
    },
    {
      "path": "otclientrc.lua",
      "sha256": "def456...",
      "size": 512,
      "managed": true,
      "critical": false,
      "overwritePolicy": "preserve_user"
    }
  ],
  "criticalFiles": [
    "init.lua",
    "modules/client_entergame/entergame.lua",
    "modules/client_entergame/entergame.otui",
    "modules/client_serverlist/serverlist.lua",
    "modules/client_serverlist/serverlist.otui",
    "modules/startup/startup.lua",
    "meta.lua"
  ]
}
```

---

## FAZA I: Launcher Core — Pobieranie + Aktualizacja Klienta ✅ JUŻ ZAIMPLEMENTOWANE

> **Status:** ✅ GOTOWE — Pełne implementacje w launcher-core + launcher-api + launcher-tauri/commands.rs.
>
> **Audyt 2026-03-07:** Pełne implementacje potwierdzone:
> - INS-16 ✅ `planner.rs` (`build_update_plan()`) + `file_index.rs` (`scan_from_manifest()`) — porównanie manifest vs lokalne pliki, delta plan
> - INS-17 ✅ `launcher-api/client.rs` (`download_file()`) + `patcher.rs` (`stage_file()`) — HTTP retry 3x, SHA-256 weryfikacja
> - INS-18 ✅ `artifact_verify.rs` (`verify_artifact_strict()`) + `integrity.rs` (`sha256_file()`) — SHA-256 per plik vs manifest
> - INS-19 ✅ `planner.rs` — delta: `OverwritePolicy::PreserveUser`, `OverwritePolicy::Never`, hash comparison
> - INS-20 ✅ `commands.rs` (`start_update()`) — wykrywa pusty client/, pełny download z manifestu z 5-fazowym flow
> - INS-21 ✅ `patcher.rs` (`apply_staged_file()`, `backup_file()`) — staging → backup → atomic rename (z fallback copy+delete)
> - INS-22 ✅ `repair.rs` (`diagnose_installation()`) — skan plików, corrupted/missing/orphan detection, plan naprawy
> - INS-23 ✅ `state.rs` (`save_state()`, `load_state()`) — atomic JSON write (tmp+fsync+rename)

### Flow pobierania (First-Run + Delta):
```
[Launcher start]
     │
     ▼
[GET /client-manifest.php?channel=stable&platform=windows]
     │
     ▼
[Porównaj z installed_state.json]
     │
     ├─(brak state → first-run)──→ [Pobierz WSZYSTKIE pliki]
     ├─(version match)──→ [Skip — klient aktualny]
     ├─(version differs)──→ [Delta: lista changed/added/deleted]
     │
     ▼
[Download changed files → staging/]
     │
     ▼
[SHA-256 weryfikacja KAŻDEGO pliku]
     │
     ├─(hash mismatch)──→ [Retry download 3x → jeśli dalej fail → ABORT + rollback]
     │ (OK)
     ▼
[Atomic swap: staging/ → client/]
     │
     ▼
[Zapisz installed_state.json]
```

---

## FAZA J: Blokada Instalki — Pre-Launch Integrity + Security ✅ JUŻ ZAIMPLEMENTOWANE

> **Status:** ✅ GOTOWE — `integrity.rs`, `challenge.rs`, `process_runner.rs`, `commands.rs` — pełne implementacje.
>
> **Audyt 2026-03-07:** Pełne implementacje potwierdzone:
> - INS-24 ✅ `integrity.rs` (`verify_critical_files()`) — hash 7 krytycznych plików vs manifest, CriticalFilesReport
> - INS-25 ✅ `integrity.rs` (`compute_files_hash()`) — SHA-256 konkatenacja → single hash string
> - INS-26 ✅ `challenge.rs` (`compute_challenge_response()`) — SHA256(nonce+":"+filesHash), nonce validation
> - INS-27 ✅ `commands.rs` (`pre_launch_check()`) — returns PreLaunchCheckDto (passed/modified/missing/error)
> - INS-28 ✅ `commands.rs` (`repair_tampered_critical_files()`, `repair_installation()`) — redownload + re-verify
> - INS-29 ✅ `commands.rs` (`launch_game()`) → `process_runner.rs` (`launch_client()`) — SET OTC_LAUNCH_TOKEN + exec

> **UWAGA:** ~~INS-30 (ticket request)~~ — **USUNIĘTE**. Ticket HMAC generuje OTClient (entergame.lua), NIE launcher.  
> Launcher odpowiada TYLKO za: integrity check → launch-token → exec. Login + gameMode + ticket = OTClient.

### 7 Krytycznych Plików (SHA-256 weryfikacja):
```
1. init.lua                                    — CLIENT_LOCKED + GameModes
2. modules/client_entergame/entergame.lua      — login flow + ticket-gate
3. modules/client_entergame/entergame.otui     — login UI layout
4. modules/client_serverlist/serverlist.lua     — server list (locked)
5. modules/client_serverlist/serverlist.otui    — server list UI layout
6. modules/startup/startup.lua                 — startup sequence
7. meta.lua                                    — metadata
```

### Scenariusze blokady:
| Sytuacja | Zachowanie launchera |
|----------|---------------------|
| Wszystkie 7 plików OK | ✅ Kontynuuj → token → launch |
| `init.lua` hash mismatch | 🔴 BLOKADA → "Pliki zmodyfikowane" → Napraw |
| `entergame.lua` hash mismatch | 🔴 BLOKADA → "Pliki zmodyfikowane" → Napraw |
| filesHash rejected przez API | 🔴 BLOKADA → "Wersja klienta nieaktualna" → Aktualizuj |
| Nonce expired (challenge fail) | 🟡 Retry challenge → jeśli 3x fail → error |
| Brak połączenia z API | 🟡 Offline mode: integrity check lokalnie OK → launch BEZ tokenu (gracze nie mogą grać, ale klient się odpali) |

---

## ~~FAZA K: USUNIĘTA~~ — Dual-Mode = OTClient, NIE Launcher

> **Dual-mode (Classic 7.4 / Modern) jest W CAŁOŚCI obsługiwany przez OTClient:**
> - `init.lua` → `GameModes` z konfiguracją featurów per tryb
> - `entergame.lua` → panel wyboru trybu, filtrowanie postaci per world/gameMode
> - `login.php` → `gameMode` parameter, filtrowanie worlds
> - `ticket.php` → `gameMode` w HMAC payload
> - `protocolgame.cpp` → 18 guardów C++ server-side
>
> **Launcher NIE musi wiedzieć o dual-mode.** Launcher dostarcza klienta i uruchamia go — reszta jest w Lua/API/C++.
>
> Dawne zadania INS-31..INS-36 → **USUNIĘTE** (nie dotyczy launchera).

---

## FAZA L: Bug Fixes — Bezpieczeństwo (z Rejestru J6) + C++ Integracja

> **Ref:** `2026-03-05_ui_installer_bug_registry_J6.md`
>
> ### C++ OTClient — Integracja z Launcherem i Siecią (audyt 2026-03-07)
>
> Audyt `httplogin.cpp` wykazał 2 krytyczne + 3 rekomendowane luki.
> Wszystkie pre-kompilacyjne naprawione:
>
> | ID | Plik | Opis | Status |
> |----|------|------|--------|
> | **INS-CPP1** | `httplogin.cpp`, `httplogin.h` | `startHttpLogin()` usunięty — dead code: brak Lua binding, brak TLS verify, discards response | ✅ FIXED |
> | **INS-CPP2** | `httplogin.cpp` (loginHttpsJson + requestTicket) | Dodano HTTP timeouts (10s connect, 15s read, 10s write) — zapobiega zawieszeniu wątku | ✅ FIXED |
> | **INS-CPP3** | `win32platform.cpp`, `unixplatform.cpp` | `openUrl()` default zostaje `http://` — instalka łączy się przez HTTP | ↩️ REVERTED |
>
> **Co JUŻ działa poprawnie w C++:**
> - ✅ TLS cert verification w `loginHttpsJson()` i `requestTicket()` (cacert.pem + hard-fail)
> - ✅ Brak HTTP fallback (INS-37/38 naprawione wcześniej — X2b)
> - ✅ `launchToken` wysyłany we WSZYSTKICH ścieżkach logowania
> - ✅ `gameMode` wysyłany we WSZYSTKICH ścieżkach logowania + ticketu
> - ✅ Graceful error handling (brak crashy, Lua callbacks on fail)
> - ✅ Sensitive data nie logowane (email, password, session keys)

| ID | Zadanie | Bug | Priorytet | Pre-kompilacja? |
|----|---------|-----|-----------|-----------------|
| **INS-37** | **TLS cert chain verification** — `loginHttpsJson()` i `requestTicket()` mają `set_ca_cert_path` + `enable_server_certificate_verification(true)`. Dead code `startHttpLogin()` (bez TLS) usunięty. | B-001 🔴 | CRITICAL | ✅ DONE (audyt potwierdził + INS-CPP1) |
| **INS-38** | **Usunięcie HTTP fallback** — X2b: `loginHttpJson()` usunięte, komentarz na L123. Jedyna ścieżka = HTTPS SSLClient. | B-002 🔴 | CRITICAL | ✅ DONE (X2b + audyt) |
| **INS-39** | **`isFeatureEnabled()` default → false** — fail-closed zamiast fail-open | B-005 🟡 | MEDIUM | ✅ DONE |
| **INS-40** | **Rate-limit na `/ticket.php`** — per IP (5/min) + per sessionKey (3/min) | B-006 🟡 | MEDIUM | ✅ DONE |
| **INS-41** | **Dead code cleanup** — ~~usunięcie `loginHttpJson()`~~ ✅ Już usunięte (FIX44+CPP-4) | B-007 🔵 | LOW | ✅ DONE |

---

## FAZA M: Dev vs Prod — Separacja Środowisk ✅ CZĘŚCIOWO ZAIMPLEMENTOWANE

> **Status:** ✅ Większość istnieje w `LauncherConfig` + `commands.rs`.
>
> **Audyt 2026-03-07:**
> - INS-42 ✅ `LauncherConfig` ma `channel: String` ("stable"/"dev"/"test"), `api_base_url`, `profile` ("dev"/"prod")
> - INS-43 ✅ `LauncherConfig` ma `client_dir: String` — konfigurowalne per kanał
> - INS-44 ✅ `LauncherConfig` ma `dev_mode: bool` + `ApiClientConfig.dev_mode` (self-signed certs w dev)
> - INS-45 ✅ `fetch_manifest()` przyjmuje `channel` — manifest per kanał

---

## FAZA N: Testy E2E + Acceptance Criteria

> **Cel:** Weryfikacja kompletnego flow: bootstrap → launcher → download → login → play

| ID | Zadanie | Scenariusz | Pre-kompilacja? |
|----|---------|-----------|-----------------|
| **INS-46** | **Test: Fresh Install (Windows)** — bootstrap → launcher → first-run download → login → Classic 7.4 → play | Windows E2E | ❌ (wymaga binariów) |
| **INS-47** | **Test: Fresh Install (Linux)** — jak INS-46 ale Linux | Linux E2E | ❌ (wymaga binariów) |
| **INS-48** | **Test: Delta Update** — zmień 1 plik w manifeście → launcher pobiera TYLKO ten plik, reszta skip | Update E2E | ❌ (wymaga binariów) |
| **INS-49** | **Test: Integrity Block** — zmodyfikuj init.lua ręcznie → launcher BLOKUJE launch → "Napraw" → redownload → launch OK | Security E2E | ❌ (wymaga binariów) |
| **INS-50** | **Test: Dual-Mode Switch** — zaloguj Classic → wyloguj → zaloguj Modern → verify different worlds/characters | Dual-mode E2E | ❌ (wymaga binariów) |
| **INS-51** | **Test: Repair Mode** — usuń 3 pliki z client/ → "Napraw" → launcher redownloaduje → verify OK | Repair E2E | ❌ (wymaga binariów) |
| **INS-52** | **Test: Offline Launch** — odłącz internet → launcher integrity check lokalnie → launch (bez tokenu, klient pokaże "brak połączenia") | Offline E2E | ❌ (wymaga binariów) |
| **INS-53** | **Test: Self-Update Launcher** — nowa wersja launchera → self-update → verify nowa wersja działa | Self-update E2E | ❌ (wymaga binariów) |

---

## FAZA O: Admin Server Management — Dynamiczna lista serwerów

> **Data:** 2026-03-07  
> **Cel:** Admin (tylko Ty) może dodawać/edytować/wyłączać serwery przez API.  
> Serwery propagują się automatycznie do: login.php, server-status, manifest, launcher, klient OTClient.  
> **Rozwiązanie problemu:** "Nie wiem w jaki sposób będę mógł dodawać do instalki nowe serwery"

### Architektura docelowa (flow):
```
Admin (Ty) + X-Admin-Key
    │
    ▼
games-manage.php (INS-60)  ──► tabela `games` (DB)
    │                              │
    │                              ├──► login.php (czyta z games — JUŻ DZIAŁAŁO)
    │                              ├──► server-status.php (INS-63 — teraz z DB)
    │                              ├──► generate_manifest.php (INS-64 — teraz z DB)
    │                              │         │
    │                              │         ▼
    │                              │    manifest.json → servers[]
    │                              │         │
    │                              │         ▼
    │                              │    launcher → sync_serverlist() → init_serverlist.lua
    │                              │                                        │
    │                              │                                        ▼
    │                              │                                   OTClient (INS-66/67)
    │                              │                                   (GameModes override)
    │                              │
    ▼                              ▼
admin_audit_log             admin_api_keys (INS-61)
```

### Zmiany:

| ID | Zadanie | Plik/Moduł | Status |
|----|---------|-----------|--------|
| **INS-60** | **`games-manage.php`** — admin CRUD (GET/POST/PUT/DELETE) z `X-Admin-Key` | `canary_test/html_copy/apik/v1/games-manage.php` | ✅ DONE |
| **INS-61** | **Admin API key system** — `validateAdminKey()`, `logAdminAction()`, tabele `admin_api_keys` + `admin_audit_log` | `common.php` + migracja 010 | ✅ DONE |
| **INS-63** | **`server-status.php` z DB** — zamiast hardcoded tablicy, czyta z `games` table. Fallback na `.env` gdy DB niedostępna | `server-status.php` | ✅ DONE |
| **INS-64** | **`generate_manifest.php` serwery z DB** — sekcja `servers[]` generowana z tabeli `games`. Fallback na `.env` | `generate_manifest.php` | ✅ DONE |
| **INS-65** | **Migracja 010: `games` + admin tables** — dodaje `game_mode`, `login_port`, `visible`, `description`, `updated_at` do `games`. Tworzy `admin_api_keys` + `admin_audit_log` | `migrations/010_games_admin_{rollout,rollback}.sql` | ✅ DONE |
| **INS-66** | **`serverlist.lua` — merge MANAGED_SERVER_LIST** — w trybie CLIENT_LOCKED dodaje serwery z init_serverlist.lua (generowanej przez launcher) obok GameModes | `modules/client_serverlist/serverlist.lua` (3 kopie) | ✅ DONE |
| **INS-67** | **`init.lua` — load init_serverlist.lua** — dofile() po GameModes, nadpisuje server.host/port z launcher-managed data, zachowuje feature flags | `init.lua` (3 kopie) | ✅ DONE |
| **INS-68** | **Production URLs** — `.env.example` z `API_BASE_URL`, instrukcje admin key, httpLoginUrl override w init.lua | `.env.example` + `generate_admin_key.php` | ✅ DONE |

### Jak dodać nowy serwer (flow admin):

```bash
# 1. Wygeneruj klucz admin (jednorazowo)
php generate_admin_key.php "ptaku-main"
# Zapisz wyświetlony klucz!

# 2. Dodaj nowy serwer
curl -X POST https://twoj-serwer/apik/v1/games-manage.php \
  -H "X-Admin-Key: TWOJ_KLUCZ" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "tibia_pvp",
    "game_mode": "pvp",
    "name": "PvP Arena",
    "game_host": "10.0.0.5",
    "game_port": 7176,
    "engine_db_name": "canary_pvp",
    "sort_order": 3
  }'

# 3. Przegeneruj manifest (automatycznie pobierze nowy serwer z DB)
php generate_manifest.php stable 1.0.1 /sciezka/do/paczki

# 4. Launcher automatycznie: manifest → init_serverlist.lua → OTClient widzi nowy serwer
# 5. login.php automatycznie: czyta z games table → nowy serwer w login response
# 6. server-status.php automatycznie: czyta z games table → status nowego serwera

# Zarządzanie:
# Listuj serwery
curl -H "X-Admin-Key: TWOJ_KLUCZ" https://twoj-serwer/apik/v1/games-manage.php

# Zmień IP serwera
curl -X PUT "https://twoj-serwer/apik/v1/games-manage.php?id=3" \
  -H "X-Admin-Key: TWOJ_KLUCZ" \
  -H "Content-Type: application/json" \
  -d '{"game_host": "10.0.0.7"}'

# Wyłącz serwer (soft delete)
curl -X DELETE "https://twoj-serwer/apik/v1/games-manage.php?id=3" \
  -H "X-Admin-Key: TWOJ_KLUCZ"

# Maintenance mode
curl -X PUT "https://twoj-serwer/apik/v1/games-manage.php?id=3" \
  -H "X-Admin-Key: TWOJ_KLUCZ" \
  -H "Content-Type: application/json" \
  -d '{"status": "maintenance"}'
```

---

## FAZA P: C++ Hardening — Bezpieczeństwo OTClient (audyt 2026-03-07)

> **Data:** 2026-03-07  
> **Cel:** Uszczelnienie kodu C++ klienta: eliminacja shell injection, walidacja inputów z launchera, czyszczenie credentials z pamięci  
> **Pliki:** `unixplatform.cpp`, `httplogin.cpp`, `httplogin.h`, `protocolgamesend.cpp`  
> **Revert INS-CPP3:** openUrl() zostaje z `http://` — instalka łączy się przez HTTP

### Zmiany:

| ID | Plik | Opis | Status |
|----|------|------|--------|
| **INS-CPP4** | `unixplatform.cpp` | **Shell injection fix** — `openUrl()`, `openDir()`: `system()` → `fork()+execlp()`. `copyFile()`: `system("/bin/cp")` → `std::filesystem::copy_file()` | ✅ DONE |
| **INS-CPP5** | `httplogin.cpp` | **LaunchToken validation** — `setLaunchToken()`: max 512 znaków, tylko `[a-zA-Z0-9_.-]`, odrzuca nieprawidłowe tokeny | ✅ DONE |
| **INS-CPP6** | `httplogin.cpp` | **GameMode whitelist** — `setGameMode()`: akceptuje TYLKO `"classic74"`, `"modern"`, lub pusty string | ✅ DONE |
| **INS-CPP7** | `httplogin.cpp` | **Cert path check w requestTicket()** — dodano `ifstream` check cacert.pem (analogicznie do loginHttpsJson FIX35) | ✅ DONE |
| **INS-CPP8** | `protocolgamesend.cpp` + `httplogin.cpp` | **Credential cleanup** — `m_accountPassword`/`m_authenticatorToken` czyszczone po wysłaniu login pakietu. `launchToken` czyszczony po udanym loginie HTTP | ✅ DONE |
| **INS-CPP9** | `unixplatform.cpp` | **openDir shell injection** — `system("xdg-open")` → `fork()+execlp()` (część INS-CPP4) | ✅ DONE |
| **INS-CPP3** | `win32platform.cpp`, `unixplatform.cpp` | **REVERT** — openUrl() default zostaje `http://` — instalka łączy się przez HTTP, nie HTTPS | ↩️ REVERTED |

---

## Podsumowanie — Status Zadań CZĘŚĆ 3

### ✅ Już zaimplementowane (audyt launcher-rust 2026-03-07):
| Faza | Zadania | Opis | Status |
|------|---------|------|--------|
| **G** | INS-01..06 | Status Panel (index.html + app.js + commands.rs) | ✅ GOTOWE |
| **H** | INS-10..15 | Client Package Pipeline (GHA + manifest + deploy) | ✅ GOTOWE |
| **I** | INS-16..23 | Pobieranie + Delta + Repair + Atomic Apply | ✅ GOTOWE |
| **J** | INS-24..29 | Blokada + Integrity Guard + Token + Launch | ✅ GOTOWE |
| **L** | INS-37..41 + CPP1..3 | Bug fixes + C++ integracja z launcherem | ✅ GOTOWE |
| **M** | INS-42..45 | Dev vs Prod (LauncherConfig + channel-aware) | ✅ GOTOWE |
| **O** | INS-60..68 | Admin Server Management — dynamiczna lista serwerów | ✅ GOTOWE |
| **P** | INS-CPP4..9 | C++ Hardening — shell injection, input validation, credential cleanup | ✅ GOTOWE |

### ✅ Dodatkowe bugi naprawione w audycie deep-verification:
| Bug | Plik | Opis | Status |
|-----|------|------|--------|
| BUG-1 | `manifest_signature.rs`, `hmac_rotation.rs` | `is_multiple_of()` wymaga Rust 1.85+ → zamienione na `% 2 != 0` | ✅ FIXED |
| BUG-2 | `commands.rs` (perform_self_update) | Brak app.exit() po launch_helper → dodano tokio::spawn z 500ms delay + exit(0) | ✅ FIXED |
| BUG-3 | `build-client-package.yml` (Linux) | `\"$MANIFEST\"` escaped quotes w grep → poprawione na `"$MANIFEST"` | ✅ FIXED |
| BUG-INS-39 | `init.lua` (3 kopie) | isFeatureEnabled() default true → false (fail-closed) | ✅ FIXED |
| BUG-INS-40 | `ticket.php` | Brak rate-limit → dodano 5/min per IP + 3/min per session via applyRateLimit() | ✅ FIXED |
| INS-11 | `tools/strip_dev_files.sh` | Nowy skrypt — reusable strip logic (standalone + GHA) | ✅ CREATED |
| INS-CPP1 | `httplogin.cpp`, `httplogin.h` | Dead code `startHttpLogin()` usunięty (brak TLS, brak Lua binding) | ✅ FIXED |
| INS-CPP2 | `httplogin.cpp` | HTTP timeouts dodane do loginHttpsJson() + requestTicket() (10s/15s/10s) | ✅ FIXED |
| INS-CPP3 | `win32platform.cpp`, `unixplatform.cpp` | openUrl() default zostaje `http://` — instalka używa HTTP | ↩️ REVERTED |
| INS-37+38 | `httplogin.cpp` | TLS verify + brak HTTP fallback — audyt potwierdził że X2b+FIX-C2 działają | ✅ VERIFIED |
| INS-60 | `games-manage.php` | Admin CRUD API (GET/POST/PUT/DELETE) z X-Admin-Key + rate-limit + audit log | ✅ CREATED |
| INS-61 | `common.php` + migracja 010 | validateAdminKey() + logAdminAction() + getActiveGamesFromDb() + admin_api_keys/audit tables | ✅ CREATED |
| INS-63 | `server-status.php` | Serwery z DB (games table) zamiast hardcoded tablicy PHP, maintenance status z DB | ✅ FIXED |
| INS-64 | `generate_manifest.php` | Sekcja servers[] z DB (games table) zamiast hardcoded, fallback na .env | ✅ FIXED |
| INS-65 | `migrations/010_games_admin_*.sql` | game_mode, login_port, visible, description → games + admin_api_keys + admin_audit_log | ✅ CREATED |
| INS-66 | `serverlist.lua` (3 kopie) | Merge MANAGED_SERVER_LIST w CLIENT_LOCKED mode — nowe serwery z launchera | ✅ FIXED |
| INS-67 | `init.lua` (3 kopie) | Load init_serverlist.lua → override GameModes server addresses z launcher data | ✅ FIXED |
| INS-68 | `.env.example` + `generate_admin_key.php` | API_BASE_URL, admin key instrukcje, CLI generator klucza | ✅ CREATED |
| INS-CPP4 | `unixplatform.cpp` | Shell injection fix: openUrl/openDir → fork()+execlp(), copyFile → std::filesystem | ✅ FIXED |
| INS-CPP5 | `httplogin.cpp` | LaunchToken validation: max 512 znaków, alfanumeryczne + _-. | ✅ FIXED |
| INS-CPP6 | `httplogin.cpp` | GameMode whitelist: tylko classic74/modern/empty | ✅ FIXED |
| INS-CPP7 | `httplogin.cpp` | Cert path check w requestTicket() — cacert.pem ifstream check | ✅ FIXED |
| INS-CPP8 | `protocolgamesend.cpp` + `httplogin.cpp` | Credential cleanup po wysłaniu login pakietu + launchToken clear | ✅ FIXED |
| INS-CPP9 | `unixplatform.cpp` | openDir shell injection → fork()+execlp() | ✅ FIXED |

### 🔲 Nie dotyczy pre-kompilacji (wymaga binariów):
| Faza | Zadania | Opis | Ilość |
|------|---------|------|-------|
| **N** | INS-46..53 | Testy E2E + acceptance | 8 |
| **RAZEM** | | **Post-kompilacja** | **8** |

### Kolejność realizacji:
```
1. FAZA H (INS-10..15) — Pipeline paczki klienta ✅ DONE
2. FAZA L (INS-39..41) — Bug fixes ✅ DONE
3. Deep verification + dodatkowe bugi ✅ DONE (BUG-1..3)
4. FAZA O (INS-60..68) — Admin Server Management ✅ DONE
5. FAZA P (INS-CPP4..9) — C++ Hardening ✅ DONE
6. FAZA Q (Q-01..04) — PHP API Hardening ✅ DONE
7. FAZA R (R-01..03) — Build Workflow Fixes ✅ DONE
8. FAZA S (S-01) — Lua Sync (3 kopie) ✅ DONE
9. FAZA T (T-01..04) — PHP Diagnostyka DEV_MODE Guard ✅ DONE
10. FAZA U (U-01..16) — C++ Deep Quality Audit ✅ DONE
11. FAZA N (INS-46..53) — Testy E2E (PO kompilacji) ← NASTĘPNE
```

---

## FAZA T: PHP Diagnostyka — DEV_MODE Guard (audyt 2026-03-07) ✅ DONE

> **Zakres:** 4 endpointy diagnostyczne w `canary_test/html_copy/apik/v1/` dostępne publicznie bez zabezpieczeń.

| ID | Plik | Zmiana | Status |
|----|------|--------|--------|
| T-01 | peek_env.php | DEV_MODE guard (ujawniał zmienne .env) | ✅ DONE |
| T-02 | diag_players.php | DEV_MODE guard + rate-limit 5/min/IP (SELECT na kontach) | ✅ DONE |
| T-03 | echo.php | DEV_MODE guard (echo raw POST) | ✅ DONE |
| T-04 | auth_probe.php | DEV_MODE guard + rate-limit 5/min/IP (weryfikacja haseł 2 baz) | ✅ DONE |

---

## FAZA Q: PHP API — Hardening (audyt 2026-03-07) ✅ DONE

> **Zakres:** Pliki PHP w `canary_test/html_copy/apik/v1/`. Wynik audytu kodu instalki.

| ID | Plik | Zmiana | Status |
|----|------|--------|--------|
| Q-01 | verify-email.php | Transakcja DB (beginTransaction/commit/rollBack) | ✅ DONE |
| Q-02 | launcher-token.php | Whitelist kanałów: `['stable', 'beta', 'dev']` | ✅ DONE |
| Q-03 | games-manage.php | try/catch PDOException w handleCreate() + handleUpdate() | ✅ DONE |
| Q-04 | pwcheck.php | DEV_MODE guard, rate-limit 5/min/IP, usunięto algo+id z response | ✅ DONE |

---

## FAZA R: Build Workflow — Poprawki (audyt 2026-03-07) ✅ DONE

> **Zakres:** `canary_test/testyy/.github/workflows/build-client-package.yml`

| ID | Zmiana | Status |
|----|--------|--------|
| R-01 | find operator precedence — dodano `\( ... \)` w strip + verify (Windows) | ✅ DONE |
| R-02 | sed CLIENT_LOCKED — dodano WARNING jeśli sed nie zadziałał | ✅ DONE |
| R-03 | SHA256 checksum — już istnieje w sign job | ✅ ALREADY EXISTS |

---

## FAZA S: Synchronizacja Lua — 3 kopie modułów (audyt 2026-03-07) ✅ DONE

> **Źródło prawdy:** `canary_test/testyy/modules/`  
> **Kopie:** `client_pack/1.1.0/modules/`, `launcher_test/test_client/modules/`

Zsynchronizowane pliki: `entergame.lua`, `serverlist.lua`, `characterlist.lua`  
S-01c (symlinki/skrypt) — niski priorytet, do rozważenia w przyszłości.

---

## FAZA U: C++ Deep Quality Audit (audyt 2026-03-07) ✅ DONE

> **Zakres:** Głęboki audyt jakości kodu C++ w `canary_test/testyy/src/`. Memory leaks, UB, zombie processes, buffer overflows, NULL→nullptr, C-style casts, clipboard leaks.

| ID | Plik | Problem | Fix | Severity |
|----|------|---------|-----|----------|
| U-01 | resourcemanager.cpp | `new uint8_t[size]` w `decrypt()` nigdy nie zwolniony — leak | Usunięto zbędną alokację, zapis bezpośrednio do `data[]` | CRITICAL |
| U-02 | unzipper.cpp | `&"error: "[error]` — pointer arithmetic na string literal = UB/crash | `std::to_string(error)` | CRITICAL |
| U-03 | unzipper.cpp | `malloc(unzmem.base)` nie zwalniane na 5 ścieżkach errorowych | Dodano `free(unzmem.base)` na wszystkich ścieżkach + normal exit | HIGH |
| U-04 | unixplatform.cpp | `spawnProcess()` fork() bez SIGCHLD = zombie processes | `signal(SIGCHLD, SIG_IGN)` przeniesiony do `Platform::init()` | HIGH |
| U-05 | unixplatform.cpp | `signal(SIGCHLD, SIG_IGN)` w lambda = global side effect per-call | Jedno wywołanie w `Platform::init()` zamiast w każdej lambdzie | HIGH |
| U-06 | httplogin.cpp | `catch(...) {}` — silent swallow bez logowania | Dodano `g_logger.warning()` w obu catch-all | MEDIUM |
| U-07 | httplogin.cpp | `strcpy(attr.requestMethod, "POST")` bez bounds | `strncpy(..., sizeof(...) - 1)` | MEDIUM |
| U-08 | tile.cpp | `m_things.size() - 1` przy pustym wektorze = unsigned underflow → ~4B iteracji | Dodano `if (m_things.empty()) return nullptr;` guard | MEDIUM |
| U-09 | cast.h | `atol`/`atof` brak sprawdzenia overflow/underflow | `strtol`/`strtod` + `errno`/`ERANGE` check + `INT_MIN`/`INT_MAX` range guard | MEDIUM |
| U-10 | androidmanager.cpp | `malloc()` + `delete[]` = UB (alloc/dealloc mismatch) | `new char[]` + `delete[]` | HIGH |
| U-11 | win32crashhandler.cpp | `fmt::format` z printf `%#0lx`/`%016lX` = literal text | `{:#x}` / `{:#016X}` fmt syntax | MEDIUM |
| U-12 | demangle.cpp | `static char Buffer[1024]` — data race w multi-thread | `thread_local char Buffer[1024]` | MEDIUM |
| U-13 | discord.cpp, main.cpp, win32window.cpp (5×) | `NULL` zamiast `nullptr` w kodzie C++ | `nullptr` wszędzie | LOW |
| U-14 | TextShaper.cpp, packet_player.cpp, crypt.cpp | C-style casty `(int)val`, `(char)val` | `static_cast<T>(val)` | LOW |
| U-15 | win32window.cpp | `GlobalAlloc` fail → `return` bez `CloseClipboard()` = clipboard lock leak | Dodano `CloseClipboard()` przed `return` | MEDIUM |
| U-16 | win32crashhandler.cpp | `strcpy(modname, "Unknown")` bez bounds check | `strncpy(..., MAX_PATH - 1)` + null-terminate | LOW |

---

## ⚠️ ZASADA KLUCZOWA (przypomnienie)

> **Launcher NIGDY nie kompiluje gry.** Launcher pobiera GOTOWE, skompilowane paczki klienta z serwera (via manifest + API).  
> Pipeline kompilacji OTClient = OSOBNY workflow GHA (`build-client-package.yml`).  
> Launcher = **downloader + verifier + launcher**, NIE builder.

---

## ⚠️ SYNCHRONIZACJA Z RedDaxe.pl (z CZĘŚCI 2)

Bootstrap, Launcher i Client Package — wszystko musi być zsynchronizowane z RedDaxe.pl:
- `installer-catalog.php` → `?type=bootstrap|launcher|installer|all`
- Download pages → primary = bootstrap, secondary = portable ZIP
- `.env` → wersje, hashe SHA-256, URLs

---

## Po Instalce: Następne Kroki

Po zakończeniu CZĘŚCI 3 → przejście do:
- **Monitoring** — ops-dashboard (metryki tokenów, HMAC failures, update health)
- **Ed25519 signing** — Level 2 artifact signing (zastąpienie placeholder B-004)
- **Lua bytecode** — Layer 3 protection (`.lua → .luac` compilation)
- **Onboarding flow** — tutorial dla nowych graczy po first-run
