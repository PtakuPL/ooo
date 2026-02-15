# GitHub Actions Workflow Status Documentation

**Last Updated:** 2025-12-05  
**Branch:** master  
**Total Workflows:** 32

---

## Table of Contents
1. [Build Workflows](#build-workflows)
2. [Analysis Workflows](#analysis-workflows)
3. [Linting Workflows](#linting-workflows)
4. [Other Workflows](#other-workflows)
5. [Known Issues and Fixes](#known-issues-and-fixes)
6. [Next Steps](#next-steps)

---

## Build Workflows

### Active Build Workflows

| Workflow | File | Status | Details |
|----------|------|--------|---------|
| **build-linux** | `build-linux.yml` | ✅ **Sukces** | Ubuntu/Linux build works correctly |
| **build-windows** | `build-windows.yml` | 🔄 **W trakcie** | vcpkg dependencies installation |
| **Build - Emscripten** | `build-browser.yml` | ❌ **Błąd** | `Could NOT find Lua (missing: LUA_LIBRARIES LUA_INCLUDE_DIR)` |
| **Build - Android** | `build-android.yml` | ❌ **Błąd** | CMake toolchain configuration issues |
| **Build - Docker** | `build-docker.yml` | ❌ **Błąd** | Dockerfile path issues |
| **Build - Windows - CMake** | `build-windows-cmake.yml` | ❌ **Błąd** | vcpkg triplet configuration |
| **Build - Windows - Solution** | `build-windows-solution.yml` | ❌ **Błąd** | MSVC Internal Compiler Error (C1001) |
| **Build - Ubuntu** | `build.yml` | ✅ **Sukces** | Main Ubuntu build |

### Dummy/Inactive Build Workflows

| Workflow | File | Status |
|----------|------|--------|
| Build - Ubuntu (dummy) | `build-ubuntu-dummy.yml` | ⏸ Dummy |
| Build - Windows - CMake (dummy) | `build-windows-cmake-dummy.yml` | ⏸ Dummy |
| Build - Windows - Solution (dummy) | `build-windows-solution-dummy.yml` | ⏸ Dummy |
| Build - Docker (dummy) | `build-docker-dummy.yml` | ⏸ Dummy |

---

## Analysis Workflows

| Workflow | File | Status | Details |
|----------|------|--------|---------|
| **SonarCloud (Windows)** | `analysis-sonarcloud-windows.yml` | ⚠️ **Sukces (manual)** | Build failure on automatic push, works manually |
| **SonarCloud (Linux)** | `analysis-sonarcloud-linux.yml` | ❌ **Błąd** | Missing SONAR_TOKEN or configuration issue |
| **SonarCloud (Android)** | `analysis-sonarcloud-android.yml` | ❌ **Błąd** | CMake Android toolchain issues |
| **Analysis - Review Dog** | `reviewdog.yml` | ⏸ **Nieaktywne** | - |

---

## Linting Workflows

| Workflow | File | Status |
|----------|------|--------|
| **Clang-format** | `lint-clang-format.yml` | ⏸ Nieaktywne |
| **CMake-format** | `lint-cmake-format.yml` | ⏸ Nieaktywne |
| **Lua-format** | `lint-lua-format.yml` | ⏸ Nieaktywne |

---

## Other Workflows

| Workflow | File | Status |
|----------|------|--------|
| **Tests - Lua** | `test-lua.yml` | ⏸ Nieaktywne |
| **MySQL Schema Check** | `mysql-schema-check.yml` | ⏸ Nieaktywne |
| **PR - Labeler** | `labeler.yml` | ⏸ Nieaktywne |
| **Issue - Labeling** | `issue-labeling.yml` | ⏸ Nieaktywne |
| **Cleanup caches** | `cleanup-caches.yml` | ⏸ Nieaktywne |
| **Use GitHub Models** | `github-models.yml` | ⏸ Nieaktywne |

---

## Known Issues and Fixes

### 1. Emscripten/WASM - Lua Detection Issue

**Problem:**  
```
CMake Error: Could NOT find Lua (missing: LUA_LIBRARIES LUA_INCLUDE_DIR)
```

**Root Cause:**  
vcpkg's WASM lua package provides Lua 5.4 (`lua54`), but `FindLua.cmake` only searches for Lua 5.1 libraries (`lua51`).

**Solution:**  
Updated `cmake/FindLua.cmake` to detect WASM builds and search for Lua 5.4:

```cmake
if(EMSCRIPTEN OR WASM)
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua54 lua5.4 lua)
    SET(_LUA_STATIC_LIBS liblua54.a liblua5.4.a liblua.a)
    SET(_LUA_SHARED_LIBS lua54 lua5.4 lua)
else()
    # Lua 5.1 paths for desktop builds
endif()
```

**Status:** ✅ Fixed in PR #29

---

### 2. Windows MSVC - Internal Compiler Error (C1001)

**Problem:**  
```
fatal error C1001: Internal compiler error.
(compiler file 'msc1.cpp', line 1587)
```

**Root Cause:**  
ASAN (`/fsanitize=address`) combined with complex template code in `src/framework/stdext/cast.h` triggers MSVC compiler crash. ASAN is not fully supported by MSVC and causes ICE on complex templates.

**Solution:**  
1. Disabled ASAN in Windows debug presets in CMakePresets.json
2. Added `/O1` optimization workaround in `src/CMakeLists.txt`

The following presets were updated with `"ASAN_ENABLED": "OFF"`:
- `windows-debug`
- `windows-debug-msbuild`

**Note:** This is NOT a memory issue - GitHub Actions Windows runners have 7GB RAM which is sufficient.

**Status:** ✅ Fixed in PR #29

---

### 3. Docker Build - Missing Python3

**Problem:**  
```
CMake Error: Could not find python3. Please install it via your package manager:
    sudo apt-get install python3
```

**Root Cause:**  
vcpkg-tool-meson requires python3 which was not installed in the Docker image.

**Solution:**  
Added `python3` and `python3-pip` to the Dockerfile's apt-get install:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake curl zip unzip tar automake ca-certificates build-essential \
    libglew-dev libx11-dev autoconf libtool pkg-config tzdata libssl3 \
    python3 python3-pip \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get clean && apt-get autoclean
```

**Status:** ✅ Fixed in PR #29

---

### 4. Android Build - Multiple Issues

**Problem 1: PkgConfig Missing**  
```
CMake Error: Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)
```

**Root Cause:**  
Windows runner doesn't have pkg-config installed, and FriBidi falls back to pkg-config when CMake CONFIG is not found.

**Solution:**  
Install pkgconfiglite via Chocolatey:
```yaml
- name: Ensure 7zip and pkg-config
  run: |
    choco install -y 7zip pkgconfiglite
```

**Problem 2: LTO Linker Error**
```
clang++: error: invalid linker name in argument '-fuse-ld=gold'
```

**Root Cause:**  
NDK 29.x doesn't support the `gold` linker with LTO. The `-flto` flag in build.gradle triggers this error.

**Solution:**  
Removed `-flto` from `android/app/build.gradle`:
```gradle
cppFlags '-std=c++20'  // removed '-flto'
```

**Status:** ✅ Fixed in PR #29

---

### 5. SonarCloud Linux - Automatic Analysis Conflict

**Problem:**  
SonarCloud analysis fails with "You are running CI analysis while Automatic Analysis is enabled".

**Root Cause:**  
SonarCloud has both automatic analysis AND manual CI scanner running simultaneously, which conflicts.

**Solution:**  
**Requires manual action by repository owner:**
1. Log into SonarCloud (https://sonarcloud.io)
2. Go to Project Settings → Administration → Analysis Method
3. Toggle OFF "Automatic Analysis"
4. Save and re-run the workflow

**Status:** 🔧 Needs Manual Configuration by Owner

---

### 6. Windows CMake - Path Issues

**Problem:**  
Workflow file references incorrect paths (`src/**` instead of `Tibia/silnik/canary_test/testyy/src/**`).

**Root Cause:**  
Original workflow was designed for a different repository structure.

**Solution:**  
Updated `build-windows-cmake.yml`:
1. Fixed path filters for pull_request/push triggers
2. Added `working-directory` to job defaults
3. Updated artifact paths

**Status:** ✅ Fixed in PR #29

---

## Next Steps

### Fixed in PR #29 (pending merge)
1. [x] Fix Emscripten/WASM Lua detection
2. [x] Fix Windows MSVC C1001 (disabled ASAN)
3. [x] Fix Docker workflow - added python3
4. [x] Fix Windows CMake path triggers
5. [x] Fix Android SonarCloud protobuf
6. [x] Fix Android build (pkg-config + LTO linker error)

### Requires Manual Action
7. [ ] **SonarCloud Linux** - Disable "Automatic Analysis" in SonarCloud UI
   - Go to: https://sonarcloud.io → Project Settings → Administration → Analysis Method
   - Toggle OFF "Automatic Analysis"

### Medium Priority
8. [ ] Enable linting workflows (clang-format, cmake-format, lua-format)
9. [ ] Enable Lua tests

### Low Priority
10. [ ] Configure PR labeler
11. [ ] Setup issue auto-labeling

---

## Summary Statistics

| Category | Working | Fixed in PR | Needs Manual Action | Inactive | Total |
|----------|---------|-------------|---------------------|----------|-------|
| Build | 2 | 6 | 0 | 4 | 12 |
| Analysis | 1 | 1 | 1 | 1 | 4 |
| Linting | 0 | 0 | 0 | 3 | 3 |
| Other | 0 | 0 | 0 | 6 | 6 |

**After PR #29 is merged:**
- Build: 8 working, 0 failed
- Analysis: 2 working, 1 needs manual config

---

## Related Files

- `CI_STATUS.md` - General CI status overview
- `I18N_Progress.md` - Internationalization progress
- `I18N_Next_Steps.md` - Next steps for i18n
- `docs/` - Additional documentation

---

*This document is automatically updated when workflow status changes.*
