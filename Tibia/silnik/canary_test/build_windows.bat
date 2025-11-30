@echo off
echo Building Canary Server for Windows
echo ===================================

REM Check if vcpkg is installed
if not defined VCPKG_ROOT (
    echo Error: VCPKG_ROOT environment variable not set.
    echo Please install vcpkg and set VCPKG_ROOT.
    echo Download from: https://github.com/microsoft/vcpkg
    pause
    exit /b 1
)

REM Create build directory
if not exist build mkdir build
cd build

REM Configure with CMake
echo Configuring with CMake...
cmake .. -G Ninja ^
    -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake" ^
    -DVCPKG_TARGET_TRIPLET=x64-windows-static ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_STATIC_LIBRARY=ON ^
    -DSPEED_UP_BUILD_UNITY=ON ^
    -DOPTIONS_ENABLE_SCCACHE=ON

if errorlevel 1 (
    echo CMake configuration failed!
    pause
    exit /b 1
)

REM Build
echo Building...
ninja

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo Build completed successfully!
echo Binary should be in build/canary.exe
pause