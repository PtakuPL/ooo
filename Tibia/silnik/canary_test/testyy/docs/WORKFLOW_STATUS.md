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

**Status:** ✅ Fixed in PR #XX

---

### 2. Windows MSVC - Internal Compiler Error (C1001)

**Problem:**  
```
fatal error C1001: Internal compiler error.
(compiler file 'msc1.cpp', line 1587)
```

**Root Cause:**  
MSVC compiler crashes on complex template code in `src/framework/stdext/cast.h` when using `/O2` optimization level.

**Solution:**  
Added workaround in `src/CMakeLists.txt` to use `/O1` optimization for MSVC:

```cmake
if(MSVC)
    # Workaround for MSVC C1001 Internal Compiler Error on cast.h templates
    target_compile_options(${PROJECT_NAME} PRIVATE
      $<$<CONFIG:Release>:/O1>
      $<$<CONFIG:RelWithDebInfo>:/O1>
    )
endif()
```

**Note:** This is NOT a memory issue - GitHub Actions Windows runners have 7GB RAM which is sufficient.

**Status:** ✅ Fixed in PR #XX

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

**Status:** ✅ Fixed in PR #XX

---

### 4. Android Build - CMake Toolchain

**Problem:**  
CMake cannot find Android NDK toolchain.

**Root Cause:**  
Missing or incorrectly configured Android NDK path in workflow.

**Solution:**  
1. Ensure `ANDROID_NDK_HOME` is set correctly
2. Update CMake toolchain file path
3. Configure proper API level

**Status:** 🔧 Needs Fix

---

### 5. SonarCloud Linux - Token Issues

**Problem:**  
SonarCloud analysis fails on Linux.

**Root Cause:**  
Missing `SONAR_TOKEN` secret or incorrect project configuration.

**Solution:**  
1. Verify `SONAR_TOKEN` is set in repository secrets
2. Check `sonar-project.properties` configuration

**Status:** 🔧 Needs Investigation

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

**Status:** ✅ Fixed in PR #XX

---

## Next Steps

### High Priority
1. [ ] Fix Docker workflow Dockerfile path
2. [ ] Fix Android NDK configuration
3. [ ] Fix Windows CMake vcpkg triplet

### Medium Priority
4. [ ] Investigate SonarCloud Linux token issues
5. [ ] Enable linting workflows (clang-format, cmake-format, lua-format)

### Low Priority
6. [ ] Enable Lua tests
7. [ ] Configure PR labeler
8. [ ] Setup issue auto-labeling

---

## Summary Statistics

| Category | Working | Failed | Inactive | Total |
|----------|---------|--------|----------|-------|
| Build | 2 | 5 | 4 | 11 |
| Analysis | 1 | 3 | 1 | 5 |
| Linting | 0 | 0 | 3 | 3 |
| Other | 0 | 0 | 6 | 6 |
| **Total** | **3** | **8** | **14** | **32** |

---

## Related Files

- `CI_STATUS.md` - General CI status overview
- `I18N_Progress.md` - Internationalization progress
- `I18N_Next_Steps.md` - Next steps for i18n
- `docs/` - Additional documentation

---

*This document is automatically updated when workflow status changes.*
