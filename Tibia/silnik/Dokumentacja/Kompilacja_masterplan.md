# KOMPILACJA — MASTER PLAN

Data utworzenia: 2026-03-22  
Branch: `feature/ticket-gate` (740 commitów ahead of `master`)  
Repo: `PtakuPL/ooo`  
Git root: `/home/ptaku/serweryt/`

---

## 1. Co kompilujemy

| # | Artefakt | Workflow GHA | Plik | Trigger |
|---|----------|-------------|------|---------|
| **C1** | **Serwer Canary (Linux)** | `Canary - Build` | `.github/workflows/build-canary.yml` | `workflow_dispatch` z brancha `feature/ticket-gate` |
| **C2** | **Klient OTClient (Linux)** | `Build - Linux (OTC Client)` | `.github/workflows/build-linux.yml` | `workflow_dispatch` z brancha `feature/ticket-gate` |
| **C3** | **Klient OTClient (Windows)** | `Build - Windows` | `.github/workflows/build-windows.yml` | `workflow_dispatch` z brancha `feature/ticket-gate` |
| **C4** | **Paczka gracza (Windows/linux)** | `build-client-package` | `.github/workflows/build-client-package.yml` | `workflow_dispatch` (version + channel) |
| **C5** | **Launcher Rust (Linux+Win)** | `Build Launcher` | `.github/workflows/build-launcher.yml` | push do `feature/ticket-gate` LUB `workflow_dispatch` |
| **C6** | **Bootstrap Launcher** | `Build Bootstrap Launcher` | `.github/workflows/build-bootstrap-launcher.yml` | push do `feature/ticket-gate` LUB `workflow_dispatch` |

### Serwer Canary = ten sam binary dla Classic 7.4 i Modern
- Różnica między serwerami to **config.lua** (worldId, serverName, porty)
- Blokady feature flags (D2-D10) działają na podstawie `gameMode` gracza
- Jeden build → dwa uruchomienia z różnymi configami

---

## 2. Kolejność kompilacji

```
KROK 1: Push na feature/ticket-gate
   └─ git add + commit + push (bez Dokumentacji)
   └─ Auto-trigger: build-launcher.yml, build-bootstrap-launcher.yml

KROK 2: Manual dispatch: build-canary.yml (serwer)
   └─ Czas: ~30-60 min
   └─ Artefakty: canary-ubuntu-22.04-linux-release, canary-ubuntu-24.04-linux-release

KROK 3: Manual dispatch: build-linux.yml (klient Linux)
   └─ Czas: ~60-120 min (vcpkg build)

KROK 4: Manual dispatch: build-windows.yml (klient Windows)
   └─ Czas: ~3-6h (Windows + vcpkg)

KROK 5: Manual dispatch: build-client-package.yml (paczka gracza)
   └─ Wymaga: version (np. "1.2.0"), channel ("dev" lub "stable")
   └─ Czas: ~3-6h (Windows build + packaging)

KROK 6: Po PASS — pobieramy artefakty i testujemy
```

---

## 3. Ścieżki źródeł w repo (względem git root)

| Komponent | Ścieżka |
|-----------|---------|
| Serwer Canary C++ | `Tibia/silnik/canary_test/src/` |
| Serwer CMake | `Tibia/silnik/canary_test/CMakeLists.txt` |
| Serwer vcpkg | `Tibia/silnik/canary_test/vcpkg.json` |
| Klient OTC C++ | `Tibia/silnik/canary_test/testyy/src/` |
| Klient CMake | `Tibia/silnik/canary_test/testyy/CMakeLists.txt` |
| Klient vcpkg | `Tibia/silnik/canary_test/testyy/vcpkg.json` |
| Klient Lua | `Tibia/silnik/canary_test/testyy/modules/`, `init.lua` |
| Klient customizations | `Tibia/silnik/canary_test/testyy/customizations/` |
| Launcher Rust | `Tibia/silnik/launcher-rust/` |
| Launcher Bootstrap | `Tibia/silnik/launcher-rust/apps/launcher-bootstrap/` |
| Workflows | `.github/workflows/` |

---

## 4. Problemy triggera brancha

| Workflow | Push trigger branches | workflow_dispatch |
|----------|----------------------|-------------------|
| `build-canary.yml` | `master`, `main` | ✅ TAK (dowolny branch) |
| `build-linux.yml` | `master`, `main` | ✅ TAK |
| `build-windows.yml` | brak (dispatch only) | ✅ TAK |
| `build-client-package.yml` | tagi `v*-client` | ✅ TAK (version+channel) |
| `build-launcher.yml` | `feature/ticket-gate` | ✅ TAK (profile) |
| `build-bootstrap-launcher.yml` | `feature/ticket-gate` | ✅ TAK (profile) |

