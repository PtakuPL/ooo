# Plan zadań PRZED kompilacją — przygotowanie kodu
**Data**: 2026-03-05  
**Status**: ⚠️ HISTORYCZNY — zastapiony planem dnia `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md`  
**Zasada**: Najpierw WSZYSTKIE zadania z tej listy, potem dopiero push + kompilacja na GHA.  
**WWW**: Strona www NIE wymaga kompilacji — zajmuje się nią Codex (pomijamy).

> Uwaga (2026-03-06): po wykryciu nowych problemow runtime (i18n/legacy routes/account flow) ten dokument traktujemy jako archiwalny snapshot. Aktualna kolejka przed kompilacja jest w `07_PLAN_JUTRO_DZIEN_KOMPILACJI.md` oraz `00_START_PRACY_CHECKLISTA.md` (K80-K89).

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

### GRUPA A — Kod launchera (Rust) — ✅ PRZEJRZANE I ZACOMMITOWANE

32 pliki w `launcher-rust/` — przejrzane, commitnięte jako `6421c9631`.

| # | Zadanie | Status | Uwagi |
|---|---|---|---|
| A-1 | commands.rs (Tauri) | ✅ | +352 linii: pre_launch_check, language_packs, error_report, channel/signature |
| A-2 | state.rs + main.rs | ✅ | config+config_path persistence, signature_public_key, language |
| A-3 | UI: app.js, index.html, style.css | ✅ | i18n (5 locale: pl/en/ar/he/fa), RTL, IDs for localization |
| A-4 | api_responses.rs + dto.rs | ✅ | LanguagePacksResponse, ErrorReport, PreLaunchCheckDto, i18n keys |
| A-5 | launcher_config.rs | ✅ | +language, +manifest_public_key, discover_with_path(), walidacja |
| A-6 | manifest.rs + fixture | ✅ | critical_files, login_port/game_port, testy |
| A-7 | client.rs — API client | ✅ | +542 linii: fetch_manifest_with_signature, language_packs, error_report, challenge validation |
| A-8 | Nowe moduły core | ✅ | font_pack_download, language_pack_download (zip), integrity.verify_critical_files |
| A-9 | Cargo.toml + lock | ✅ | +zip crate, +.cargo/config.toml (blokada lokalnych buildów), 6 ZIP artefaktów usunięte ze stage |
| A-10 | Commit | ✅ | `6421c9631` — 32 pliki, 4217+/155- |

### GRUPA B — Kod serwera Canary — ✅ PRZEJRZANE I ZACOMMITOWANE

13 plików w `canary/` — przejrzane, commitnięte jako `a02e74725`.
**Główna zmiana**: usunięcie inline ticket-gate + Classic 7.4 blocking z canary/ (clean reference).

⚠️ **WAŻNE**: `canary_test/` (kompilowany na GHA) nadal ma ticket-gate — to zamierzone!

| # | Zadanie | Status | Co zmieniono |
|---|---|---|---|
| B-1 | protocolgame.cpp/.hpp | ✅ | -166 linii: usunięto TicketValidator, isClassic74Blocked, pendingGameMode, blokady rune/market/prey/wheel |
| B-2 | game.cpp | ✅ | -14 linii: usunięto rate-limit ruchu Classic 7.4 |
| B-3 | config_enums + configmanager | ✅ | Usunięto TICKET_GATE_ENABLED, TICKET_SECRET |
| B-4 | player.hpp + creatures_definitions | ✅ | Usunięto PlayerGameMode_t, gameMode_, isClassic74(), lastMoveTime_ |
| B-5 | server/CMakeLists.txt | ✅ | Usunięto ticket_validator.cpp z buildu (pliki nadal na dysku) |
| B-6 | CMakeLists.txt + config.lua.dist | ✅ | +GHA guard, +porty doc, -ticketGateEnabled/ticketSecret |
| B-7 | Commit | ✅ | `a02e74725` — 13 plików, 439+/226- |

### GRUPA C — Instalka OTClient (testyy) — ✅ PRZEJRZANE I ZACOMMITOWANE

4 pliki — commitnięte jako `b98d6521d`.

| # | Zadanie | Status | Uwagi |
|---|---|---|---|
| C-1 | build-client-package.yml | ✅ | 538 linii: Windows+Linux, manifest gen, Ed25519 signing, checksums |
| C-2 | deploy-client.sh + generate-ed25519-keys.sh | ✅ | OK — deploy z cleanup starych wersji, key gen z DER extraction |
| C-3 | OTClient source | ✅ | Brak zmian w src/ — kompilacja nie powinna się zmienić |
| C-4 | Commit | ✅ | `b98d6521d` — 4 pliki, 731+ |

### GRUPA D — Konfiguracja i API (PHP) — ✅ SPRAWDZONE

| # | Zadanie | Status | Uwagi |
|---|---|---|---|
| D-1 | .env spójność | ✅ | Dev OK: porty 7172/7174, TICKET_SECRET jest, LAUNCHER_VERSION=1.0.0 |
| D-2 | launcher-version.php vs Cargo.toml | ✅ | .env=1.0.0, Cargo=0.1.0 — po kompilacji trzeba zsyncować |
| D-3 | generate_manifest.php | ✅ | Przetestowane wcześniej (TOR C) — OK |
| D-4 | login.php routing | ✅ | Przetestowane wcześniej (TOR A) — classic→7172, modern→7174 |
| D-5 | launcher_config.json | ✅ | **NAPRAWIONE**: dodano `language`, zmieniono apiBaseUrl na prod |

### GRUPA E — Pliki konfiguracyjne klienta — ✅ SPRAWDZONE

| # | Zadanie | Status | Uwagi |
|---|---|---|---|
| E-1 | init.lua | ✅ | CLIENT_LOCKED=true, GameModes classic74+modern, porty dev=127.0.0.1 |
| E-2 | config.lua serwery | ✅ | Classic worldId=0 port 7171/7172, Modern worldId=1 port 7173/7174 |
| E-3 | config.lua.dist | ✅ | Usunięto ticketGateEnabled/ticketSecret, dodano doc portów |

### GRUPA F — Dokumentacja — ✅ GOTOWE

| # | Zadanie | Status | Uwagi |
|---|---|---|---|
| F-1 | Dziennik + plan | ✅ | `b9cdaa4a5` — dziennik + plan przed kompilacją |
| F-2 | Wersje do kompilacji | ✅ | Sekcja 5 tego dokumentu |
| F-3 | Procedura testu | ✅ | Sekcja 3 tego dokumentu |

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
