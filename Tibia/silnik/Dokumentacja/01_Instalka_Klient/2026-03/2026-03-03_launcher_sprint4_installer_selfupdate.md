# Sprint 4: Installer Integration + Self-Update + Release Workflows

**Data:** 2026-03-03  
**Branch:** `feature/ticket-gate`  
**Status:** KOMPLETNY (do commita)

---

## Zakres

Sprint 4 obejmuje:
- **Etap 3:** Integracja z instalatorem + Download Center (LR-041..046)
- **Etap 4:** Self-update launchera (LR-047..051)
- **Etap 7 (dokończenie):** Release workflows (LR-066..070)

---

## Zrealizowane zadania

### Etap 3 — Integracja z instalką

| ID | Zadanie | Wynik |
|---|---|---|
| LR-041 | Model instalatora bootstrap | `docs/contracts/installer-bootstrap.md` — pełna dokumentacja: 3-entity model (installer/launcher/client), flow, struktura katalogów, schemat `launcher_config.json`, wymagania (minimalność, idempotencja), wariant hybrydowy |
| LR-042 | Integracja instalki z launcherem | `crates/common-models/src/launcher_config.rs` — `LauncherConfig` struct z serde, walidacja, ładowanie z pliku, auto-discovery, rozwiązywanie ścieżek. 7 unit testów |
| LR-043 | Endpoint installer-catalog | `InstallerCatalogResponse` + `InstallerArtifact` w `api_responses.rs`, `fetch_installer_catalog()` w `launcher-api/client.rs` z walidacją kanału |
| LR-044 | Widok Download Center | Nowe sekcje `#screen-downloads` i `#screen-self-update` w `index.html`, CSS dla kart pobierania, JS: `loadDownloadCenter()`, `downloadArtifact()`, `checkSelfUpdate()`. 4 nowe komendy Tauri (łącznie 12) |
| LR-045 | Walidacja checksum instalek | `crates/launcher-core/src/artifact_verify.rs` — `verify_artifact()`, `verify_artifact_strict()`, `verify_artifact_file()` z `ArtifactVerifyResult`. 7 unit testów |
| LR-046 | Polityka podpisów artefaktów | `docs/contracts/artifact-signing-policy.md` — 3-poziomowy model: Level 1 SHA-256, Level 2 Ed25519 `.sig`, Level 3 Authenticode/GPG. Zarządzanie kluczami, rotacja, harmonogram |

### Etap 4 — Self-update

| ID | Zadanie | Wynik |
|---|---|---|
| LR-047 | `launcher-helper` crate | `crates/launcher-helper/` — standalone binary (~350 linii): `UpdateConfig`, CLI parser, `execute_self_update()` (wait PID → verify SHA-256 → backup → replace → restart → status JSON), platform-specific `replace_binary()` i `is_process_running()`, rollback on failure. 5 unit testów |
| LR-048 | Check launcher-version | `self_update.rs`: `check_launcher_version()` z semver — porównanie z `minVersion`, logika `required` |
| LR-049 | Download + verify self-update | `verify_self_update_package()` + `stage_self_update_package()` w `self_update.rs` |
| LR-050 | Restart po podmianie | `launch_helper()` + `build_self_update_plan()` — spawns helper z CLI args, launcher powinien się zamknąć |
| LR-051 | Rollback self-update | `check_for_rollback()` + `perform_rollback()` — detekcja z `update_status.json`, przywracanie backupu. 8 unit testów łącznie w `self_update.rs` |

### Etap 7 — Release Workflows

| ID | Zadanie | Wynik |
|---|---|---|
| LR-066 | `release-launcher.yml` | Workflow triggerowany tagiem `v*`: build CLI+Tauri+Helper na 2 platformach → checksums → catalog → GitHub Release |
| LR-067 | Auto-generate checksums.txt | Job `checksums-and-catalog` generuje `checksums.txt` z SHA-256 wszystkich artefaktów |
| LR-068 | Publikacja podpisów `.sig` | Placeholder w release body — podpisy dodawane ręcznie przez maintainera (per polityka LR-046) |
| LR-069 | `installer-catalog.json` z release | Automatyczna generacja JSON zgodnego ze schematem `InstallerCatalogResponse`, dołączany do release |
| LR-070 | Smoke check po release | Job `smoke-check`: weryfikacja istnienia release, count artefaktów ≥6, obecność `checksums.txt` i `installer-catalog.json` |

### CI Updates

- **`build-launcher.yml`:** Aktywowany job `build-helper` (wcześniej zakomentowany). Checksums job zależy teraz od build-core + build-tauri + build-helper
- **`launcher-ci.yml`:** Dodany test `launcher-helper` w job `contract-tests`

---

## Nowe pliki

```
launcher-rust/
  crates/
    common-models/src/launcher_config.rs       (LR-042)
    launcher-core/src/artifact_verify.rs        (LR-045)
    launcher-core/src/self_update.rs            (LR-048..051)
    launcher-helper/Cargo.toml                  (LR-047)
    launcher-helper/src/main.rs                 (LR-047)
  docs/contracts/
    installer-bootstrap.md                      (LR-041)
    artifact-signing-policy.md                  (LR-046)
.github/workflows/
  release-launcher.yml                          (LR-066..070)
```

## Zmodyfikowane pliki

```
launcher-rust/
  Cargo.toml                                    (uncommented launcher-helper)
  crates/common-models/src/lib.rs               (added launcher_config mod)
  crates/common-models/src/api_responses.rs     (InstallerCatalog structs)
  crates/launcher-api/src/client.rs             (fetch_installer_catalog)
  crates/launcher-core/src/lib.rs               (artifact_verify + self_update mods)
  apps/launcher-tauri/src/main.rs               (4 new commands, 12 total)
  apps/launcher-tauri/src/commands.rs           (4 new command handlers)
  apps/launcher-tauri/ui/index.html             (Download Center + self-update screens)
  apps/launcher-tauri/ui/style.css              (Download Center styles)
  apps/launcher-tauri/ui/app.js                 (Download Center + self-update JS)
.github/workflows/
  build-launcher.yml                            (enabled build-helper, updated deps)
  launcher-ci.yml                               (added helper tests)
Dokumentacja/.../launcher+rust2_zadania.md      (marked Sprint 4 tasks ✅)
```

---

## Statystyki

- Nowe pliki: 7
- Zmodyfikowane pliki: 13
- Nowe linie kodu (szacunkowo): ~2000+
- Unit testy: ~27 nowych (7+7+8+5)
- Tauri commands: 12 (z 8 → 12, +4 nowe)
- Rust crates: 6 (z 5 → 6, +launcher-helper)
- CI workflows: 3 (ci + build + release)

---

## Następny krok

**Sprint 5:** LR-052..061 (Hardening + Migracja/Rollout) + AT-001..015 (testy akceptacyjne).
