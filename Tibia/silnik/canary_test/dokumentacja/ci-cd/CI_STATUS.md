# OTClient CI/CD Status Report

**Last Updated:** 2025-12-07

## Plan działania (CI + I18N)
1. SonarCloud: wyłączyć Automatic Analysis w projekcie SC lub włączyć warunek `if` w workflow, aby nie uruchamiać analizy CI gdy AA jest aktywne; następnie ponowić `Analysis - SonarCloud (Windows/Android)`.
2. Windows (MSVC): uzupełnić `asyncdispatcher` o brakujące include’y standardowe i potwierdzić, że cpp jest budowany; przejrzeć logi pod kątem braków typu `g_asyncDispatcher` i poprawić deklarację/definicję.
3. Vcpkg baseline: podnieść `builtin-baseline`/`vcpkgGitCommitId` do wersji zawierającej `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0` albo zredukować wersje portów; po zmianie wykonać `build-windows.yml` i `build-windows-solution.yml`.
4. I18N san-check: potwierdzić, że wszystkie 53 locale przechodzą buildy (Windows/Ubuntu/WASM/Android) z ustawionym UTF-8 (MSVC flag), TTF/HarfBuzz/FriBidi włączone tam, gdzie potrzebne.
5. Retest: po powyższych zmianach uruchomić komplet workflow (Windows, Ubuntu, Browser, Android, SonarCloud) i zaktualizować statusy w tym pliku.
6. Checklist: korzystaj z `docs/ci-cd/I18N_BUILD_CHECKLIST.md` przy każdym rerunie, aby upewnić się, że wymagania I18N/UTF-8 są spełnione.

---

## Build Workflow Summary

| Workflow | File | Platform | Status | Notes |
|----------|------|----------|--------|-------|
| **Windows** | `build-windows.yml` | Windows | ⚙️ In Progress | MSVC ICE workaround added |
| **Ubuntu** | `build-ubuntu.yml` | Ubuntu 24.04 | ⏳ Pending | |
| **Browser (WASM)** | `build-browser.yml` | Emscripten | ⚙️ In Progress | Lua 5.4 support fixed |
| **Android** | `build-android.yml` | Android NDK | ❌ Needs Investigation | CMake configuration issues |

---

## Fixes Implemented in This PR

### ✅ Emscripten/WASM Build Fix (NEW)
**Files Changed:**
- `cmake/FindLua.cmake` - Updated to support Lua 5.4 for WASM builds
- `src/CMakeLists.txt` - Simplified WASM Lua detection

**Problem:** Custom `FindLua.cmake` only looked for Lua 5.1 libraries, but vcpkg's WASM Lua package provides Lua 5.4 (lua54).

**Solution:** Updated `FindLua.cmake` to detect WASM/Emscripten builds and search for Lua 5.4 library names:
```cmake
if(EMSCRIPTEN OR WASM)
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua54 lua5.4 lua)
    # Static library file names (.a files) and library names
    SET(_LUA_STATIC_LIBS liblua54.a liblua5.4.a liblua.a)
    SET(_LUA_SHARED_LIBS lua54 lua5.4 lua)
else()
    # Standard Lua 5.1 paths for non-WASM builds
    ...
endif()
```

### ✅ MSVC Internal Compiler Error (ICE) Workaround (NEW)
**File Changed:** `src/CMakeLists.txt`

**Problem:** MSVC triggers C1001 internal compiler error on complex template code in `cast.h` around line 157 when using `/O2` optimization.

**Solution:** Added optimization level reduction for Release/RelWithDebInfo builds. The workaround is applied globally because `cast.h` is a header-only template library included via `stdext.h` across all source files:
```cmake
if (MSVC)
  # Workaround for MSVC Internal Compiler Error (ICE) on complex template code
  target_compile_options(${PROJECT_NAME} PRIVATE
    $<$<CONFIG:Release>:/O1>  # Use /O1 instead of /O2
    $<$<CONFIG:RelWithDebInfo>:/O1>
  )
endif()
```

### ✅ UTF-8 Support (Previous Fix)
**File:** `src/CMakeLists.txt`

MSVC UTF-8 flag (`/utf-8`) already added for proper Unicode handling.

---

## Known Issues and Workarounds

### 1. `asyncdispatcher` Type Mismatch (Previous Issue - Check Status)
**Files:** `src/framework/core/asyncdispatcher.h`, `src/framework/core/asyncdispatcher.cpp`

**Issue:** Conflicting template parameter declarations for `BS::thread_pool`.

**Resolution:** Ensure both header and implementation use identical type signature:
```cpp
// asyncdispatcher.h
extern BS::thread_pool<> g_asyncDispatcher;

// asyncdispatcher.cpp
BS::thread_pool<> g_asyncDispatcher{ getThreadCount() };
```

