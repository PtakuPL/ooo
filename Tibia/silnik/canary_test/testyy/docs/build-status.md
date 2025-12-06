# Build Status Overview

**Last Updated:** 2025-12-06

## Build Status Summary

| Platform | Status | Notes |
|----------|--------|-------|
| Windows | ⚠ Needs baseline update | vcpkg commit/baseline brak wersji `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0`; zaktualizuj baseline lub obniż wersje portów |
| Ubuntu 24.04 | ✅ Ready | Requires GCC 14, system deps |
| Emscripten (WASM) | ✅ Fixed | Lua module path fix applied |
| Android | ✅ Ready | NDK r23c, Gradle 8.11 |

## Recent Fixes

### Emscripten/WASM Build Fix (2025-12-05)
- **File:** `src/CMakeLists.txt` (lines 483-496)
- **Issue:** Custom `FindLua.cmake` incompatible with WASM
- **Solution:** Use CMake's standard FindLua module for WASM builds

### Windows vcpkg baseline note (2025-12-06)
- **Issue:** `run-vcpkg` na commit-cie `5b121431` nie znajduje wersji portów `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0`.
- **Action:** Podnieść `builtin-baseline`/`vcpkgGitCommitId` do wersji zawierającej te porty lub zredukować wersje portów do dostępnych.

## Build Instructions

### Linux (Ubuntu 24.04)
```bash
# Install dependencies
sudo apt-get install -y gcc-14 g++-14 cmake ninja-build libglew-dev libx11-dev

# Configure and build
cmake -G Ninja -S . -B build \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux
cmake --build build --target otclient
```

See [linux-build-deps.md](./linux-build-deps.md) for full dependency list.

### Windows
```powershell
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake" `
  -DVCPKG_TARGET_TRIPLET=x64-windows-static
cmake --build build --config Release --parallel
```

### Emscripten (WASM)
```bash
source $EMSDK/emsdk_env.sh
cmake -G Ninja -S . -B build-wasm \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=wasm32-emscripten
cmake --build build-wasm --target otclient
```

## Output
- No compiled binaries stored in repository
- Build produces `./otclient` (or `otclient.exe` on Windows)
- WASM build produces `otclient.html`, `otclient.js`, `otclient.wasm`

## Related Documentation
- [BUILD_GUIDE.md](BUILD_GUIDE.md) - Comprehensive build guide
- [DEPENDENCIES.md](DEPENDENCIES.md) - Full dependency documentation
- [linux-build-deps.md](linux-build-deps.md) - Linux dependencies
- [../CI_STATUS.md](../CI_STATUS.md) - CI/CD workflow status
