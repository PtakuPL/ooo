# Plan zadań PRZED kompilacją — przygotowanie kodu
**Data**: 2026-03-05  
**Status**: ⏳ Do realizacji  
**Zasada**: Najpierw WSZYSTKIE zadania z tej listy, potem dopiero push + kompilacja na GHA.  
**WWW**: Strona www NIE wymaga kompilacji — zajmuje się nią Codex (pomijamy).

---

## 0. Co kompilujemy i gdzie

| Artefakt | Źródło | Workflow GHA | Output |
|---|---|---|---|
| **Serwer Canary** (canary_test) | `canary_test/src/` + `canary_test/CMakeLists.txt` | `build-ubuntusr.yml` (Linux), `build-windowssr.yml` (Windows) | `canary` / `canary.exe` |
| **Instalka testowa** (OTClient dev) | `canary_test/testyy/src/` + CMake | `build-windows.yml` (w root `.github/`) | `otclient.exe` — ta sama co do testów |
| **Instalka dla graczy** (OTClient package) | `canary_test/testyy/` + customizacje | `build-client-package.yml` (w testyy `.github/`) | ZIP z czystą paczką klienta bez plików dev |
| **Launcher CLI** | `launcher-rust/apps/launcher-cli/` | `build-launcher.yml` | `launcher-cli` / `launcher-cli.exe` |
| **Launcher Tauri** (UI) | `launcher-rust/apps/launcher-tauri/` | `build-launcher.yml` (Tauri step) | `launcher-tauri` / `launcher-tauri.exe` |

---

## 1. Pytanie: Czy potrzebujemy instalator?

**Odpowiedź: NIE na ten moment.**

Wrzucenie skompilowanego launchera + plików konfiguracyjnych do folderu na Windows = **już zainstalowane**. Launcher sam pobierze/zaktualizuje pliki klienta.

**Flow "instalacji" dla gracza:**
1. Gracz rozpakowuje ZIP (`TwojaGra-v1.0.0.zip`) do folderu
2. W środku: `launcher.exe` + `launcher_config.json` + pusty folder `client/`
3. Gracz uruchamia `launcher.exe`
4. Launcher pobiera pliki klienta z serwera (manifest → download)
5. Po pobraniu — przycisk "Graj" uruchamia `otclient.exe`

**Na później (opcjonalnie):**
- Instalator NSIS/Inno Setup — ale to kosmetyka, nie blokuje testów
- Wystarczy ZIP + launcher — launcher SAM jest instalatorem (pobiera pliki)

---

## 2. Zadania do wykonania PRZED kompilacją

### GRUPA A — Kod launchera (Rust) — niezacommitowane zmiany

Mamy 23 zmienione pliki w `launcher-rust/` (niezacommitowane). Trzeba je przejrzeć i upewnić się, że wszystko działa logicznie:

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| A-1 | Przejrzeć zmiany w `commands.rs` (Tauri) — 352+ linii zmian | `launcher-tauri/src/commands.rs` | ⬜ |
| A-2 | Przejrzeć zmiany w `state.rs` + `main.rs` (Tauri) | `launcher-tauri/src/state.rs`, `main.rs` | ⬜ |
| A-3 | Przejrzeć UI: `app.js`, `index.html`, `style.css` | `launcher-tauri/ui/` | ⬜ |
| A-4 | Przejrzeć `api_responses.rs` + `dto.rs` — nowe typy API | `common-models/src/` | ⬜ |
| A-5 | Przejrzeć `launcher_config.rs` — rozszerzenie configu | `common-models/src/launcher_config.rs` | ⬜ |
| A-6 | Przejrzeć `manifest.rs` + fixture JSON | `common-models/src/manifest.rs` | ⬜ |
| A-7 | Przejrzeć `client.rs` — 542+ linii zmian w API client | `launcher-api/src/client.rs` | ⬜ |
| A-8 | Przejrzeć nowe moduły core: `hmac_rotation`, `integrity`, `manifest_signature`, `planner`, `serverlist_sync` | `launcher-core/src/` | ⬜ |
| A-9 | Sprawdzić `Cargo.toml` + `Cargo.lock` — nowe zależności | `launcher-rust/Cargo.toml` | ⬜ |
| A-10 | Commitnąć wszystkie zmiany launchera jako logiczny commit | git | ⬜ |

### GRUPA B — Kod serwera Canary — niezacommitowane zmiany

Zmienione pliki w `canary/`:

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| B-1 | Przejrzeć `protocolgame.cpp/.hpp` — ticket-gate/HMAC logika | `canary/src/server/network/protocol/` | ⬜ |
| B-2 | Przejrzeć `game.cpp` — zmiany w logice gry | `canary/src/game/game.cpp` | ⬜ |
| B-3 | Przejrzeć `config_enums.hpp` + `configmanager.cpp` — nowe configi | `canary/src/config/` | ⬜ |
| B-4 | Przejrzeć `player.hpp` + `creatures_definitions.hpp` | `canary/src/creatures/` | ⬜ |
| B-5 | Przejrzeć `server/CMakeLists.txt` — zmiany w buildzie | `canary/src/server/CMakeLists.txt` | ⬜ |
| B-6 | Przejrzeć `canary/CMakeLists.txt` + `config.lua.dist` | `canary/` root | ⬜ |
| B-7 | Commitnąć zmiany serwera | git | ⬜ |

