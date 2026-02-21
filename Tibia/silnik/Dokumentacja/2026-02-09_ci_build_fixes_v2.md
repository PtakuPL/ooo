# CI Build Fixes — 2026-02-09 (sesja 2)

## Problem
GitHub Actions buildy na Windows (MSVC), WASM (Emscripten) i Android nadal padały po zmianach Codex agenta.
Codex dodał `VCPKG_C_FLAGS: -pthread -matomics -mbulk-memory` na poziomie `env:` w workflow WASM,
co trafiało do WSZYSTKICH tripletów (w tym x64-linux host) i łamało kompilację GCC.

## Naprawione problemy

### 1. WASM: env-level VCPKG_C_FLAGS łamie host triplet
- **Problem:** `-matomics -mbulk-memory` to flagi Emscripten; GCC na x64-linux ich nie rozumie.
- **Fix:** Usunięto `VCPKG_C_FLAGS`/`VCPKG_CXX_FLAGS` z env workflow. Flagi są w `browser/triplets/wasm32-emscripten.cmake` (tylko dla tripit wasm).
- **Commity:** `40f1db728`, `ab5bdb4d5`

### 2. WASM: vcpkg nie rozpoznaje overlay ports/lua (brak vcpkg.json)
- **Problem:** Katalog `overlay-ports/lua/` nie miał `vcpkg.json`. vcpkg ignorował overlay i używał built-in Lua (bez flag atomics).
- **Fix:** Dodano `vcpkg.json` do overlay-ports/lua/ (force-add, bo *.json jest w .gitignore).
- **Commit:** `365a0cf04`

### 3. WASM: OpenSSL i inne non-cmake porty bez flag atomics
- **Problem:** `VCPKG_C_FLAGS` w triplet działa tylko dla cmake-based portów. OpenSSL używa własnego systemu budowania (perl Configure) i nie czyta `VCPKG_C_FLAGS`.
- **Fix:** Dodano `EMCC_CFLAGS: -pthread -matomics -mbulk-memory` na poziomie env workflow. `EMCC_CFLAGS` jest czytany TYLKO przez `emcc`, nie przez GCC.
- **Commit:** `baf8acf15`

### 4. WASM: brak VCPKG_CHAINLOAD_TOOLCHAIN_FILE w triplet
- **Problem:** vcpkg wewnętrznie uruchamia cmake dla portów i nie zna ścieżki do Emscripten toolchain.
- **Fix:** Dodano `VCPKG_CHAINLOAD_TOOLCHAIN_FILE` z `$ENV{EMSDK}` do tripit.
- **Commit:** `ab5bdb4d5`

### 5. Windows: MSVC 14.44 ICE C1001 — cast.h safe_cast
- **Problem:** `safe_cast<R,T>()` wywołuje `demangle_type<T>()` — nested template w P2 (codegen) MSVC 14.44 powoduje EXCEPTION_ACCESS_VIOLATION.
- **Poprzedni fix (sesja 1):** `detail::throw_cast_failure()` non-template helper — naprawił C2664 ale ICE się przeniosło do `otmlparser.cpp`.
- **Finalny fix:** Usunięto WSZYSTKIE wywołania template z MSVC error path — `safe_cast` rzuca `std::runtime_error("failed to cast value")` bez demangle.
- **Commity:** `7e349b6ac`, `d1faf2c5a`

### 6. Windows: MSVC toolset selector
- **Problem:** Codex dodał selector aby ominąć 14.44, ale `windows-2022` runner ma TYLKO 14.44.
- **Status:** Selector działa (nie szkodzi), ale fallback do 14.44 jest nieunikniony.
- **W przyszłości:** Rozważyć `windows-2025` runner lub Clang-CL.

## Pliki zmienione
- `.github/workflows/build-wasm.yml` — usunięto VCPKG_C/CXX_FLAGS, dodano EMCC_CFLAGS
- `.github/workflows/analysis-sonarcloud-wasm.yml` — j.w.
- `browser/triplets/wasm32-emscripten.cmake` — dodano VCPKG_CHAINLOAD_TOOLCHAIN_FILE
- `browser/overlay-ports/lua/vcpkg.json` — NOWY (force-add mimo .gitignore)
- `browser/overlay-ports/lua/CMakeLists.txt` — unconditional atomics flags
- `src/framework/stdext/cast.h` — uproszczony MSVC path (plain string exception)

## Status buildów (oczekujący)
- Windows: buduje (vcpkg install → build → linkowanie) — ~60min
- WASM: buduje z EMCC_CFLAGS i Lua overlay — ~45min
