# Podsumowanie prac — branch `feature/ticket-gate`

**Data:** 2026-03-05  
**Branch:** `feature/ticket-gate`  
**Repo:** PtakuPL/ooo

---

## 1. Co zostało zrobione

### 1.1 Launcher Rust+Tauri — naprawy kompilacji

| Commit | Opis |
|--------|------|
| `9230171b5` | rustfmt + contract_tests + compilation errors + canary nlohmann_json |
| `ee2f50667` | clippy collapsible_if + manual_strip + test_infer_tags path fix |
| `ae6706ace` | 10 clippy errors + commands.rs ApiClientConfig type mismatch |
| `789cb4f52` | cargo fmt formatting + tempfile dev-dependency for helper |
| `a30670479` | 2 unused imports + cargo fmt + tempfile dev-dep |
| `dbc26ab4d` | 4 more clippy errors — map_identity, needless_return, ptr_arg, unused imports |
| `eb73803d9` | cargo fmt flow.rs line break style |
| `5f40af954` | clippy field_reassign_with_default w launcher_config tests |
| `e3b923f48` | manifest type + for_kv_map — unblock ubuntu/windows |
| `422472d45` | align acceptance manifest fixtures |
| `74574f49a` | unblock ubuntu edge-case tests + canary protocol/rsa build |

### 1.2 Launcher — naprawy kontraktów i bezpieczeństwa

| Commit | Opis |
|--------|------|
| `4aca821ed` | gap-fix: validation.rs, edge_case_tests.rs, grace period |
| `365fe958b` | FIX-GUARDS: Naprawa 11 błędów kompilacji w protocolgame.cpp |
| `d95e5ebb1` | FIX-AUDIT: Pełny audyt ticket-gate — workflows, SQL, PHP |
| `c895334f3` | DOC: Pełna dokumentacja audytu ticket-gate |
| `64733e25e` | FIX-CONTRACT: Synchronizacja Rust launcher ↔ PHP API |
| `ed62fab3c` | FIX-DEEP: sha256 Option<String> — Tauri guard + AT-008 test |

### 1.3 CI/CD — GitHub Actions

| Commit | Opis | Rozwiązany problem |
|--------|------|--------------------|
| `be1bfd8cd` | Launcher workflows w repo root | Workflows w `Tibia/silnik/.github/` były niewidoczne dla GHA — muszą być w `.github/workflows/` w root repo |
| `7f71615e0` | Dodaj Tauri system deps na Linux | `cargo build --all` (w tym launcher-tauri) wymagał `libwebkit2gtk-4.1-dev` na Ubuntu |
| `7c5ae6f8f` | Dodaj brakującą dep `tracing` | `common-models/Cargo.toml` brakowało `tracing = { workspace = true }` → `E0433` |
| `6151c29d3` | Trigger na feature/ticket-gate + fix ścieżek Tauri | Build nie triggerował się na nasz branch |
| `b6e9671ea` | Uproszczenie z 3 jobów do 1 joba | Zbędne 3 joby (build-core, build-tauri, build-helper) → 1 job `build` per platforma |
| `1ea68332c` | Override working-directory dla checksums | Job checksums nie mógł znaleźć artefaktów |

### 1.4 Tauri Frontend — ERR_CONNECTION_REFUSED

| Commit | Opis | Rozwiązany problem |
|--------|------|--------------------|
| `a46ca05d9` | frontendDist `../ui` → `./ui` | Ścieżka rozwiązywała się na `apps/ui/` (nie istnieje) zamiast `apps/launcher-tauri/ui/` |
| `f01b6871a` | Usunięto devUrl, dodano clean + Cargo.lock | 3 warstwy buga: (1) devUrl jako fallback na localhost:1420, (2) cache GHA nigdy się nie bustował bo Cargo.lock nie był w git, (3) stara binarka przeżywała rebuildy |

---

## 2. Wykryte problemy i ich rozwiązania

