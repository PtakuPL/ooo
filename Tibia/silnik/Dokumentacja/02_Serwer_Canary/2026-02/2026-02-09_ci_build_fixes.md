# 2026-02-09 - Naprawa kompilacji CI (Windows, Android, WASM)

## Problem
Wszystkie platformy (Windows, Android, WASM) miały błędy kompilacji w GitHub Actions.
Copilot na GitHubie tworzył kolejne PR-y z poprawkami (PR #49-#61), ale żaden nie naprawił
problemów kompleksowo.

## Zidentyfikowane błędy

### 1. Windows (MSVC) — `fatal error C1001: Internal compiler error`
- **Plik:** `src/framework/stdext/cast.h:160` (durante kompilacji `luavaluecasts.cpp`)
- **Przyczyna:** Zagnieżdżona instancjacja szablonów: `safe_cast<R,T>()` wywołuje
  `cast_exception::update_what<T,R>()` (szablon-członek klasy wewnątrz szablonu-funkcji).
  MSVC's front-end crashuje się na tym nawet z `/Od`.
- **Poprzednie próby naprawy (nieskuteczne):** PR #50, #52, #54, #56, #61:
  - `#pragma optimize("", off)` — nie działa bo crash jest w front-end, nie w optymalizatorze
  - `__declspec(noinline)` — nie pomaga bo ICE jest w instancjacji szablonu
  - `/Od` per-file — nie pomaga bo ICE jest przed etapem optymalizacji
  - `/GL-`, `/LTCG:OFF` — nie dotyczy tego problemu bezpośrednio

### 2. Android — `clang++: error: invalid linker name in argument '-fuse-ld=gold'`
- **Przyczyna:** CMake's `check_ipo_supported()` testuje LTO używając linkera `gold`, który
  nie istnieje w NDK na Windows. Plus `ninja: error: bad $-escape` ze starych plików cache.
- **Plik:** `src/CMakeLists.txt:1112` — `set(CMAKE_SHARED_LINKER_FLAGS "-fuse-ld=lld")`
  nadpisywał wszystkie flagi linkerowe (zamiast APPEND).

### 3. WASM — `wasm-ld: error: --shared-memory is disallowed by ldo.c.o`
- **Przyczyna:** Lua (vcpkg) kompilowana bez `-matomics -mbulk-memory`, a główny projekt
  używa pthreads + shared-memory. Overlay-ports miały flagi ale vcpkg nie używał
  custom overlay triplet, więc `VCPKG_C_FLAGS` nie propagowały się.

## Zastosowane rozwiązania

### Windows MSVC fix:
- **cast.h:** Rozdzielenie na dwie ścieżki `#ifdef _MSC_VER`:
  - MSVC: `detail::throw_cast_failure()` — non-template helper, unika zagnieżdżonej
    instancjacji szablonu
  - Inne: oryginalna wersja z `cast_exception::update_what<T,R>()`
- **src/CMakeLists.txt:** `/d2SSAOptimizer-` (wewnętrzna flaga MSVC wyłączająca SSA
  optimizer) + `/Od` + `SKIP_PRECOMPILE_HEADERS ON` dla 3 plików: luavaluecasts.cpp,
  otmlparser.cpp, uiwidgetbasestyle.cpp

### Android fix:
- Zmiana `set()` na `string(APPEND)` dla flag linkera — nie nadpisuje istniejących flag
- Warunkowe ustawianie `-fuse-ld=lld` tylko gdy NDK < r23 (nowsze mają lld domyślnie)
- Usuwanie starych plików `build.ninja` i `rules.ninja` przed budowaniem Gradle

### WASM fix:
- Utworzenie custom overlay triplet: `browser/triplets/wasm32-emscripten.cmake`
  z `VCPKG_C_FLAGS` / `VCPKG_CXX_FLAGS` zawierającymi `-pthread -matomics -mbulk-memory`
- Podanie `VCPKG_OVERLAY_TRIPLETS` w workflow build-wasm.yml i sonarcloud-wasm.yml
- Aktualizacja kluczy cache aby uwzględniały zmiany triplet

## Zmienione pliki
- `src/framework/stdext/cast.h`
- `src/CMakeLists.txt`
- `.github/workflows/build-android.yml`
- `.github/workflows/build-wasm.yml`
- `.github/workflows/analysis-sonarcloud-wasm.yml`
- `browser/triplets/wasm32-emscripten.cmake` (nowy)

## Status
Pushed to master. Buildy uruchomione — oczekiwanie na wyniki.
