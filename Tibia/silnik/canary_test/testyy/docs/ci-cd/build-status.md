# Build Status Overview

**Last Updated:** 2025-12-12

## Build Status Summary

| Platform | Status | Notes |
|----------|--------|-------|
| Windows | ⚠ Needs baseline update + SonarCloud fix | vcpkg baseline nadal nie zawiera `abseil@20250814.1`/`angle@chromium_7258#2`/`asio@1.32.0`; workflow SonarCloud wymaga patcha na porty |
| Ubuntu 24.04 | ✅ Ready (SonarCloud only) | Automatic Analysis w SonarCloud wyłączone; jedyny aktywny workflow to `analysis-sonarcloud-linux.yml` |
| Emscripten (WASM) | ✅ Workflow gotowy | `analysis-sonarcloud-web.yml` używa Emscripten 3.1.51; czeka na test po zakończeniu poprawek Windows/Android |
| Android | ⚠ Build bez dźwięku | Workflow SonarCloud działa tylko z `-DOTC_ENABLE_SOUND=OFF` (brak OpenAL w toolchainie) |

## Recent Fixes / Notes

- **2025-12-12 – SonarCloud focus:** wszystkie workflow poza czterema `analysis-sonarcloud-*` zostały tymczasowo wyłączone (tylko `workflow_dispatch`). Automatic Analysis w projekcie SonarCloud jest wyłączone – uruchamiamy wyłącznie CI analizy.
- **2025-12-12 – Windows/Android workflow:** dodane kroki instalacji Ninja + MSVC env (Windows) oraz `-DOTC_ENABLE_SOUND=OFF` (Android) + wspólny `sonar-project.properties` dla klienta/serwera.
- **2025-12-13 – Web workflow:** na czas analiz SonarCloud wyłączone PhysFS (`-DOTC_ENABLE_PHYSFS=OFF` w `analysis-sonarcloud-web.yml`); w `src/CMakeLists.txt` dodany alias `OTC_ENABLE_SOUND` → `TOGGLE_FRAMEWORK_SOUND`, żeby flagi z CI były respektowane.
- **2025-12-06 – Emscripten fix:** `FindLua.cmake` zastąpiony standardowym modułem CMake (szczegóły w `ci-errors.md`).
- **Windows vcpkg baseline:** nadal wymagane podniesienie `builtin-baseline`/`vcpkgGitCommitId`, aby porty `abseil@20250814.1`, `angle@chromium_7258#2`, `asio@1.32.0` były dostępne dla SonarCloud run.

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