### 2. Compiler Warnings
| Warning | File | Line | Fix |
|---------|------|------|-----|
| Extra semicolon | `eventdispatcher.h` | 104 | Remove `;;` → `;` |
| Unused parameter | `platformwindow.h` | 84 | Add `[[maybe_unused]]` to `color` |

---

## I18N Implementation Status

### 🎉 Complete Features

| Feature | Status | Files Changed |
|---------|--------|---------------|
| 53 Language Locales | ✅ Complete | `modules/client_locales/*.lua` |
| TTF Font Rendering | ✅ Complete | `src/framework/text/TTFFont.cpp` |
| Text Shaping (HarfBuzz) | ✅ Complete | `src/framework/text/TextShaper.cpp` |
| RTL Support (FriBidi) | ✅ Complete | `src/framework/text/LocaleShaping.cpp` |
| MSVC UTF-8 Flag | ✅ Complete | `src/CMakeLists.txt` |
| Emscripten Lua Fix | ✅ Complete | `src/CMakeLists.txt` |

### Locale Coverage (53 Languages)

| Region | Languages | Count |
|--------|-----------|-------|
| Western European | en, de, es, fr, it, pt, nl, sv, da, no, fi, is | 12 |
| Eastern European | pl, cs, hu, ro, bg, sk, hr, sr, sl, sq, mk | 11 |
| Baltic | lt, lv, et | 3 |
| Slavic | ru, uk | 2 |
| Asian | zh, ja, ko, vi, th, hi, id, ms, fil, bn | 10 |
| Middle Eastern (RTL) | ar, he, fa, tr | 4 |
| Caucasus | ka, hy, az | 3 |
| Central Asian | kk, uz | 2 |
| African | af, sw | 2 |
| Other | eu, ca, gl, el | 4 |

---

## Documentation Created

### OTClient (`testyy/docs/`)
| Document | Purpose |
|----------|---------|
| `ARCHITECTURE.md` | Project architecture overview |
| `TEXT_RENDERING.md` | Text rendering pipeline and I18N |
| `MODULES.md` | Lua modules documentation (60+) |
| `SOURCE_CODE.md` | C++ source code documentation |
| `I18N_SUMMARY.md` | I18N project summary |
| `BUILD_GUIDE.md` | Build instructions for all platforms |
| `DEPENDENCIES.md` | Complete dependency documentation |

### Canary Server (`canary/docs/`)
| Document | Purpose |
|----------|---------|
| `INTERNATIONALIZATION.md` | Server-side I18N guide |
| `SOURCE_CODE.md` | Server source documentation |
| `LUA_SCRIPTING.md` | Lua API documentation |
| `CONFIGURATION.md` | Server configuration |
| `DATABASE.md` | Database schema with I18N tables |

---

## CI Workflow Files Comparison

### Branch vs Master
Workflows in this PR branch are **identical** to master - no workflow file changes were needed for the I18N implementation.

### Workflow Triggers

| Workflow | Triggers |
|----------|----------|
| `build-windows.yml` | push (master), pull_request |
| `build-ubuntu.yml` | push (master), pull_request, merge_group |
| `build-browser.yml` | push (master), pull_request |
| `build-android.yml` | push (master), pull_request |

### Path Filters
All build workflows trigger on changes to:
- `Tibia/silnik/canary_test/testyy/src/**`
- Respective workflow file

---

## Next Steps

### Immediate (After Workflow Approval)
1. [ ] Verify all builds complete successfully
2. [ ] Address any compilation errors if they occur
3. [ ] Review warning messages and fix if needed

### Short-term
1. [ ] Implement TTFFont batching for better performance
2. [ ] Add shaping cache to `CachedText`
3. [ ] Create unit tests for `TTFFont` and `TextShaper`

### Long-term
1. [ ] Font fallback system for missing glyphs
2. [ ] Colored emoji support (COLR/CPAL)
3. [ ] Grapheme cluster-aware caret/selection

---

## How to Test Locally

### Windows
```powershell
cd Tibia/silnik/canary_test/testyy
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake" `
  -DVCPKG_TARGET_TRIPLET=x64-windows-static
cmake --build build --config Release --parallel
```

### Linux (Ubuntu)
```bash
cd Tibia/silnik/canary_test/testyy
cmake -G Ninja -S . -B build-linux \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux
cmake --build build-linux --target otclient
```

### Browser (Emscripten)
```bash
source $EMSDK/emsdk_env.sh
cd Tibia/silnik/canary_test/testyy
cmake -G Ninja -S . -B build-wasm \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=wasm32-emscripten \
  -DVCPKG_OVERLAY_PORTS=$(pwd)/browser/overlay-ports
cmake --build build-wasm --target otclient
```

---

## Contact

For questions about this PR or I18N implementation:
- Review the documentation in `docs/` directories
- Check `I18N_Progress.md` for historical context
- Check `I18N_Next_Steps.md` for planned improvements
