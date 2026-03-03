# Sprint 3 — Tauri UI v1 (kompletny)

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Kontekst:** Uzupełnienie Sprint 3 — po LR-064/065/079/080 (CI/DTO), teraz Tauri UI v1.

---

## Wykonane zadania

### LR-031: Utworzyć app Tauri
- Scaffold `apps/launcher-tauri/`:
  - `Cargo.toml` — zależności: tauri v2, common-models, launcher-api, launcher-core, tokio, uuid, semver
  - `build.rs` — `tauri_build::build()`
  - `tauri.conf.json` — okno 720x520, CSP, bundle config, identifier `pl.serwercanary.launcher`
  - `capabilities/default.json` — minimalne uprawnienia Tauri v2
  - `src/main.rs` — entry point, rejestracja 8 komend, tracing init
  - `src/state.rs` — `AppState` (Mutex) z client_dir, API URL, channel, wersja, flaga update
- Dodano crate do workspace `Cargo.toml` members

### LR-032: Podpiąć komendy z launcher-core
- `src/commands.rs` (~530 linii) — 8 Tauri command handlers:
  - `get_status` → `LauncherStatusDto` (faza, wersje, error, recovery)
  - `check_for_updates` → `UpdatePlanSummaryDto` (manifest → skan → plan)
  - `start_update` → `UpdateProgressDto` (download → stage → apply → finalize)
  - `launch_game` → token request → process_runner
  - `repair_installation` → `RepairDiagnosticsDto`
  - `get_installation_info` → `InstallationSummaryDto`
  - `change_channel` → walidacja stable/test/dev
  - `export_logs` → zbiera logi + state do TXT
- Wzorzec: thin wrapper, cała logika w launcher-core, zwraca DTO
- Guard `update_in_progress` zapobiega podwójnemu update

### LR-033: Ekran statusu
- `ui/index.html` — sekcja `#screen-status`
- `app.js` — `loadStatus()` wywołuje `get_status`, wyświetla wersje, kanał, fazę
- Badge'y kolorowe per status (ready=zielony, error=czerwony)

### LR-034: Ekran aktualizacji z progress barem
- `ui/index.html` — sekcja `#screen-update` z progress bar + info
- `app.js` — `startUpdate(plan)`, `updateProgress(dto)` — aktualizuje UI
- Stage labels: CheckingManifest, ScanningFiles, Downloading, Verifying, Applying, Finalizing, Done

### LR-035: Ekran startu gry
- Przycisk "▶ Uruchom grę" — aktywny tylko gdy `phase === "ready"`
- Click → `launch_game` → token → process_runner → feedback UI

### LR-036: Ekran błędów i diagnostyki
- Sekcja `#screen-error` z kodem LCH_*, komunikatem, przyciskiem retry
- `showError(message, code, retryable)` — nawigacja + wyświetlanie
- Ekran naprawy z diagnostyką (corrupted/missing/ok count)

### LR-037: Eksport logów
- Przycisk "Eksport logów" w stopce
- Backend zbiera pliki `.log` + `installed_state.json` do jednego TXT

### LR-038: Ustawienia
- Sekcja `#screen-settings` z select kanału (stable/test/dev)
- Backend `change_channel` z walidacją

### LR-039: Widok statusu API/serwera (read-only)
- Zintegrowane w ekranie statusu (wersja launchera, klienta, kanał, faza)
- `get_installation_info` → pełne podsumowanie

### LR-040: UX retry po błędzie
- Przycisk "🔄 Ponów" w ekranie błędu
- Wraca do statusu + automatycznie odpala `check_for_updates`

---

## Frontend UI

- Ciemny motyw gry (dark theme, kolory: #1a1a2e, accent #e94560)
- 5 ekranów: Status, Aktualizacja, Błąd, Naprawa, Ustawienia
- Nawigacja footer z 4 przyciskami
- Responsive (flexbox, media query <500px)
- Vanilla JS — zero frameworków, ~280 linii

---

## CI Updates

- `launcher-ci.yml` — dodano instalację webkit2gtk-4.1/librsvg2 na Ubuntu (potrzebne dla Tauri)
- `build-launcher.yml` — odkomentowano job `build-tauri` (build + upload artefaktu per platform)
- Checksums job zależy teraz od build-core + build-tauri

---

## Pliki utworzone/zmodyfikowane

| Plik | Operacja |
|------|----------|
| `apps/launcher-tauri/Cargo.toml` | NEW |
| `apps/launcher-tauri/build.rs` | NEW |
| `apps/launcher-tauri/tauri.conf.json` | NEW |
| `apps/launcher-tauri/capabilities/default.json` | NEW |
| `apps/launcher-tauri/src/main.rs` | NEW |
| `apps/launcher-tauri/src/state.rs` | NEW |
| `apps/launcher-tauri/src/commands.rs` | NEW (~530 linii) |
| `apps/launcher-tauri/ui/index.html` | NEW |
| `apps/launcher-tauri/ui/style.css` | NEW (~250 linii) |
| `apps/launcher-tauri/ui/app.js` | NEW (~280 linii) |
| `launcher-rust/Cargo.toml` | EDIT — aktywowano launcher-tauri |
| `.github/workflows/launcher-ci.yml` | EDIT — webkit2gtk deps |
| `.github/workflows/build-launcher.yml` | EDIT — aktywowano build-tauri job |
| `zadania.md` | EDIT — LR-031..040 ✅, Sprint 3 complete |

---

## Podsumowanie Sprint 3

| Element | Wartość |
|---------|---------|
| Sprint 3 zadania | **14/14** ✅ (LR-031..040 + LR-064 + LR-065 + LR-079 + LR-080) |
| Nowe pliki | 10 |
| Backend Rust (Tauri commands) | ~530 linii |
| Frontend (HTML+CSS+JS) | ~650 linii |
| Łącznie crate'ów | 5 (common-models, launcher-api, launcher-core, launcher-cli, launcher-tauri) |
| Łącznie testów | ~79 (40 unit + 13 contract + 13 integration + 13 DTO) |

---

## Następne kroki (Sprint 4)

- LR-041..LR-046: Integracja z instalką + Download Center
- LR-047..LR-051: Self-update launchera (helper binary)
- LR-066..LR-070: Release workflow + checksums + smoke check
- Push do GitHub + weryfikacja CI (po decyzji użytkownika)
