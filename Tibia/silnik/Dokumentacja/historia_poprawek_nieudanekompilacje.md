# Historia poprawek i nieudanych kompilacji

Data utworzenia: 2026-03-22  
Branch: `feature/ticket-gate`  
Repo: `PtakuPL/ooo`

> Ten plik dokumentuje KAŻDĄ próbę kompilacji — zarówno udaną jak i nieudaną.
> Dla każdego błędu: dokładna diagnoza, plik, linia, poprawka, commit.

---

## Format wpisów

```
### [DATA] [WORKFLOW] — [PASS/FAIL]
- **GHA Run**: #ID / URL
- **Branch**: feature/ticket-gate @ commit HASH
- **Czas**: X min
- **Wynik**: PASS / FAIL

#### Błędy (jeśli FAIL):
1. **[PLIK:LINIA]** — opis błędu
   - Komunikat: `...`
   - Diagnoza: ...
   - Poprawka: ... (commit HASH)
   
#### Artefakty (jeśli PASS):
- `nazwa-artefaktu` — rozmiar, SHA256
```

---

## Próby kompilacji

### Poprzednie udane kompilacje (historia)
- **GHA #22717070014** — Canary Linux (commit `652c0e033`) — ✅ PASS
  - Ubuntu 22.04 + 24.04, linux-release + linux-debug: wszystkie 4 warianty PASS
  - Artefakt serwera Canary dostępny i przetestowany

---

### [2026-03-22] Przygotowanie do kompilacji
- ⬜ Oczekuje na push kodu do `feature/ticket-gate`
- Zmiany od ostatniej kompilacji:
  - ticket_validator.cpp/hpp — nonce replay + worldId check
  - protocolgame.cpp — feature flags D2-D10
  - httplogin.cpp — TLS hard-fail, usunięcie HTTP fallback
  - Lua: entergame.lua, serverlist.lua, characterlist.lua, init.lua
  - 20+ plików PHP API (login, ticket, account-context, etc.)
  - 12 migracji SQL
  - Launcher Rust — 33 komend, session store, i18n
  - Workflows GHA — build-canary, build-linux, build-windows, build-client-package, build-launcher

---

### [2026-03-22] Push + trigger ALL workflows
- **Commit**: `fcb62b6c2` (75 files, +7320/-973)
- **Branch**: `feature/ticket-gate` → pushed to `origin`
- **Workflows triggered**:
  1. `Canary - Build` (serwer Linux) — `workflow_dispatch`
  2. `Build - Linux (OTC Client)` — `workflow_dispatch`
  3. `Build - Windows` (klient Windows) — `workflow_dispatch`
  4. `build-client-package` v1.2.0-dev (paczka gracza Win+Linux) — `workflow_dispatch`
  5. `Build Launcher` (Rust cross-platform) — auto push trigger
  6. `Build Bootstrap Launcher` — auto push trigger
  7. `Launcher Rust CI` (fmt/clippy/tests) — auto push trigger
- **Oczekiwany czas**:
  - Launcher + CI: ~10-15 min
  - Server Canary: ~30-60 min
  - Client Linux: ~60-120 min
  - Client Windows + paczka gracza: ~3-6h
- **Wynik**: ⏳ W TRAKCIE → częściowe wyniki poniżej

---

### [2026-03-22] Wyniki kompilacji z commit `fcb62b6c2`

| # | Workflow | Run ID | Wynik | Czas |
|---|---------|--------|-------|------|
| 1 | Canary - Build (serwer Linux) | 23401384350 | ✅ SUCCESS | — |
| 2 | Build Launcher (Rust cross-platform) | 23401376171 | ✅ SUCCESS | — |
| 3 | Build Bootstrap Launcher | 23401376165 | ✅ SUCCESS | — |
| 4 | Build - Linux (OTC Client) | 23401385971 | ❌ FAILURE | 24m37s |
| 5 | Launcher Rust CI (fmt/clippy/tests) | 23401376166 | ❌ FAILURE | <2min |
| 6 | Build - Windows (klient) | 23401387845 | 🔄 IN PROGRESS | — |
| 7 | build-client-package v1.2.0-dev | 23401389833 | 🔄 IN PROGRESS | — |