**WNIOSEK**: Wszystkie workflows mają `workflow_dispatch` — możemy je odpalić ręcznie z brancha `feature/ticket-gate` bez mergowania do master.

---

## 5. Plan push

### Co pushujemy (kod):
- `canary_test/src/` — C++ serwera (ticket_validator, protocolgame, feature flags)
- `canary_test/testyy/` — C++ klienta + Lua + customizations
- `canary_test/html_copy/` — PHP API + migracje SQL
- `canary_test/config.lua.dist` — template konfiguracji
- `launcher-rust/` — cały launcher Rust
- `.github/workflows/` — pliki workflow GHA
- `run/` — skrypty testowe
- `smoke_test*.sh` — smoke testy

### Czego NIE pushujemy:
- `Dokumentacja/` — plany, opisy prac (nie wpływa na build)
- `canary_test/config.lua` — lokalna konfiguracja runtime (ma sekrety)
- `canary_modern/` — lokalna konfiguracja runtime
- `.env` — sekrety runtime
- `budowa_silnik/` — lokalne build artifacts
- `include-what-you-use/` — narzędzie lokalne
- `aplikacje/` — gotowe artefakty (ZIP)
- `client_pack/` — gotowe paczki

### Pliki do git add (nowe, nieśledzone):
- `canary_test/html_copy/apik/v1/game-profiles.php`
- `canary_test/html_copy/apik/v1/migrations/011_*.sql` (2 pliki)
- `canary_test/html_copy/apik/v1/migrations/012_*.sql` (2 pliki)
- `canary_test/html_copy/files/bootstrap/launcher-bootstrap-linux-x86_64.zip`
- `canary_test/html_copy/files/checksums.zip`
- `canary_test/testyy/custom-triplets/` (katalog)
- `canary_test/testyy/customizations/` (katalog)
- `launcher-rust/apps/launcher-tauri/src/session_store.rs`
- `run/k140_k142_static_audit.sh`
- `run/k182_env_contract_check.sh`
- `smoke_test_api.sh`, `smoke_test_e2e.sh`, `smoke_test_security.sh`

---

## 6. Kryteria sukcesu

| Artefakt | Kryteria PASS |
|----------|---------------|
| Serwer Canary | Binary `canary` w artefakcie + zero errors |
| Klient Linux | Binary `otclient` w artefakcie |
| Klient Windows | Binary `otclient.exe` w artefakcie |
| Paczka gracza | ZIP z `otclient.exe` + `init.lua` (CLIENT_LOCKED=true) + modules/ + data/ — BEZ plików .cpp/.h |
| Launcher | Binary `launcher-cli` + `launcher-tauri` (Linux+Windows) |
| Bootstrap | Binary `launcher-bootstrap` (Linux+Windows), rozmiar < 512KB |

---

## 7. Ryzyka i mitygacja

| Ryzyko | Prawdopodobieństwo | Mitygacja |
|--------|-------------------|-----------|
| vcpkg cache miss → długi build | ŚREDNIE | Cache GHA powinien zadziałać z previous runs |
| ICE (Internal Compiler Error) MSVC | NISKIE | Wyłączony IPO/LTCG w CMakeLists.txt |
| Nested .git dirs → checkout failure | ŚREDNIE | Workflow ma krok `Remove nested git directories` |
| Brak secrets na GHA | NISKIE | Build nie wymaga secretów (compile-only) |
| include-what-you-use w repo → checkout bloat | NISKIE | Pominąć w push (jest w .gitignore?) |
| Timeout 6h Windows | ŚREDNIE | Ustawiony w workflow |

---

## 8. Po udanej kompilacji

1. Pobrać artefakty z GHA (Actions → workflow run → Artifacts)
2. Serwer: `canary` binary → skopiować do `canary_test/` i `canary_modern/`
3. Klient: `otclient` / `otclient.exe` → do `canary_test/testyy/`
4. Paczka gracza: ZIP → do `client_pack/` LUB do serwera HTTP dla launchera
5. Launcher: `launcher-tauri` → do `canary_test/html_copy/files/launcher/`
6. Runtime smoke testy (login, create account, create character, ticket flow)
7. Aktualizacja checklisty `00_START_PRACY_CHECKLISTA.md`

---

## Status

| Krok | Status | Data | Uwagi |
|------|--------|------|-------|
| Push do ticket-gate | ⬜ TODO | — | — |
| C1: Canary build | ⬜ TODO | — | — |
| C2: OTC Linux build | ⬜ TODO | — | — |
| C3: OTC Windows build | ⬜ TODO | — | — |
| C4: Paczka gracza | ⬜ TODO | — | — |
| C5: Launcher build | ⬜ TODO | — | — |
| C6: Bootstrap build | ⬜ TODO | — | — |
| Smoke test post-build | ⬜ TODO | — | — |
