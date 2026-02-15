# OTClient Build Guide

This guide explains how to compile OTClient for all supported platforms: Windows, Linux (Ubuntu), Android, and Browser (WebAssembly/Emscripten).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Windows Build](#windows-build)
3. [Linux (Ubuntu) Build](#linux-ubuntu-build)
4. [Browser (Emscripten/WASM) Build](#browser-emscriptenwasm-build)
5. [Android Build](#android-build)
6. [Troubleshooting](#troubleshooting)
7. [CI/CD Workflows](#cicd-workflows)

---

## Prerequisites

### Common Requirements

- **CMake** 3.16+ (3.27+ recommended)
- **Ninja** build system (recommended)
- **Git** for source control
- **vcpkg** package manager

### vcpkg Setup

```bash
# Clone vcpkg
git clone https://github.com/microsoft/vcpkg.git

# Bootstrap vcpkg
# Linux/macOS:
./vcpkg/bootstrap-vcpkg.sh

# Windows:
.\vcpkg\bootstrap-vcpkg.bat

# Set environment variable
export VCPKG_ROOT=/path/to/vcpkg
```

---

## Windows Build

### Requirements

- **Visual Studio 2022** with C++ workload
- **Windows SDK** 10.0+
- **vcpkg** with `x64-windows-static` triplet

### Build Steps

```powershell
# Navigate to project directory
cd Tibia/silnik/canary_test/testyy

# Set vcpkg triplet
$env:VCPKG_DEFAULT_TRIPLET = "x64-windows-static"

# Configure CMake with Visual Studio generator
cmake -S . -B build `
  -G "Visual Studio 17 2022" -A x64 `
  -DCMAKE_TOOLCHAIN_FILE="$env:VCPKG_ROOT\scripts\buildsystems\vcpkg.cmake" `
  -DVCPKG_TARGET_TRIPLET="x64-windows-static"

# Build Release
cmake --build build --config Release --parallel

# Output: build/Release/otclient.exe
```

### Static vs Dynamic Build

| Triplet | Type | Runtime |
|---------|------|---------|
| `x64-windows-static` | Static | `/MT` |
| `x64-windows` | Dynamic | `/MD` (requires DLLs) |

For standalone distribution, use `x64-windows-static`.

---

## Linux (Ubuntu) Build

### Requirements

- **Ubuntu 24.04** (or compatible)
- **GCC 14+** or Clang 15+
- **Development packages**

### Install Dependencies

```bash
# Update system
sudo apt-get update

# Install build tools
sudo apt-get install -y \
  build-essential \
  gcc-14 g++-14 \
  cmake ninja-build \
  git curl zip unzip tar \
  pkg-config

# Install graphics/audio libraries
sudo apt-get install -y \
  libglew-dev \
  libx11-dev \
  libopenal-dev \
  linux-headers-$(uname -r)

# Set GCC 14 as default
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-14 100
```

### Build Steps

```bash
# Navigate to project directory
cd Tibia/silnik/canary_test/testyy

# Configure CMake
cmake -G Ninja -S . -B build-linux \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux \
  -DTOGGLE_BIN_FOLDER=ON \
  -DOPTIONS_ENABLE_IPO=OFF

# Build
cmake --build build-linux --target otclient

# Output: build-linux/bin/otclient
```

### Debug Build

```bash
cmake -G Ninja -S . -B build-debug \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=x64-linux

cmake --build build-debug
```

---

## Browser (Emscripten/WASM) Build

### Requirements

- **Emscripten SDK** 3.1.73+
- **vcpkg** with `wasm32-emscripten` triplet

### Install Emscripten

```bash
# Clone Emscripten SDK
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk

# Install and activate
./emsdk install 3.1.73
./emsdk activate 3.1.73
source ./emsdk_env.sh
```

### Build Steps

```bash
# Navigate to project directory
cd Tibia/silnik/canary_test/testyy

# Configure CMake for WASM
cmake -G Ninja -S . -B build-wasm \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake \
  -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake \
  -DVCPKG_TARGET_TRIPLET=wasm32-emscripten \
  -DVCPKG_OVERLAY_PORTS=$(pwd)/browser/overlay-ports \
  -DCMAKE_BUILD_TYPE=Release \
  -DOPTIONS_ENABLE_IPO=OFF \
  -DTOGGLE_BIN_FOLDER=ON

# Build
cmake --build build-wasm --target otclient

# Output: build-wasm/bin/otclient.html, otclient.js, otclient.wasm, otclient.data
```

### WASM-Specific Notes

1. **Lua vs LuaJIT**: WASM uses standard Lua (not LuaJIT) due to JIT limitations.
2. **Overlay Ports**: Custom vcpkg ports in `browser/overlay-ports/` are used for WASM-compatible libraries.
3. **Link Flags**: Emscripten-specific flags are set in `src/CMakeLists.txt` (lines 893-918).

### Testing WASM Build

```bash
# Start a local server
cd build-wasm/bin
python3 -m http.server 8080

# Open http://localhost:8080/otclient.html in browser
```

---

## Android Build

### Requirements

- **Android NDK** r23c
- **Android SDK** with build-tools 30
- **Java JDK** 17
- **Gradle** 8.11+

### Setup Android Environment

```powershell
# Windows PowerShell - Download required files
$files = @(
  @{ Name = 'ndk.zip'; Url = 'https://github.com/opentibiabr/otcv8/releases/download/binary-files/android-ndk-r23c-windows.zip' },
  @{ Name = 'android_libs.7z'; Url = 'https://github.com/opentibiabr/otcv8/releases/download/binary-files/android-libs.7z' }
)
foreach ($f in $files) { Invoke-WebRequest -Uri $f.Url -OutFile $f.Name }

# Extract to C:\Android\android-sdk
7z x ndk.zip -aoa -oC:\Android\android-sdk
7z x android_libs.7z -aoa -oC:\Android
```

### Build Steps

```bash
# Set environment variables
export ANDROID_NDK_HOME=C:\Android\android-sdk\android-ndk-r23c
export ANDROID_SDK_ROOT=$ANDROID_HOME
export VCPKG_ROOT=C:\vcpkg

# Navigate to android directory
cd Tibia/silnik/canary_test/testyy/android

# Build with Gradle
./gradlew assembleRelease --no-daemon --stacktrace

# Output: app/build/outputs/apk/release/app-release.apk
```

### Prepare Assets

```powershell
# Create data.zip for Android assets
cd Tibia/silnik/canary_test/testyy
powershell -ExecutionPolicy Bypass -File create_android_assets.ps1
```

---

## Troubleshooting

### Common Issues

#### 1. vcpkg Packages Not Found

```bash
# Ensure vcpkg is bootstrapped and manifest is installed
$VCPKG_ROOT/vcpkg install

# Check installed packages
$VCPKG_ROOT/vcpkg list
```

#### 2. LuaJIT Not Found (Linux)

```bash
# Install LuaJIT via vcpkg
$VCPKG_ROOT/vcpkg install luajit:x64-linux
```

#### 3. WASM Lua Build Issues

The project uses CMake's standard `FindLua` module for WASM builds instead of the custom one. This is handled in `src/CMakeLists.txt`:

```cmake
# For WASM builds, find Lua via CMake's standard FindLua module
set(_SAVED_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
list(REMOVE_ITEM CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
find_package(Lua REQUIRED)
set(CMAKE_MODULE_PATH ${_SAVED_CMAKE_MODULE_PATH})
```

#### 4. HarfBuzz/FriBidi Not Found

```bash
# These are part of the text stack (I18N support)
$VCPKG_ROOT/vcpkg install harfbuzz freetype fribidi
```

#### 5. Protobuf Version Mismatch

```bash
# Ensure consistent protobuf version
$VCPKG_ROOT/vcpkg upgrade protobuf --no-dry-run
```

### Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `TOGGLE_FRAMEWORK_GRAPHICS` | ON | Enable graphics subsystem |
| `TOGGLE_FRAMEWORK_SOUND` | ON | Enable sound subsystem |
| `TOGGLE_FRAMEWORK_XML` | ON | Enable XML parsing |
| `TOGGLE_FRAMEWORK_NET` | ON | Enable networking |
| `OTC_ENABLE_TTF` | ON | Enable TrueType font rendering |
| `OTC_ENABLE_HARFBUZZ` | ON | Enable HarfBuzz text shaping |
| `OTC_ENABLE_FRIBIDI` | ON | Enable bidirectional text (RTL) |
| `OPTIONS_ENABLE_IPO` | ON | Enable Link-Time Optimization |
| `TOGGLE_BIN_FOLDER` | OFF | Output to build/bin/ |
| `ASAN_ENABLED` | OFF | Enable AddressSanitizer |

---

## CI/CD Workflows

### Available Workflows

| Workflow | File | Platform | Trigger |
|----------|------|----------|---------|
| Windows | `build-windows.yml` | Windows | push, PR |
| Ubuntu | `build-ubuntu.yml` | Ubuntu 24.04 | push, PR |
| Browser | `build-browser.yml` | WASM | push, PR |
| Android | `build-android.yml` | Android | push, PR |

### Workflow Paths

All workflows are triggered by changes in:
- `Tibia/silnik/canary_test/testyy/src/**`
- Respective workflow file

### Manual Trigger

All workflows support `workflow_dispatch` for manual triggering via GitHub Actions UI.

---

## Build Output Locations

| Platform | Build Type | Output Path |
|----------|------------|-------------|
| Windows | Release | `build/Release/otclient.exe` |
| Linux | Release | `build-linux/bin/otclient` |
| WASM | Debug/Release | `build-wasm/bin/otclient.html` |
| Android | Release | `android/app/build/outputs/apk/release/app-release.apk` |

---

## Dependencies (vcpkg.json)

The project uses the following dependencies managed by vcpkg:

### Core Libraries
- `asio` - Networking
- `protobuf` - Protocol buffers
- `nlohmann-json` - JSON parsing
- `physfs` - Virtual filesystem
- `zlib` - Compression
- `liblzma` - LZMA compression
- `openssl` - Cryptography

### Graphics/UI
- `glew` - OpenGL extensions (Windows/Linux/macOS)
- `opengl` - OpenGL (Windows)
- `freetype` - Font rendering
- `harfbuzz` - Text shaping
- `fribidi` - Bidirectional text

### Audio
- `openal-soft` - Audio output
- `libogg` - Ogg container
- `libvorbis` - Vorbis audio codec

### Scripting
- `luajit` - Lua JIT compiler (Windows/Linux/macOS)
- `lua` - Standard Lua (WASM)

### Platform-Specific
- `angle` - OpenGL ES on Windows
- `discord-rpc` - Discord integration

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Project architecture
- [TEXT_RENDERING.md](TEXT_RENDERING.md) - Text rendering and I18N
- [MODULES.md](MODULES.md) - Lua modules documentation
- [SOURCE_CODE.md](SOURCE_CODE.md) - C++ source code documentation
