# Sprint 3 — CI matrix + build workflow + DTO + thin frontend

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Commit:** (do ustalenia po commicie — jeszcze NOT pushed)

---

## Wykonane zadania

### LR-064: CI matrix build Windows/Linux
- Rozszerzono `.github/workflows/launcher-ci.yml`:
  - Dodana strategia macierzowa: `ubuntu-latest` + `windows-latest`
  - Każda platforma ma target: `x86_64-unknown-linux-gnu` / `x86_64-pc-windows-msvc`
  - `fail-fast: false` — obie platformy budują się niezależnie
  - Cache cargo osobno per OS
  - Job `contract-tests` utrzymany na ubuntu-latest (wystarczający)
  - Dodano osobny step do uruchamiania integration_tests (launcher-core)

### LR-065: build-launcher.yml (release candidate workflow)
- Utworzono nowy `.github/workflows/build-launcher.yml`:
  - Trigger: `workflow_dispatch` (manual z wyborem profilu debug/release) + `push tags: v*-rc*`
  - Job `build-core`: macierz ubuntu+windows, buduje CLI binary, uploaduje artefakt
  - Job `checksums`: generuje `checksums.txt` z SHA-256 każdego artefaktu, uploaduje + GitHub Step Summary z tabelką
  - Joby `build-tauri` i `build-helper` — zakomentowane jako placeholdery (aktywowane po Sprincie z Tauri)
  - Specyfikacja zgodna z `launcher+rust.md` §6.2

### LR-079: Warstwa DTO statusów dla Tauri
- Utworzono moduł `crates/common-models/src/dto.rs`:
  - `LauncherPhase` enum (6 stanów: Checking/Updating/Ready/Repairing/Error/LauncherUpdateRequired)
  - `LauncherStatusDto` — pełny status dla UI (phase, wersje, error, launcher update info)
  - `UpdateProgressDto` — postęp aktualizacji (etap, pliki, bajty, procent, ETA)
  - `UpdateStage` enum (7 etapów: CheckingManifest → Done)
  - `ErrorInfoDto` — błąd user-facing z kodem LCH_*, `user_message`, flagą `retryable`
  - `LauncherUpdateDto` — info o wymaganej aktualizacji launchera
  - `RepairDiagnosticsDto` — wynik diagnostyki do UI
  - `InstallationSummaryDto` — uproszczony widok `InstalledState` (bez wrażliwych danych)
  - `UpdatePlanSummaryDto` — podsumowanie planu aktualizacji
  - Konwersje: `from_state()`, `from_plan()`, `from_api_response()`, `from_code()`
  - **13 testów** weryfikujących serde, procent, retryable, roundtrip

### LR-080: Thin frontend security (dokument)
- Utworzono `launcher-rust/docs/thin-frontend-security.md`:
  - Reguły: frontend = czysto UI, komunikacja przez Tauri Commands
  - Tabela zdefiniowanych komend (get_status, check_for_updates, start_update, launch_game, repair, itp.)
  - DTO jako jedyny kontrakt z frontem
  - Tauri allowlist: fs/http/shell wyłączone, sieć tylko przez Rust
  - Walidacja na granicy, brak sekretów w UI
  - Diagram przepływu architekturalny

---

## Podsumowanie statystyk

| Metryka | Wartość |
|---------|---------|
| Zadania Sprint 3 zrobione | 4 / 14 (LR-064, LR-065, LR-079, LR-080) |
| Pozostało Sprint 3 | LR-031..LR-040 (Tauri UI v1) |
| Nowe pliki | 3 (`build-launcher.yml`, `dto.rs`, `thin-frontend-security.md`) |
| Zmodyfikowane pliki | 2 (`launcher-ci.yml`, `lib.rs`) |
| Nowe testy DTO | 13 |
| Łącznie testów | ~79 (40 unit + 13 contract + 13 integration + 13 DTO) |

---

## Pliki zmienione/utworzone

| Plik | Operacja |
|------|----------|
| `.github/workflows/launcher-ci.yml` | EDIT — matrix Ubuntu+Windows, integration tests |
| `.github/workflows/build-launcher.yml` | NEW — build RC workflow |
| `crates/common-models/src/dto.rs` | NEW — warstwa DTO (13 testów) |
| `crates/common-models/src/lib.rs` | EDIT — dodano `pub mod dto` |
| `docs/thin-frontend-security.md` | NEW — dokument bezpieczeństwa UI |

---

## Następne kroki

- LR-031..LR-040: Tauri UI v1 (wymaga setup Tauri + Node.js na GHA)
- Sprint 4: LR-041..LR-051 (integracja z instalką + self-update)
- Push do GitHub + weryfikacja CI na obu platformach (po decyzji użytkownika)