---

### [2026-03-22] FAIL #1: Build - Linux (OTC Client) — FAIL

- **GHA Run**: #23401385971
- **Branch**: feature/ticket-gate @ `fcb62b6c2`
- **Czas**: 24m37s
- **Wynik**: FAIL (oba warianty: Release + Debug)

#### Błędy:
1. **`luainterface.h:418`** — `no matching function for call to 'bind_singleton_mem_fun'`
   - Komunikat: `types 'Ret (FC::)(Args ...)' and 'bool (ConfigManager::)() const' have incompatible cv-qualifiers`
   - Plik źródłowy: `luafunctions.cpp:177-190` (bindowane metody ConfigManager)
   - Dotyczy metod: `isDevMode()`, `isClientLocked()`, `getStartupGameMode()`, `getGameModeCount()`, `hasGameMode()`, `getGameModeName()`, `getGameModeDescription()`, `getGameModeHost()`, `getGameModePort()`, `getGameModeProtocol()`, `getGameModeHttpLogin()`, `getGameModeHttpLoginUrl()`, `getGameModeFeature()`, `getGameModeAllowedWorldIds()`
   - **Diagnoza**: Szablon `bind_singleton_mem_fun` w `luabinder.h:215` obsługuje tylko **nie-const** wskaźniki na metody `Ret(FC::*)(Args...)`. Metody ConfigManager są oznaczone `const` → sygnatura `Ret(FC::*)(Args...) const` nie pasuje do szablonu. To jest klasyczny problem z C++ template deduction i cv-qualifiers.
   - **Poprawka**: Dodano 3 nowe overloady w `luabinder.h`:
     1. `make_mem_func_singleton(Ret(C::* f)(Args...) const, C*)` — const Ret overload
     2. `make_mem_func_singleton(void(C::* f)(Args...) const, C*)` — const void overload
     3. `bind_singleton_mem_fun(Ret(FC::* f)(Args...) const, C*)` — const bind overload
   - **Plik poprawiony**: `testyy/src/framework/luaengine/luabinder.h`

2. **`httplogin.cpp:121`** — WARNING (nie blokuje): `-Wunused-parameter 'httpLogin'`
   - Tylko warning, nie error. Nie blokuje kompilacji.

---

### [2026-03-22] FAIL #2: Launcher Rust CI — FAIL (NON-BLOCKING)

- **GHA Run**: #23401376166
- **Branch**: feature/ticket-gate @ `fcb62b6c2`
- **Czas**: <2min
- **Wynik**: FAIL — `cargo fmt --check` (formatting only)
- **UWAGA**: Build Launcher (binaria) SUCCEEDED — to jest tylko check jakości kodu

#### Błędy:
1. **`cargo fmt --check`** — 12 plików z niezgodną indentacją
   - Pliki:
     - `launcher-bootstrap/src/downloader.rs`
     - `launcher-bootstrap/src/i18n.rs`
     - `launcher-bootstrap/src/installer.rs`
     - `launcher-bootstrap/src/main.rs`
     - `launcher-bootstrap/src/platform.rs`
     - `launcher-bootstrap/src/ui.rs`
     - `launcher-tauri/src/commands.rs`
     - `launcher-tauri/src/main.rs`
     - `launcher-tauri/src/session_store.rs`
     - `common-models/src/launcher_config.rs`
     - `launcher-core/src/integrity.rs`
     - `launcher-core/src/language_pack_download.rs`
   - **Diagnoza**: Kod Rust nie przeszedł `rustfmt`. Zmiany to indentacja łańcuchów `.map_err()`, `let` bindings, line wrapping.
   - **Poprawka**: Wymagany `cargo fmt` na 12 plikach. Brak lokalnego Rust — fix manualny lub `rustup install`.

---

<!-- NOWE WPISY PONIŻEJ -->
