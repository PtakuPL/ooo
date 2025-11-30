# Building Canary Server on Windows

This guide will help you build the Canary server for Windows.

## Prerequisites

1. **Visual Studio 2022** with C++ development tools
   - Download from: https://visualstudio.microsoft.com/downloads/
   - Install "Desktop development with C++" workload

2. **Git**
   - Download from: https://git-scm.com/downloads

3. **CMake**
   - Download from: https://cmake.org/download/
   - Or install via winget: `winget install Kitware.CMake`

4. **Ninja** (optional, but recommended)
   - Download from: https://github.com/ninja-build/ninja/releases
   - Or install via winget: `winget install Ninja-build.Ninja`

5. **vcpkg** (package manager)
   - Clone: `git clone https://github.com/microsoft/vcpkg.git`
   - Run: `.\vcpkg\bootstrap-vcpkg.bat`
   - Set environment variable: `VCPKG_ROOT=C:\path\to\vcpkg`

## Building Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/opentibiabr/canary.git
   cd canary
   ```

2. **Install dependencies via vcpkg:**
   ```bash
   vcpkg install --triplet x64-windows-static
   ```

3. **Build using the provided script:**
   ```bash
   build_windows.bat
   ```

   Or manually:
   ```bash
   mkdir build
   cd build
   cmake .. -G Ninja ^
       -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake" ^
       -DVCPKG_TARGET_TRIPLET=x64-windows-static ^
       -DCMAKE_BUILD_TYPE=Release ^
       -DBUILD_STATIC_LIBRARY=ON ^
       -DSPEED_UP_BUILD_UNITY=ON ^
       -DOPTIONS_ENABLE_SCCACHE=ON
   ninja
   ```

4. **Find the binary:**
   - The compiled binary will be in `build/canary.exe`

## Alternative: Using Visual Studio

1. Open the project in Visual Studio
2. Select "windows-release" preset from CMakePresets.json
3. Build the solution

## Troubleshooting

- If you get vcpkg errors, make sure VCPKG_ROOT is set correctly
- If CMake can't find dependencies, run `vcpkg integrate install`
- For 32-bit build, change triplet to `x86-windows-static`

## Running the Server

1. Copy `config.lua.dist` to `config.lua` and configure it
2. Copy data files to appropriate directories
3. Run `canary.exe`

The server should now run on Windows with TTF/i18n support!