### 2.1 Workflows niewidoczne w GitHub Actions
- **Problem:** Pliki `.github/workflows/` umieszczone w `Tibia/silnik/.github/workflows/` — GitHub czyta TYLKO z roota repo
- **Rozwiązanie:** Przeniesienie do `/home/ptaku/serweryt/.github/workflows/` z dostosowaniem ścieżek (`launcher-rust/` → `Tibia/silnik/launcher-rust/`)

### 2.2 Nie można przełączyć na master (283 untracked files)
- **Problem:** `git checkout master` blokowane przez niezacommitowane pliki
- **Rozwiązanie:** Git plumbing (`hash-object` → `mktree` → `commit-tree` → `update-ref`) — edytowanie master bez przełączania branchy

### 2.3 Launcher-rust zniknął z WSL
- **Problem:** `git stash --include-untracked` z poprzedniej sesji usunął pliki z dysku
- **Rozwiązanie:** `git checkout HEAD -- Tibia/silnik/launcher-rust/` + `git stash pop`

### 2.4 Ubuntu build fail — brak Tauri deps
- **Problem:** `cargo build --all` kompiluje launcher-tauri który wymaga `libwebkit2gtk-4.1-dev` itp.
- **Rozwiązanie:** Krok `apt-get install` w workflow przed `cargo build`

### 2.5 E0433 — brak tracing dependency
- **Problem:** `common-models/Cargo.toml` nie miał `tracing` w `[dependencies]` mimo że `launcher_config.rs` używaj `tracing::warn!`
- **Rozwiązanie:** Dodanie `tracing = { workspace = true }`

### 2.6 Cache GHA never-busting
- **Problem:** `Cargo.lock` nie był w git → `hashFiles('Cargo.lock')` zwracał pusty string → zawsze ten sam cache key → stara binarka przeżywała rebuildy
- **Rozwiązanie:** Commit `Cargo.lock` do repo + `cargo clean -p launcher-tauri` w workflow

### 2.7 ERR_CONNECTION_REFUSED w launcherze
- **Problem:** Tauri nie embeddował frontendu w binarce → fallbackował na `devUrl: localhost:1420`
- **Przyczyna główna:** `frontendDist: "../ui"` (względem `tauri.conf.json`) rozwiązywało się na `apps/ui/` zamiast `apps/launcher-tauri/ui/`
- **Przyczyna dodatkowa:** `devUrl` nie powinien istnieć w release config
- **Rozwiązanie:** `frontendDist: "./ui"` + usunięcie `devUrl` + wymuszenie clean rebuild

### 2.8 Windows OTClient — vcpkg HTTP 503
- **Problem:** GitHub CDN zwracał HTTP 503 dla zlib przy budowie OTClient
- **Rozwiązanie:** Transient — wystarczy ponowić build

---

## 3. Obecna struktura workflow-ów

| Plik | Trigger | Cel |
|------|---------|-----|
| `.github/workflows/build-launcher.yml` | Push na `feature/ticket-gate` + workflow_dispatch | Build CLI + Tauri + Helper na Linux i Windows |
| `.github/workflows/launcher-ci.yml` | Push na `master`/`feature/ticket-gate` | CI: fmt, clippy, test, contract tests |
| `.github/workflows/release-launcher.yml` | Tag `v*` | Release: build + checksums + GitHub Release |

### build-launcher.yml — architektura po uproszczeniu
```
jobs:
  build (matrix: ubuntu + windows):
    cargo build --all → 3 binarki per platforma
    cargo test --all
    upload artifacts
  checksums:
    sha256sum wszystkich artefaktów
```

---

## 4. Pliki launchera w repo

```
Tibia/silnik/launcher-rust/
├── Cargo.toml              (workspace)
├── Cargo.lock              (teraz w git!)
├── apps/
│   ├── launcher-cli/       (CLI bez GUI — do automatyzacji)
│   ├── launcher-tauri/     (GUI launcher — Tauri v2.10.3)
│   │   ├── tauri.conf.json (frontendDist: "./ui")
│   │   ├── ui/             (index.html, app.js, style.css)
│   │   ├── capabilities/   (default.json)
│   │   ├── icons/
│   │   └── src/            (main.rs, commands.rs, state.rs)
│   └── launcher-helper/    (serwis tła — auto-update)
└── crates/
    ├── common-models/      (struktury danych, config, manifest)
    ├── launcher-api/       (klient HTTP do PHP API)
    └── launcher-core/      (logika: update, patcher, repair, HMAC)
```

