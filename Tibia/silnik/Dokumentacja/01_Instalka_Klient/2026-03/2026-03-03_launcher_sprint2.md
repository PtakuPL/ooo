# Launcher Rust — Sprint 2 implementacja

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Poprzedni commit:** `28499ce41` (Sprint 1)

## Co zrobiono

### Etap 0 — uzupełnienie kontraktów
- **LR-004**: Opisano kontrakt `installer-catalog.php` — endpoint zwracający artefakty
  do pobrania dla Windows/Linux/Android z hashami SHA-256.
  Plik: `launcher-rust/docs/contracts/installer-catalog.md`

### Etap 1 — pełna implementacja launcher-core i launcher-api

#### launcher-api (LR-013, LR-015, LR-023)
- Pełna implementacja klienta HTTP z reqwest:
  - `check_launcher_version()` — GET `launcher-version.php`
  - `fetch_manifest()` — GET `update.php?channel=...` + parse v1/v2
  - `request_launch_token()` — POST `launcher-token.php`
  - `download_file()` — pobieranie pliku z retry (exponential backoff)
  - `get_with_retry()` — helper GET z retry
- Obsługa rate-limit (429), TLS warning, timeout
- 3 testy (config default, URL building)

#### launcher-core — nowe moduły

**file_index (LR-016)**
- `LocalFileIndex` — skan lokalnych plików z hashami SHA-256
- `scan_from_manifest()` — skan wg listy plików z manifestu
- `scan_full_directory()` — pełny skan katalogu (do repair/orphan)
- `matches_hash()` — sprawdzenie zgodności hash
- 4 testy

**planner (LR-018)**
- `build_update_plan()` — generuje deterministyczny UpdatePlan z manifestu vs lokalne pliki
- Obsługuje overwrite policies: always, if_hash_differs, never, preserve_user
- Obsługuje action=file, delete, mkdir, noop
- `resolve_file_url()` — base_url + relative URL resolution
- 6 testów (all new, up-to-date, delete, preserve_user, never, URL resolve)

**patcher (LR-019, LR-020, LR-021, LR-022)**
- `PatchContext` — zarządzanie staging/backup/state paths
- `verify_downloaded_file()` — weryfikacja SHA-256 po pobraniu
- `stage_file()` — zapis do staging po weryfikacji hash
- `backup_file()` — kopia zapasowa przed podmianą
- `apply_staged_file()` — atomowa podmiana staging → docelowy
- `apply_plan()` — kompletny flow: backup → apply → delete
- `rollback()` — przywracanie z backupu po błędzie
- `check_recovery_needed()` — wykrywanie przerwanego update
- `update_managed_index()` — aktualizacja indeksu managed files
- 5 testów (verify OK/mismatch, stage+apply, backup+rollback, cleanup, recovery)

**process_runner (LR-024)**
- `launch_client()` — uruchamia klienta z OTC_LAUNCH_TOKEN w env
- `launch_client_and_wait()` — wariant z czekaniem (do testów)
- Token WYŁĄCZNIE przez zmienną środowiskową (zgodnie z planem)
- 2 testy (client not found, launch /bin/true na Linux)

**serverlist_sync (LR-025)**
- `sync_serverlist()` — generuje plik Lua z listą serwerów
- `sync_serverlist_json()` — alternatywny format JSON
- Atomowy zapis (tmp → rename)
- Pomija ukryte/wyłączone serwery (visible=false/enabled=false)
- 5 testów (generate lua, sync file, empty, escape, json)

**repair (LR-028)**
- `diagnose_installation()` — pełny skan + raport diagnostyczny
- `RepairDiagnostics` — corrupted/missing/orphan/ok files + bytes do naprawy
- Generuje plan naprawy z wykorzystaniem standardowego plannera
- 3 testy (empty dir, corrupted file, orphan detection)

### Dokumentacja
- Zaktualizowano `launcher+rust2_zadania.md` — wszystkie zrobione zadania oznaczone ✅
- Plan sprintów zaktualizowany z faktycznym postępem

## Co pozostaje (Sprint 2 niedokończone)
- **LR-026**: CLI flow `check→update→token→launch` — wymaga app launcher-cli
- **LR-030**: Testy integracyjne z fake API — wymaga mockowania HTTP

## Podsumowanie plików
| Plik | Typ | Nowy/Zmieniony |
|---|---|---|
| `docs/contracts/installer-catalog.md` | Kontrakt | Nowy |
| `crates/launcher-api/src/client.rs` | Implementacja | Zmieniony (stub → pełna) |
| `crates/launcher-core/src/lib.rs` | Moduł | Zmieniony (dodane 6 modułów) |
| `crates/launcher-core/src/file_index.rs` | Implementacja | Nowy |
| `crates/launcher-core/src/planner.rs` | Implementacja | Nowy |
| `crates/launcher-core/src/patcher.rs` | Implementacja | Nowy |
| `crates/launcher-core/src/process_runner.rs` | Implementacja | Nowy |
| `crates/launcher-core/src/serverlist_sync.rs` | Implementacja | Nowy |
| `crates/launcher-core/src/repair.rs` | Implementacja | Nowy |

## Notatki
- Kompilacja weryfikowana wyłącznie na GitHub Actions (nie lokalnie na WSL)
- Commit jeszcze nie pushowany — czekamy na zielone światło od usera