### GRUPA C — Instalka OTClient (testyy) — nowe pliki

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| C-1 | Przejrzeć `build-client-package.yml` — workflow dla paczki graczy | `testyy/.github/workflows/` | ⬜ |
| C-2 | Przejrzeć `deploy-client.sh` + `generate-ed25519-keys.sh` — nowe narzędzia | `testyy/tools/` | ⬜ |
| C-3 | Upewnić się, że OTClient source kompiluje się poprawnie (sprawdzić CMakeLists, src zmiany) | `testyy/` | ⬜ |
| C-4 | Commitnąć nowe pliki instalki | git | ⬜ |

### GRUPA D — Konfiguracja i API (PHP)

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| D-1 | Sprawdzić spójność `.env` (wersje, porty, ścieżki) — czy prod-ready | `/var/www/html/apik/v1/.env` | ⬜ |
| D-2 | Sprawdzić `launcher-version.php` — czy wersja launchera match z Cargo.toml | API | ⬜ |
| D-3 | Sprawdzić `generate_manifest.php` — czy poprawnie generuje manifest dla nowej paczki | API | ⬜ |
| D-4 | Sprawdzić `login.php` — routing classic/modern z ticket-gate HMAC | API | ⬜ |
| D-5 | Upewnić się, że `launcher_config.json` w player_package ma poprawne URL-e (prod) | `player_package/` | ⬜ |

### GRUPA E — Pliki konfiguracyjne klienta

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| E-1 | Sprawdzić `init.lua` — konfiguracja klienta (serwery, tryby, CLIENT_LOCKED) | `client_pack/1.1.0/init.lua` lub `testyy/init.lua` | ⬜ |
| E-2 | Sprawdzić `config.lua` serwera (Classic + Modern) — porty, worldId, klucze HMAC | `canary_test/config.lua`, `canary_modern/config.lua` | ⬜ |
| E-3 | Sprawdzić `config.lua.dist` w `canary/` — template z nowymi opcjami | `canary/config.lua.dist` | ⬜ |

### GRUPA F — Dokumentacja (przed kompilacją)

| # | Zadanie | Plik(i) | Status |
|---|---|---|---|
| F-1 | Zaktualizować dziennik o ten plan | `01_DZIENNIK_PRAC.md` | ⬜ |
| F-2 | Spisać DOKŁADNIE jakie wersje będziemy kompilować (serwer, instalka, launcher) | ten dokument | ⬜ |
| F-3 | Opisać procedurę testu: "zmień 1 tłumaczenie/klucz → kompiluj → sprawdź czy launcher wykryje" | ten dokument | ⬜ |

---

## 3. Plan testu po kompilacji — "Czy launcher wykryje zmianę?"

### Scenariusz testowy:

```
KROK 1: Kompilacja bazowa
  - Kompiluj wszystko (serwer, instalka, launcher) na GHA → artefakty v1.0.0
  - Wrzuć na Windows (testy-kopia otclient)
  - Wygeneruj manifest v1.0.0 z hashami plików

KROK 2: Zmiana testowa
  - Zmień JEDNĄ rzecz w kodzie C++ (np. jeden string tłumaczenia lub klucz w config)
  - Przykłady co zmienić:
    a) Tłumaczenie w instalce: init.lua — zmień np. "Welcome" → "Witaj"
    b) Klucz w C++ serwera: zmień np. HMAC_SECRET w config_enums.hpp
    c) Plik klienta: zmień wersję w meta.lua lub dodaj linię w init.lua
  
KROK 3: Kompilacja zmieniona
  - Kompiluj TYLKO zmieniony artefakt (np. instalka) → artefakt v1.0.1
  - Wygeneruj nowy manifest v1.0.1 z nowymi hashami
  - Umieść na serwerze (API zwraca v1.0.1)

KROK 4: Test launchera na Windows
  - Uruchom launcher (testy-kopia otclient)
  - Launcher sprawdza wersję → widzi v1.0.1 > v1.0.0
  - Launcher porównuje hashe → widzi różnicę w 1 pliku
  - Launcher pobiera zmieniony plik
  - Gracz klika "Graj" → gra startuje z nowym plikiem

KROK 5: Weryfikacja
  - ✅ Launcher wykrył nową wersję
  - ✅ Launcher pobrał TYLKO zmieniony plik (nie wszystko)
  - ✅ Gra działa po aktualizacji
  - ✅ Hash plików po update = hash w manifeście
```

---

## 4. Kolejność kompilacji na GHA

```
1. Serwer Canary (canary_test)
   ├── Ubuntu:  build-ubuntusr.yml  → canary (Linux)
   └── Windows: build-windowssr.yml → canary.exe (Windows)

2. Instalka OTClient — testowa (ta co zawsze)
   └── Windows: build-windows.yml (root .github/) → otclient.exe

3. Instalka OTClient — paczka graczy (czysta)
   └── Windows: build-client-package.yml (testyy .github/) → ZIP

4. Launcher Rust (CLI + Tauri)
   └── build-launcher.yml → launcher-cli + launcher-tauri (Linux + Windows)
```

---

## 5. Wersje do kompilacji

| Artefakt | Wersja | Źródło wersji |
|---|---|---|
| Serwer Canary | 3.2.0+ | `canary_test/CMakeLists.txt` |
| Instalka OTClient | 1.1.1 | manifest + `init.lua` |
| Paczka graczy OTClient | 1.0.0 | `build-client-package.yml` input |
| Launcher Rust | 0.1.0 → 0.2.0? | `launcher-rust/Cargo.toml` |

---

## 6. Co NIE robimy teraz

- ❌ Strona WWW — Codex się nią zajmuje
- ❌ Instalator NSIS/Inno Setup — launcher SAM pobiera pliki, ZIP wystarczy
- ❌ Build na lokalnym WSL — WSZYSTKO przez GHA
- ❌ Push na GHA — dopóki nie skończymy WSZYSTKICH zadań z tej listy
