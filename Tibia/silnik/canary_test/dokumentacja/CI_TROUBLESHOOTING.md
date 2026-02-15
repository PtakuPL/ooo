# CI/CD Troubleshooting Guide

**Last Updated:** 2025-12-05  
**Purpose:** Complete documentation of all CI/CD errors encountered and their solutions, to help diagnose similar issues in the future.

---

## Table of Contents

1. [Build Errors](#build-errors)
   - [Emscripten/WASM Errors](#emscriptenwasm-errors)
   - [Windows MSVC Errors](#windows-msvc-errors)
   - [Docker Build Errors](#docker-build-errors)
   - [Android Build Errors](#android-build-errors)
2. [Workflow Configuration Errors](#workflow-configuration-errors)
3. [Analysis Tool Errors](#analysis-tool-errors)
4. [Quick Reference Table](#quick-reference-table)
5. [Diagnostic Commands](#diagnostic-commands)

---

## Build Errors

### Emscripten/WASM Errors

#### Error: Could NOT find Lua

**Full Error Message:**
```
CMake Error at cmake/FindLua.cmake:XX (message):
  Could NOT find Lua (missing: LUA_LIBRARIES LUA_INCLUDE_DIR)
```

**Symptoms:**
- Build fails during CMake configuration phase
- Occurs only on Emscripten/WASM builds
- Desktop builds (Linux, Windows) work fine

**Root Cause:**
vcpkg's WASM lua package provides **Lua 5.4** (`lua54`, `liblua54.a`), but the original `FindLua.cmake` only searched for **Lua 5.1** libraries (`lua51`, `liblua51.a`).

**Solution:**
Update `cmake/FindLua.cmake` to detect WASM builds and search for Lua 5.4:

```cmake
# WASM/Emscripten uses Lua 5.4
if(EMSCRIPTEN OR WASM)
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua54 lua5.4 lua)
    SET(_LUA_STATIC_LIBS liblua54.a liblua5.4.a liblua.a)
    SET(_LUA_SHARED_LIBS lua54 lua5.4 lua)
else()
    # Desktop builds use Lua 5.1 (LuaJIT)
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES luajit-2.1 lua5.1 lua)
    SET(_LUA_STATIC_LIBS liblua51.a liblua5.1.a libluajit.a liblua.a)
    SET(_LUA_SHARED_LIBS lua51 lua5.1 luajit-5.1 lua)
endif()
```

**Files Modified:**
- `cmake/FindLua.cmake`

**How to Verify Fix:**
```bash
# Check if vcpkg installed lua54 for wasm
ls $VCPKG_ROOT/installed/wasm32-emscripten/lib/ | grep lua
# Should show: liblua54.a
```

---

### Windows MSVC Errors

#### Error: Fatal error C1001 - Internal compiler error

**Full Error Message:**
```
fatal error C1001: Internal compiler error.
(compiler file 'msc1.cpp', line 1587)
```

or

```
fatal error C1001: Internal compiler error.
(compiler file 'd:\a01\_work\38\s\src\vctools\Compiler\CxxFE\sl\p1\c\toil.c', line 2547)

while compiling class-template member function 'void stdext::packed_any_storage::construct<_Ty>(_Ty &&)'
```

**Symptoms:**
- Build fails during compilation phase
- Error occurs in complex template code (especially `src/framework/stdext/cast.h`)
- Debug builds fail more often than Release
- NOT related to memory (GitHub runners have 7GB RAM)

**Root Cause:**
ASAN (`/fsanitize=address`) is not fully supported by MSVC and causes Internal Compiler Error (ICE) when combined with complex C++ template metaprogramming code.

**Solution 1: Disable ASAN (Recommended)**
Update `CMakePresets.json` to disable ASAN for Windows debug builds:

```json
{
    "name": "windows-debug",
    "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "ASAN_ENABLED": "OFF"  // Add this line
    }
}
```

**Solution 2: Use lower optimization level**
Add `/O1` flag for problematic files in `src/CMakeLists.txt`:

```cmake
if(MSVC)
    # Workaround for MSVC ICE with complex templates
    set_source_files_properties(
        framework/stdext/cast.cpp
        PROPERTIES COMPILE_FLAGS "/O1"
    )
endif()
```

**Files Modified:**
- `CMakePresets.json` (ASAN_ENABLED: OFF)
- `src/CMakeLists.txt` (/O1 optimization)

**How to Verify:**
```powershell
# Check if ASAN is disabled
grep -r "ASAN_ENABLED" CMakePresets.json
# Should show: "ASAN_ENABLED": "OFF"
```

**Important Notes:**
- This is NOT a memory issue - GitHub Actions Windows runners have sufficient RAM
- ChatGPT incorrectly suggested this was a memory problem - it is not
- The root cause is MSVC compiler limitation with ASAN + templates

---

### Docker Build Errors

#### Error: Could not find python3

**Full Error Message:**
```
CMake Error at scripts/cmake/vcpkg_find_acquire_program.cmake:179 (message):
  Could not find python3.  Please install it via your package manager:

      sudo apt-get install python3
```

**Symptoms:**
- Docker build fails during vcpkg dependency installation
- Specifically fails when building `vcpkg-tool-meson` package
- Error appears in Docker build log around step 9/13

**Root Cause:**
The `vcpkg-tool-meson` package requires Python 3 to be installed, but the base Ubuntu Docker image doesn't include it.

**Solution:**
Add `python3` and `python3-pip` to the Dockerfile's apt-get install command:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake curl zip unzip tar automake ca-certificates build-essential \
    libglew-dev libx11-dev autoconf libtool pkg-config tzdata libssl3 \
    python3 python3-pip \  # Add this line
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get clean && apt-get autoclean
```

**Files Modified:**
- `Dockerfile`

**How to Verify:**
```bash
# Check if python3 is in Dockerfile
grep "python3" Dockerfile
# Should show: python3 python3-pip
```

---

### Android Build Errors

#### Error: Could NOT find PkgConfig

**Full Error Message:**
```
CMake Error at /usr/share/cmake-3.22/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
  Could NOT find PkgConfig (missing: PKG_CONFIG_EXECUTABLE)

      Reason given by package: The command
        "C:/Strawberry/perl/bin/pkg-config.bat" --version
      failed with output:

      stderr: 
        Can't locate Pod/Usage.pm in @INC (you may need to install the Pod::Usage module)
```

**Symptoms:**
- Android build fails during CMake configuration
- Error occurs when trying to find FriBidi library
- Only happens on Windows runners (Android builds run on Windows)

**Root Cause:**
1. The Windows runner doesn't have a working pkg-config
2. FriBidi library falls back to pkg-config when CMake CONFIG mode fails
3. Strawberry Perl's pkg-config.bat is broken (missing Pod::Usage module)

**Solution:**
Install `pkgconfiglite` via Chocolatey in the workflow:

```yaml
- name: Ensure 7zip and pkg-config
  run: |
    choco install -y 7zip pkgconfiglite
```

**Files Modified:**
- `.github/workflows/build-android.yml`

---

#### Error: Invalid linker name '-fuse-ld=gold'

**Full Error Message:**
```
FAILED: boo 
clang++: error: invalid linker name in argument '-fuse-ld=gold'
clang++: error: invalid linker name in argument '-fuse-ld=gold'
ninja: build stopped: subcommand failed.
```

**Symptoms:**
- Android build fails during IPO/LTO check
- Error mentions `gold` linker
- Occurs with NDK 29.x

**Root Cause:**
1. LTO (Link Time Optimization) is enabled via `-flto` flag in `build.gradle`
2. CMake's IPO check tries to use `gold` linker which isn't available in newer NDK versions
3. NDK 29.x uses LLVM's lld linker, not GNU gold

**Solution:**
Remove `-flto` flag from `android/app/build.gradle`:

```gradle
externalNativeBuild {
    cmake {
        cppFlags '-std=c++20'  // Removed '-flto'
        arguments "-DVCPKG_TARGET_ANDROID=ON",
                "-DANDROID_STL=c++_shared"
        abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
    }
}
```

**Files Modified:**
- `android/app/build.gradle`

**Alternative Solution:**
If LTO is needed, specify the correct linker:
```gradle
cppFlags '-std=c++20', '-flto=thin', '-fuse-ld=lld'
```

---

## Workflow Configuration Errors

### Error: Workflow never triggers

**Symptoms:**
- Workflow doesn't run on push/PR
- No errors shown, just doesn't trigger

**Root Cause:**
Incorrect path patterns in workflow triggers. Original paths like `src/**` don't match the actual repository structure.

**Solution:**
Update path triggers to match repository structure:

```yaml
# Wrong:
paths:
  - 'src/**'

# Correct:
paths:
  - 'Tibia/silnik/canary_test/testyy/src/**'
```

Also add `working-directory` to job defaults:
```yaml
defaults:
  run:
    working-directory: Tibia/silnik/canary_test/testyy
```

**Files Modified:**
- `.github/workflows/build-windows-cmake.yml`

---

## Analysis Tool Errors

### Error: SonarCloud - Automatic Analysis Conflict

**Full Error Message:**
```
ERROR: You are running CI analysis while Automatic Analysis is enabled. 
Please consider disabling one or the other.
```

**Symptoms:**
- SonarCloud workflow fails immediately
- Error appears at the start of analysis

**Root Cause:**
SonarCloud has two analysis modes:
1. **Automatic Analysis** - SonarCloud automatically analyzes code
2. **CI-based Analysis** - Workflow runs sonar-scanner

These modes conflict when both are enabled.

**Solution:**
**Requires manual action by repository owner:**
1. Log into https://sonarcloud.io
2. Go to Project Settings → Administration → Analysis Method
3. Toggle OFF "Automatic Analysis"
4. Save and re-run the workflow

**Files Modified:**
- None (manual configuration in SonarCloud UI)

---

## Quick Reference Table

| Error Message | Platform | Root Cause | Quick Fix |
|--------------|----------|------------|-----------|
| `Could NOT find Lua` | Emscripten | FindLua.cmake searches for Lua 5.1, vcpkg has Lua 5.4 | Update FindLua.cmake for WASM |
| `fatal error C1001` | Windows | ASAN + complex templates | Set `ASAN_ENABLED: OFF` |
| `Could not find python3` | Docker | Missing python3 in image | Add `python3` to Dockerfile |
| `Could NOT find PkgConfig` | Android | No pkg-config on Windows | `choco install pkgconfiglite` |
| `invalid linker name '-fuse-ld=gold'` | Android | LTO uses gold linker | Remove `-flto` from build.gradle |
| `Automatic Analysis is enabled` | SonarCloud | Both analysis modes active | Disable in SonarCloud UI |

---

## Diagnostic Commands

### Check vcpkg installed packages
```bash
# List installed packages for a triplet
$VCPKG_ROOT/vcpkg list

# Check specific package
ls $VCPKG_ROOT/installed/<triplet>/lib/ | grep <package>
```

### Check CMake configuration
```bash
# View CMake cache variables
cmake -LA -N build/

# Check specific variable
grep "ASAN" build/CMakeCache.txt
```

### Check workflow triggers
```bash
# List files that would trigger workflow
git diff --name-only HEAD~1 | grep -E "pattern"
```

### Debug Docker builds
```bash
# Build with verbose output
docker build --progress=plain .

# Run intermediate container
docker run -it <intermediate-image-id> /bin/bash
```

### Check Android NDK version
```bash
# In workflow
echo $ANDROID_NDK_HOME
cat $ANDROID_NDK_HOME/source.properties
```

---

## Error Categories

### 1. Dependency Resolution Errors
- Missing libraries (Lua, python3, pkg-config)
- Wrong library versions
- **Pattern:** `Could NOT find X` or `missing: X`

### 2. Compiler Errors
- MSVC ICE (C1001)
- Linker errors
- **Pattern:** `fatal error` or `error:`

### 3. Toolchain Errors
- Wrong linker (gold vs lld)
- Missing tools
- **Pattern:** `invalid` or `not found`

### 4. Configuration Errors
- Wrong paths
- Conflicting settings
- **Pattern:** Workflow doesn't trigger or silent failures

---

## Prevention Checklist

Before submitting workflow changes:

- [ ] Check path patterns match repository structure
- [ ] Verify all required dependencies are installed
- [ ] Test on fresh environment (no cache)
- [ ] Check CMake variables are set correctly
- [ ] Verify toolchain compatibility (NDK version, compiler version)
- [ ] Review SonarCloud/analysis tool settings

---

## Related Documentation

- [WORKFLOW_STATUS.md](WORKFLOW_STATUS.md) - Current status of all workflows
- [BUILD_GUIDE.md](BUILD_GUIDE.md) - How to build the project
- [DEPENDENCIES.md](DEPENDENCIES.md) - Required dependencies

---

## Changelog

| Date | Change |
|------|--------|
| 2025-12-05 | Initial documentation created |
| 2025-12-05 | Added Android build errors (pkg-config, LTO) |
| 2025-12-05 | Added MSVC ICE workaround details |
| 2025-12-05 | Added Docker python3 fix |
| 2025-12-05 | Added Emscripten Lua 5.4 fix |