---

## 5. Następne kroki — plan wdrożenia

### 5.1 Pilne — po potwierdzeniu że embed działa
- [ ] Pobrać nowy build, potwierdzić że launcher wyświetla UI
- [ ] Przetestować przyciski: "Uruchom grę", "Sprawdź aktualizacje"

### 5.2 Nowe funkcje launchera
- [ ] **Przycisk "Odwiedź stronę WWW"** — otwiera stronę Tibi w domyślnej przeglądarce
- [ ] **System i18n** — wielojęzyczność (plan w `2026-03-04_launcher_i18n_plan.md`)
  - Faza 1: Infrastruktura (rust-i18n crate + JSON tłumaczenia)
  - Faza 2: Bundled pl+en, reszta do pobrania z serwera
  - Faza 3: Pełny Unicode (CJK, Arabic/RTL, Devanagari)
  - Faza 4: API `/api/language-packs.php`
  - Faza 5: Spójność z serwerem Canary (53+ locale)
- [ ] **Przełączanie serwerów** — 14.20+ i 7.4 w jednym launcherze
- [ ] **Logo i branding** — design SerwerCanary

### 5.3 Dalekosiężne plany
- [ ] Launcher na Androida (Tauri v2 mobile)
- [ ] Obsługa wielu gier (CS 1.6 via Xash3D, Half-Life)
- [ ] Wspólne topki / sklep premium / statystyki gildii
- [ ] Unified account system (1 konto → wiele gier)

---

## 6. Pełna lista commitów na `feature/ticket-gate`

```
f01b6871a  fix(tauri): wymuś embed frontendu — usunięto devUrl, dodano clean + Cargo.lock
a46ca05d9  fix(tauri): frontendDist path ../ui → ./ui
b6e9671ea  CI: build-launcher — uproszczenie do 1 joba
1ea68332c  fix(ci): override working-directory for checksums job
74574f49a  fix(ci): unblock ubuntu edge-case tests and canary protocol/rsa build
422472d45  fix(tests): align acceptance manifest fixtures
e3b923f48  fix(ci): unblock ubuntu/windows launcher by manifest type + for_kv_map
5f40af954  fix(ci): clippy field_reassign_with_default in launcher_config tests
eb73803d9  fix(ci): cargo fmt flow.rs line break style
dbc26ab4d  fix(ci): 4 more clippy errors
a30670479  fix(ci): 2 unused imports + cargo fmt + tempfile dev-dep
789cb4f52  fix(ci): cargo fmt formatting + tempfile dev-dependency for helper
5e85571e3  fix(tests): add missing generatedAtUtc to integration test manifest fixture
fe4a426fb  fix(tests): contract_tests schema_version assertions
ae6706ace  fix(launcher): 10 clippy errors + commands.rs ApiClientConfig type mismatch
ee2f50667  fix(CI): clippy collapsible_if + manual_strip + test_infer_tags path fix
9230171b5  fix(CI): rustfmt + contract_tests + compilation errors + canary nlohmann_json
7c5ae6f8f  fix: common-models — dodaj brakującą dep tracing
7f71615e0  fix(CI): build-core — dodaj Tauri system deps na Linux
be1bfd8cd  CI: Launcher workflows w repo root (.github/workflows/)
6151c29d3  CI: build-launcher — trigger na feature/ticket-gate + fix ścieżek Tauri
ed62fab3c  FIX-DEEP: sha256 Option<String> — Tauri guard + AT-008 test
64733e25e  FIX-CONTRACT: Synchronizacja Rust launcher ↔ PHP API
c895334f3  DOC: Pełna dokumentacja audytu ticket-gate
d95e5ebb1  FIX-AUDIT: Pełny audyt ticket-gate — workflows, SQL, PHP
365fe958b  FIX-GUARDS: Naprawa 11 błędów kompilacji w protocolgame.cpp
4aca821ed  gap-fix: validation.rs, edge_case_tests.rs, grace period
```
