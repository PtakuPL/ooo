# Launcher Rust — Sprint 2 uzupełnienie + Sprint 3 początek

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Poprzedni commit:** `5c11b4490` (Sprint 2 core)

## Wykonane zadania

### LR-026: CLI flow app (`apps/launcher-cli`)
Pełna aplikacja CLI z orkiestracją flow `check → update → hash → token → launch`.

**Pliki:**
- `apps/launcher-cli/Cargo.toml` — nowy crate binarny
- `apps/launcher-cli/src/main.rs` — punkt wejścia, routing komend
- `apps/launcher-cli/src/cli.rs` — parser argumentów (bez clap, ręczny)
- `apps/launcher-cli/src/flow.rs` — pełna logika: update, repair, status, check, hash

**Komendy CLI:**
- `run` — pełny flow: check → update → hash → token → launch
- `update` — tylko aktualizacja (bez startu klienta)
- `repair` — diagnoza + naprawa uszkodzonych plików
- `status` — wyświetl installed_state.json
- `check` — sprawdź wersję launchera na serwerze
- `hash` — oblicz filesHash z lokalnych plików

**Testy CLI:** 3 testy parsera, 5 testów helpersów (chrono_utc_now, days_to_ymd, resolve_launcher_data)

### LR-010: Testy kontraktowe API
13 testów weryfikujących zgodność modeli serde z zamrożonymi kontraktami.

**Pliki:**
- `crates/common-models/tests/contract_tests.rs` — 13 testów
- `tests/contracts/fixtures/` — 5 plików fixture JSON

**Pokrycie kontraktów:**
- LR-001: launcher-version response (full + minimal + roundtrip)
- LR-003: launch-token response, error, request (camelCase verify)
- LR-005: manifest v1/v2 parse + normalized
- LR-006: installed_state full schema + roundtrip + enum serde names
- LR-007: error codes (21 LCH_* codes + user_message)
- LR-008: overwrite/delete policy serde
- file action enum serde

### LR-030: Testy integracyjne
13 scenariuszy testowych (launcher-core integration tests).

**Plik:** `crates/launcher-core/tests/integration_tests.rs`

**Scenariusze:**
1. Fresh install — plan pobierania obu plików
2. Up to date — zero download
3. Partial update — jeden plik zmieniony
4. Stage + apply + verify flow
5. Hash mismatch — odrzucenie pliku
6. Rollback po błędnym update
7. Recovery detection po crash
8. State persistence roundtrip
9. filesHash deterministyczny + zmiana po modyfikacji
10. Repair diagnoza — korumpowany plik
11. Repair diagnoza — brakujący plik
12. Serverlist sync (Lua + JSON)
13. Delete action w manifeście

## Zmiany infrastrukturalne
- `Cargo.toml` (workspace) — dodano `apps/launcher-cli` do members
- `common-models/api_responses.rs` — dodano `Deserialize` do `LaunchTokenRequest` (potrzebne dla contract tests)

## Podsumowanie

Sprint 2 jest teraz **w pełni ukończony**:
- ✅ LR-004..LR-030 (wszystkie 27 zadań)
- ~66 testów łącznie (40 unit + 13 contract + 13 integration)
- 4 crate'y: common-models, launcher-api, launcher-core, launcher-cli

Gotowe do Sprint 3 (Tauri UI / CI matrix).
