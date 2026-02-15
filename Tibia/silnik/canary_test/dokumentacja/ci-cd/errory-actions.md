sonarcloud

Annotations
2 errors and 8 warnings
sonarcloud
Process completed with exit code 1.
sonarcloud: src/framework/core/asyncdispatcher.cpp#L41
conflicting declaration ‘thread_pool<...auto...> g_asyncDispatcher’
sonarcloud: src/framework/platform/platformwindow.h#L84
unused parameter ‘color’ [-Wunused-parameter]
sonarcloud: src/framework/core/eventdispatcher.h#L104
extra ‘;’ [-Wpedantic]
sonarcloud
glew requires the following libraries from the system package manager:
sonarcloud
[LogCollection][Warn]File not found:'-- Loading CMake variables from /home/runner/work/testyy/testyy/vcpkg/buildtrees/openssl/cmake-get-vars_C_CXX-x64-linux.cmake.log'.
sonarcloud
[LogCollection][Warn]File not found:'-- Loading CMake variables from /home/runner/work/testyy/testyy/vcpkg/buildtrees/luajit/cmake-get-vars_C_CXX-x64-linux.cmake.log'.
sonarcloud
[LogCollection][Warn]File not found:'-- Loading CMake variables from /home/runner/work/testyy/testyy/vcpkg/buildtrees/harfbuzz/cmake-get-vars_C_CXX-x64-linux.cmake.log'.
sonarcloud
glew requires the following libraries from the system package manager:
sonarcloud
[LogCollection][Warn]File not found:'-- Loading CMake variables from /home/runner/work/testyy/testyy/vcpkg/buildtrees/fribidi/cmake-get-vars_C_CXX-x64-linux.cmake.log'.

-- The CXX compiler identification is GNU 12.3.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/gcc-12 - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/g++-12 - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Enabled: ccache
-- Enabled: ipo
-- Found ZLIB: optimized;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/lib/libz.a;debug;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/libz.a (found version "1.3.1")
-- Found BZip2: optimized;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/lib/libbz2.a;debug;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/libbz2d.a (found version "1.0.8")
-- Looking for BZ2_bzCompressInit
-- Looking for BZ2_bzCompressInit - found
-- Found PNG: optimized;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/lib/libpng16.a;debug;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/libpng16d.a (found version "1.6.51")
-- Found PkgConfig: /usr/bin/pkg-config (found version "0.29.2")
-- Checking for module 'fribidi'
--   Found fribidi, version 1.0.16
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD
-- Performing Test CMAKE_HAVE_LIBC_PTHREAD - Success
-- Found Threads: TRUE
-- Found Protobuf: /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/tools/protobuf/protoc (found version "29.5.0")
-- Found Protobuf Compiler: /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/tools/protobuf/protoc
-- Use precompiled header: OFF
-- Disabled: asan
-- Enabled: DEBUG LOG
-- Build type: Debug
-- Build commit: 
-- Build revision: 
-- Checking for module 'physfs'
--   Found physfs, version 3.2.0
-- Found LibLZMA: optimized;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/lib/liblzma.a;debug;/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/liblzma.a (found version "5.8.1")
-- Found X11: /usr/include
-- Looking for XOpenDisplay in /usr/lib/x86_64-linux-gnu/libX11.so;/usr/lib/x86_64-linux-gnu/libXext.so
-- Looking for XOpenDisplay in /usr/lib/x86_64-linux-gnu/libX11.so;/usr/lib/x86_64-linux-gnu/libXext.so - found
-- Looking for gethostbyname
-- Looking for gethostbyname - found
-- Looking for connect
-- Looking for connect - found
-- Looking for remove
-- Looking for remove - found
-- Looking for shmat
-- Looking for shmat - found
-- Looking for IceConnectionNumber in ICE
-- Looking for IceConnectionNumber in ICE - found
-- Found VorbisFile: /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/libvorbisfile.a
CMake Warning (dev) at /usr/local/share/cmake-3.31/Modules/FindPackageHandleStandardArgs.cmake:441 (message):
  The package name passed to `find_package_handle_standard_args` (X11) does
  not match the name of the calling package (OpenGL).  This can lead to
  problems in calling code that expects `find_package` result variables
  (e.g., `_FOUND`) to follow a certain pattern.
Call Stack (most recent call first):
  /usr/local/share/cmake-3.31/Modules/FindX11.cmake:676 (find_package_handle_standard_args)
  cmake/FindOpenGL.cmake:128 (INCLUDE)
  vcpkg/scripts/buildsystems/vcpkg.cmake:908 (_find_package)
  src/CMakeLists.txt:440 (find_package)
This warning is for project developers.  Use -Wno-dev to suppress it.

-- Found LuaJIT: /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/libluajit-5.1.a
-- Configuring done (1303.2s)
-- Generating done (0.0s)
-- Build files have been written to: /home/runner/work/testyy/testyy/build/linux-debug
[1/173] Running cpp protocol buffer compiler on /home/runner/work/testyy/testyy/src/protobuf/sounds.proto
[2/173] Running cpp protocol buffer compiler on /home/runner/work/testyy/testyy/src/protobuf/staticdata.proto
[3/173] Running cpp protocol buffer compiler on /home/runner/work/testyy/testyy/src/protobuf/appearances.proto
[4/173] Building CXX object src/protobuf/CMakeFiles/protobuf.dir/sounds.pb.cc.o
[5/173] Building CXX object src/protobuf/CMakeFiles/protobuf.dir/appearances.pb.cc.o
[6/173] Building CXX object src/protobuf/CMakeFiles/protobuf.dir/staticdata.pb.cc.o
[7/173] Linking CXX static library src/protobuf/libprotobuf.a
[8/173] Building CXX object src/CMakeFiles/otclient.dir/framework/core/asyncdispatcher.cpp.o
FAILED: [code=1] src/CMakeFiles/otclient.dir/framework/core/asyncdispatcher.cpp.o 
/usr/bin/ccache /usr/bin/g++-12 -DAL_LIBTYPE_STATIC -DCLIENT -DCPPHTTPLIB_BROTLI_SUPPORT -DCPPHTTPLIB_USE_NON_BLOCKING_GETADDRINFO -DDEBUG_LOG=ON -DFMT_HEADER_ONLY=1 -DFRAMEWORK_GRAPHICS -DFRAMEWORK_NET -DFRAMEWORK_SOUND -DFRAMEWORK_XML -DOTC_ENABLE_FRIBIDI -DOTC_ENABLE_HARFBUZZ -DOTC_ENABLE_TTF -D_DISABLE_STRING_ANNOTATION -D_DISABLE_VECTOR_ANNOTATION -I/home/runner/work/testyy/testyy/src -I/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/include/luajit-2.1 -I/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/pkgconfig/../../../include -I/home/runner/work/testyy/testyy/build/linux-debug/src/protobuf -I/home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/debug/lib/pkgconfig/../../../include/fribidi -isystem /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/include -isystem /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/include/stduuid -isystem /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/include/AL -isystem /home/runner/work/testyy/testyy/build/linux-debug/vcpkg_installed/x64-linux/include/harfbuzz -g -std=gnu++20 -flto=auto -fno-fat-lto-objects -fPIE   -D"VERSION=1.0.0" -D"BUILD_TYPE=\"Debug\"" -D"BUILD_COMMIT=\"\"" -D"BUILD_REVISION=\"\"" -Wno-deprecated-declarations -Wall -Wextra -Wpedantic -MD -MT src/CMakeFiles/otclient.dir/framework/core/asyncdispatcher.cpp.o -MF src/CMakeFiles/otclient.dir/framework/core/asyncdispatcher.cpp.o.d -o src/CMakeFiles/otclient.dir/framework/core/asyncdispatcher.cpp.o -c /home/runner/work/testyy/testyy/src/framework/core/asyncdispatcher.cpp
Error: /home/runner/work/testyy/testyy/src/framework/core/asyncdispatcher.cpp:41:17: error: conflicting declaration ‘thread_pool<...auto...> g_asyncDispatcher’
   41 | BS::thread_pool g_asyncDispatcher{ getThreadCount() };
      |                 ^~~~~~~~~~~~~~~~~
In file included from /home/runner/work/testyy/testyy/src/framework/core/asyncdispatcher.cpp:23:
/home/runner/work/testyy/testyy/src/framework/core/asyncdispatcher.h:27:24: note: previous declaration as ‘BS::thread_pool<0> g_asyncDispatcher’
   27 | extern BS::thread_pool g_asyncDispatcher;
      |                        ^~~~~~~~~~~~~~~~~
[9/173] Building CXX object src/CMakeFiles/otclient.dir/framework/core/application.cpp.o
In file included from /home/runner/work/testyy/testyy/src/framework/core/application.cpp:27:
Warning: /home/runner/work/testyy/testyy/src/framework/core/eventdispatcher.h:104:7: warning: extra ‘;’ [-Wpedantic]
  104 |     };;
      |       ^
      |       -
In file included from /home/runner/work/testyy/testyy/src/framework/core/graphicalapplication.h:30,
                 from /home/runner/work/testyy/testyy/src/framework/graphics/drawpool.h:30,
                 from /home/runner/work/testyy/testyy/src/framework/graphics/drawpoolmanager.h:26,
                 from /home/runner/work/testyy/testyy/src/framework/core/application.cpp:30:
/home/runner/work/testyy/testyy/src/framework/platform/platformwindow.h: In member function ‘virtual void PlatformWindow::setTitleBarColor(const Color&)’:
Warning: /home/runner/work/testyy/testyy/src/framework/platform/platformwindow.h:84:48: warning: unused parameter ‘color’ [-Wunused-parameter]
   84 |     virtual void setTitleBarColor(const Color& color) {}
      |                                   ~~~~~~~~~~~~~^~~~~
ninja: build stopped: subcommand failed.
Error: Process completed with exit code 1.



build-windows 

10s
17s
Run lukka/run-vcpkg@v11
  with:
    vcpkgGitURL: https://github.com/microsoft/vcpkg.git
    vcpkgGitCommitId: 5b1214315250939257ef5d62ecdcbca18cf4fb1c
    runVcpkgInstall: true
    vcpkgJsonGlob: vcpkg.json
    vcpkgConfigurationJsonGlob: vcpkg-configuration.json
    doNotCache: false
    vcpkgDirectory: D:\a\testyy\testyy/vcpkg
    doNotUpdateVcpkg: false
    vcpkgJsonIgnores: ['**/vcpkg/**']
    runVcpkgFormatString: [`install`, `--recurse`, `--clean-after-build`, `--x-install-root`, `$[env.VCPKG_INSTALLED_DIR]`, `--triplet`, `$[env.VCPKG_DEFAULT_TRIPLET]`]
    useShell: true
    logCollectionRegExps: \s*"(.+CMakeOutput\.log)"\.\s*;\s*"(.+CMakeError\.log)"\.\s*;\s*(.+out\.log)\s*;\s+(.+err\.log)\s*;\s*(.+vcpkg.+\.log)\s*
  env:
    VCPKG_DEFAULT_TRIPLET: x64-windows-static
    VCPKG_DEFAULT_HOST_TRIPLET: x64-windows
    VCPKG_FEATURE_FLAGS: manifests,binarycaching
    VCPKG_BINARY_SOURCES: clear;x-gha,readwrite
    CMAKE_BUILD_PARALLEL_LEVEL: 8
    CommandPromptType: Native
    DevEnvDir: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\
    ExtensionSdkDir: C:\Program Files (x86)\Microsoft SDKs\Windows Kits\10\ExtensionSDKs
    EXTERNAL_INCLUDE: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\include;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\ATLMFC\include;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\VS\include;C:\Program Files (x86)\Windows Kits\10\include\10.0.26100.0\ucrt;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\um;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\shared;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\winrt;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\cppwinrt;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\include\um
    Framework40Version: v4.0
    FrameworkDir: C:\Windows\Microsoft.NET\Framework64\
    FrameworkDir64: C:\Windows\Microsoft.NET\Framework64\
    FrameworkVersion: v4.0.30319
    FrameworkVersion64: v4.0.30319
    FSHARPINSTALLDIR: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\FSharp\Tools
    HTMLHelpDir: C:\Program Files (x86)\HTML Help Workshop
    IFCPATH: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\ifc\x64
    INCLUDE: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\include;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\ATLMFC\include;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\VS\include;C:\Program Files (x86)\Windows Kits\10\include\10.0.26100.0\ucrt;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\um;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\shared;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\winrt;C:\Program Files (x86)\Windows Kits\10\\include\10.0.26100.0\\cppwinrt;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\include\um
    is_x64_arch: true
    LIB: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\ATLMFC\lib\x64;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\lib\x64;C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\lib\um\x64;C:\Program Files (x86)\Windows Kits\10\lib\10.0.26100.0\ucrt\x64;C:\Program Files (x86)\Windows Kits\10\\lib\10.0.26100.0\\um\x64
    LIBPATH: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\ATLMFC\lib\x64;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\lib\x64;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\lib\x86\store\references;C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.26100.0;C:\Program Files (x86)\Windows Kits\10\References\10.0.26100.0;C:\Windows\Microsoft.NET\Framework64\v4.0.30319
    NETFXSDKDir: C:\Program Files (x86)\Windows Kits\NETFXSDK\4.8\
    Path: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\bin\HostX64\x64;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC\VCPackages;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TestWindow;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\bin\Roslyn;C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\;C:\Program Files (x86)\HTML Help Workshop;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\FSharp\Tools;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Team Tools\DiagnosticsHub\Collector;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\Extensions\Microsoft\CodeCoverage.Console;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\Llvm\x64\bin;C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\\x64;C:\Program Files (x86)\Windows Kits\10\bin\\x64;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\\MSBuild\Current\Bin\amd64;C:\Windows\Microsoft.NET\Framework64\v4.0.30319;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\;C:\Program Files\MongoDB\Server\7.0\bin;C:\vcpkg;C:\tools\zstd;C:\hostedtoolcache\windows\stack\3.7.1\x64;C:\cabal\bin;C:\\ghcup\bin;C:\mingw64\bin;C:\Program Files\dotnet;C:\Program Files\MySQL\MySQL Server 8.0\bin;C:\Program Files\R\R-4.5.2\bin\x64;C:\SeleniumWebDrivers\GeckoDriver;C:\SeleniumWebDrivers\EdgeDriver\;C:\SeleniumWebDrivers\ChromeDriver;C:\Program Files (x86)\sbt\bin;C:\Program Files (x86)\GitHub CLI;C:\Program Files\Git\bin;C:\Program Files (x86)\pipx_bin;C:\npm\prefix;C:\hostedtoolcache\windows\go\1.24.9\x64\bin;C:\hostedtoolcache\windows\Python\3.9.13\x64\Scripts;C:\hostedtoolcache\windows\Python\3.9.13\x64;C:\hostedtoolcache\windows\Ruby\3.3.10\x64\bin;C:\Program Files\OpenSSL\bin;C:\tools\kotlinc\bin;C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.17-10\x64\bin;C:\Program Files\ImageMagick-7.1.2-Q16-HDRI;C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin;C:\ProgramData\kind;C:\ProgramData\Chocolatey\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\PowerShell\7\;C:\Program Files\Microsoft\Web Platform Installer\;C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\;C:\Program Files\Microsoft SQL Server\150\Tools\Binn\;C:\Program Files\dotnet\;C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\;C:\Program Files (x86)\WiX Toolset v3.14\bin;C:\Program Files\Microsoft SQL Server\130\DTS\Binn\;C:\Program Files\Microsoft SQL Server\140\DTS\Binn\;C:\Program Files\Microsoft SQL Server\150\DTS\Binn\;C:\Program Files\Microsoft SQL Server\160\DTS\Binn\;C:\Program Files\Microsoft SQL Server\170\DTS\Binn\;C:\ProgramData\chocolatey\lib\pulumi\tools\Pulumi\bin;C:\Program Files\CMake\bin;C:\Strawberry\c\bin;C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin;C:\ProgramData\chocolatey\lib\maven\apache-maven-3.9.11\bin;C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code;C:\Program Files\Microsoft SDKs\Service Fabric\Tools\ServiceFabricLocalClusterManager;C:\Program Files\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Program Files\GitHub CLI\;c:\tools\php;C:\Program Files\Amazon\AWSCLIV2\;C:\Program Files\Amazon\SessionManagerPlugin\bin\;C:\Program Files\Amazon\AWSSAMCLI\bin\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files\mongosh\;C:\Program Files\LLVM\bin;C:\Program Files (x86)\LLVM\bin;C:\Users\runneradmin\.dotnet\tools;C:\Users\runneradmin\.cargo\bin;C:\Users\runneradmin\AppData\Local\Microsoft\WindowsApps;C:\Program Files (x86)\Microsoft Visual Studio\Installer;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\CommonExtensions\Microsoft\CMake\Ninja;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC\Linux\bin\ConnectionManagerExe;C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\vcpkg
    Platform: x64
    UCRTVersion: 10.0.26100.0
    UniversalCRTSdkDir: C:\Program Files (x86)\Windows Kits\10\
    VCIDEInstallDir: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\VC\
    VCINSTALLDIR: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\
    VCPKG_ROOT: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\vcpkg
    VCToolsInstallDir: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.44.35207\
    VCToolsRedistDir: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Redist\MSVC\14.44.35112\
    VCToolsVersion: 14.44.35207
    VisualStudioVersion: 17.0
    VS170COMNTOOLS: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\
    VSCMD_ARG_app_plat: Desktop
    VSCMD_ARG_HOST_ARCH: x64
    VSCMD_ARG_TGT_ARCH: x64
    VSCMD_VER: 17.14.19
    VSINSTALLDIR: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\
    VSSDK150INSTALL: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VSSDK
    VSSDKINSTALL: C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VSSDK
    WindowsLibPath: C:\Program Files (x86)\Windows Kits\10\UnionMetadata\10.0.26100.0;C:\Program Files (x86)\Windows Kits\10\References\10.0.26100.0
    WindowsSdkBinPath: C:\Program Files (x86)\Windows Kits\10\bin\
    WindowsSdkDir: C:\Program Files (x86)\Windows Kits\10\
    WindowsSDKLibVersion: 10.0.26100.0\
    WindowsSdkVerBinPath: C:\Program Files (x86)\Windows Kits\10\bin\10.0.26100.0\
    WindowsSDKVersion: 10.0.26100.0\
    WindowsSDK_ExecutablePath_x64: C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\x64\
    WindowsSDK_ExecutablePath_x86: C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\
    __DOTNET_ADD_64BIT: 1
    __DOTNET_PREFERRED_BITNESS: 64
    __VSCMD_PREINIT_PATH: C:\Program Files\MongoDB\Server\7.0\bin;C:\vcpkg;C:\tools\zstd;C:\hostedtoolcache\windows\stack\3.7.1\x64;C:\cabal\bin;C:\\ghcup\bin;C:\mingw64\bin;C:\Program Files\dotnet;C:\Program Files\MySQL\MySQL Server 8.0\bin;C:\Program Files\R\R-4.5.2\bin\x64;C:\SeleniumWebDrivers\GeckoDriver;C:\SeleniumWebDrivers\EdgeDriver\;C:\SeleniumWebDrivers\ChromeDriver;C:\Program Files (x86)\sbt\bin;C:\Program Files (x86)\GitHub CLI;C:\Program Files\Git\bin;C:\Program Files (x86)\pipx_bin;C:\npm\prefix;C:\hostedtoolcache\windows\go\1.24.9\x64\bin;C:\hostedtoolcache\windows\Python\3.9.13\x64\Scripts;C:\hostedtoolcache\windows\Python\3.9.13\x64;C:\hostedtoolcache\windows\Ruby\3.3.10\x64\bin;C:\Program Files\OpenSSL\bin;C:\tools\kotlinc\bin;C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.17-10\x64\bin;C:\Program Files\ImageMagick-7.1.2-Q16-HDRI;C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin;C:\ProgramData\kind;C:\ProgramData\Chocolatey\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\PowerShell\7\;C:\Program Files\Microsoft\Web Platform Installer\;C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\;C:\Program Files\Microsoft SQL Server\150\Tools\Binn\;C:\Program Files\dotnet\;C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\;C:\Program Files (x86)\WiX Toolset v3.14\bin;C:\Program Files\Microsoft SQL Server\130\DTS\Binn\;C:\Program Files\Microsoft SQL Server\140\DTS\Binn\;C:\Program Files\Microsoft SQL Server\150\DTS\Binn\;C:\Program Files\Microsoft SQL Server\160\DTS\Binn\;C:\Program Files\Microsoft SQL Server\170\DTS\Binn\;C:\ProgramData\chocolatey\lib\pulumi\tools\Pulumi\bin;C:\Program Files\CMake\bin;C:\Strawberry\c\bin;C:\Strawberry\perl\site\bin;C:\Strawberry\perl\bin;C:\ProgramData\chocolatey\lib\maven\apache-maven-3.9.11\bin;C:\Program Files\Microsoft Service Fabric\bin\Fabric\Fabric.Code;C:\Program Files\Microsoft SDKs\Service Fabric\Tools\ServiceFabricLocalClusterManager;C:\Program Files\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\Git\mingw64\bin;C:\Program Files\Git\usr\bin;C:\Program Files\GitHub CLI\;c:\tools\php;C:\Program Files (x86)\sbt\bin;C:\Program Files\Amazon\AWSCLIV2\;C:\Program Files\Amazon\SessionManagerPlugin\bin\;C:\Program Files\Amazon\AWSSAMCLI\bin\;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files\mongosh\;C:\Program Files\LLVM\bin;C:\Program Files (x86)\LLVM\bin;C:\Users\runneradmin\.dotnet\tools;C:\Users\runneradmin\.cargo\bin;C:\Users\runneradmin\AppData\Local\Microsoft\WindowsApps;C:\Program Files (x86)\Microsoft Visual Studio\Installer
Prepare output directories
  The vpckg root directory: 'D:\a\testyy\testyy\vcpkg'
⏱ elapsed: 0.005 seconds
Computing vcpkg cache key
  Adding user provided vcpkg's Git commit id '5b1214315250939257ef5d62ecdcbca18cf4fb1c' to cache key.
  Computed key: {"primary":"runnerOS=win2520251102.77.1-vcpkgGitCommit=5b1214315250939257ef5d62ecdcbca18cf4fb1c","restore":[]}
⏱ elapsed: 0.001 seconds
Restore vcpkg installation from cache (not the packages, that is done by vcpkg via Binary Caching stored onto the GitHub Action cache)
  Cache key: 'runnerOS=win2520251102.77.1-vcpkgGitCommit=5b1214315250939257ef5d62ecdcbca18cf4fb1c'
  Cache restore keys: ''
  Cached paths: 'D:\a\testyy\testyy\vcpkg\*,.\!D:\a\testyy\testyy\vcpkg\installed,.\!D:\a\testyy\testyy\vcpkg\vcpkg_installed,.\!D:\a\testyy\testyy\vcpkg\packages,.\!D:\a\testyy\testyy\vcpkg\buildtrees,.\!D:\a\testyy\testyy\vcpkg\downloads'
  Warning: Failed to restore: Cache service responded with 400
  Cache miss.
⏱ elapsed: 0.531 seconds
Running command '"C:\Program Files\Git\bin\git.exe"' with args '^"submodule^",^"status^",^"D:\a\testyy\testyy\vcpkg^"' in current directory 'D:\a\testyy\testyy'.
error: pathspec 'D:\a\testyy\testyy\vcpkg' did not match any file(s) known to git
Searching for vcpkg.json with glob expression 'vcpkg.json'
  Found vcpkg.json at 'vcpkg.json'.
⏱ elapsed: 0.008 seconds
Setup to run on GitHub Action runners
  Set the workflow environment variable 'ACTIONS_CACHE_URL' to value 'https://artifactcache.actions.githubusercontent.com/zDEEOQ1iUVMIAsEGExM8GeoahOusQhQyhbddg6XaMeyRgzmjmb/'
  Set the workflow environment variable 'ACTIONS_RUNTIME_TOKEN' to value '***'
⏱ elapsed: 0.001 seconds
Retrieving the vcpkg Git commit id at: 'D:\a\testyy\testyy\vcpkg'
  Fetching the Git commit id at 'D:\a\testyy\testyy\vcpkg' ...
  Running command '"C:\Program Files\Git\bin\git.exe"' with args '^"rev-parse^",^"HEAD^"' in current directory 'D:\a\testyy\testyy\vcpkg'.
  d90a1dba9ad588ead72f675d33d47c276d3c9e6e
⏱ elapsed: 0.159 seconds
Check whether vcpkg repository is up to date
  Checking whether vcpkg's repository is updated to commit id 'd90a1dba9ad588ead72f675d33d47c276d3c9e6e' ...
  Current commit id of vcpkg: 'd90a1dba9ad588ead72f675d33d47c276d3c9e6e'.
  Is vcpkg repository updated? No
⏱ elapsed: 0.001 seconds
Download vcpkg source code repository
  Cloning vcpkg in 'D:\a\testyy\testyy\vcpkg'...
  Running command '"C:\Program Files\Git\bin\git.exe"' with args '^"clone^",^"https://github.com/microsoft/vcpkg.git^",^"-n^",^".^"' in current directory 'D:\a\testyy\testyy\vcpkg'.
  Cloning into '.'...
  Running command '"C:\Program Files\Git\bin\git.exe"' with args '^"checkout^",^"--force^",^"5b1214315250939257ef5d62ecdcbca18cf4fb1c^"' in current directory 'D:\a\testyy\testyy\vcpkg'.
  Note: switching to '5b1214315250939257ef5d62ecdcbca18cf4fb1c'.
  
  You are in 'detached HEAD' state. You can look around, make experimental
  changes and commit them, and you can discard any commits you make in this
  state without impacting any branches by switching back to a branch.
  
  If you want to create a new branch to retain commits you create, you may
  do so (now or later) by using -c with the switch command. Example:
  
    git switch -c <new-branch-name>
  
  Or undo this operation with:
  
    git switch -
  
  Turn off this advice by setting config variable advice.detachedHead to false
  
  HEAD is now at 5b12143152 Update vcpkg-tool to 2023-03-29. (#30503)
  Clone vcpkg in 'D:\a\testyy\testyy\vcpkg'.
⏱ elapsed: 13.317 seconds
Build vcpkg executable
  Running command '"C:\Windows\system32\cmd.exe"' with args '^"/c^",^"D:\a\testyy\testyy\vcpkg\bootstrap-vcpkg.bat^"' in current directory 'D:\a\testyy\testyy\vcpkg'.
  Downloading https://github.com/microsoft/vcpkg-tool/releases/download/2023-03-29/vcpkg.exe -> D:\a\testyy\testyy\vcpkg\vcpkg.exe... done.
  Validating signature... done.
  
  Telemetry
  ---------
  vcpkg collects usage data in order to help us improve your experience.
  The data collected by Microsoft is anonymous.
  You can opt-out of telemetry by re-running the bootstrap-vcpkg script with -disableMetrics,
  passing --disable-metrics to vcpkg on the command line,
  or by setting the VCPKG_DISABLE_METRICS environment variable.
  
  Read more about vcpkg telemetry at docs/about/privacy.md
  Fetching the Git commit id at 'D:\a\testyy\testyy\vcpkg' ...
  Running command '"C:\Program Files\Git\bin\git.exe"' with args '^"rev-parse^",^"HEAD^"' in current directory 'D:\a\testyy\testyy\vcpkg'.
  5b1214315250939257ef5d62ecdcbca18cf4fb1c
  Stored last built vcpkg commit id '5b1214315250939257ef5d62ecdcbca18cf4fb1c' in file 'D:\a\testyy\testyy\vcpkg\vcpkgLastBuiltCommitId'.
⏱ elapsed: 1.574 seconds
Add to PATH vcpkg at 'D:\a\testyy\testyy\vcpkg'
⏱ elapsed: 0.000 seconds
Install/Update ports using vcpkg.json
  Running 'vcpkg install,--recurse,--clean-after-build,--x-install-root,D:/a/testyy/testyy/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed,--triplet,x64-windows-static' in directory 'D:\a\testyy\testyy' ...
  Running command '"D:\a\testyy\testyy\vcpkg\vcpkg.exe"' with args '^"install^",^"--recurse^",^"--clean-after-build^",^"--x-install-root^",^"D:/a/testyy/testyy/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed^",^"--triplet^",^"x64-windows-static^"' in current directory 'D:\a\testyy\testyy'.
  warning: The vcpkg D:\a\testyy\testyy\vcpkg\vcpkg.exe is using detected vcpkg root D:\a\testyy\testyy\vcpkg and ignoring mismatched VCPKG_ROOT environment value C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\vcpkg. To suppress this message, unset the environment variable or use the --vcpkg-root command line switch.
  error: no version database entry for abseil at 20250814.1.
  Available versions:
      20230125.0#1
      20230125.0
      20220623.1
      20211102.1
      20210324.2#1
      20210324.2
      2021-03-24#1
      2021-03-24
      2020-09-23#3
      2020-09-23#2
      2020-09-23#1
      2020-09-23
      2020-03-03#8
      2020-03-03#7
      2020-03-03-7
      2020-03-03-6
      2020-03-03-5
      2020-03-03-4
      2020-03-03-3
      2020-03-03-2
      2020-03-03-1
      2020-03-03
      2019-12-19
      2019-05-08-1
      2019-05-08
      2019-05-07
      2019-04-19-1
      2019-04-19
      2019-03-29
      2019_01_30-1
      2019-01-30
      2019-01-09-1
      2018-12-14
      2018-11-08-1
      2018-11-08
      2018-11-01
      2018-10-25
      2018-10-11
      2018-09-18-3
      2018-09-18
      2018-08-03
      2018-07-30
      2018-07-08
      2018-07-03
      2018-07-01
      2018-06-15
      2018-06-12-1
      2018-05-01-1
      2018-04-25-1
      2018-04-12
      2018-04-09
      2018-04-05
      2018-04-02
      2018-03-29
      2018-03-27
      2018-03-23
      2018-03-20
      2018-03-17
      2018-03-14
      2018-03-13
      2018-03-07
      2018-03-02
      2018-2-23
      2018-2-5
      2017-11-10-1
      2017-11-10
      2017-10-14
      2017-09-28
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for angle at chromium_7258#2.
  Available versions:
      chromium_5414#1
      chromium_5414
      chromium_4472#8
      chromium_4472#7
      chromium_4472#6
      chromium_4472#5
      chromium_4472#4
      chromium_4472#3
      chromium_4472#2
      chromium_4472#1
      chromium_4472
      2020-05-15#2
      2020-05-15-1
      2020-05-15
      2019-12-31-2
      2019-12-31-1
      2019-12-31
      2019-07-19-4
      2019-07-19-3
      2019-07-19-2
      2019-07-19-1
      2019-06-13
      2019-03-13-c2ee2cc-3
      2019-03-13-c2ee2cc-2
      2019-03-13-c2ee2cc-1
      2019-03-13-c2ee2cc
      2019-01-14-c2ee2cc
      2017-06-14-8d471f-5
      2017-06-14-8d471f-4
      2017-06-14-8d471f-2
      2017-06-14-8d471f-1
      2017-06-14-8d471f
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for asio at 1.32.0.
  Available versions:
      1.24.0#1
      1.24.0
      1.23.0
      1.22.1
      1.20.0
      1.19.2
      1.18.2
      1.18.1#1
      1.18.1
      1.18.0
      1.12.2-2
      1.12.2-1
      1.12.2
      1.12.1-1
      1.12.1
      1.12.0-2
      1.12.0-1
      1.12.0
      1.10.8-1
      1.10.8
      1.10.6
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for bshoshany-thread-pool at 5.0.0.
  Available versions:
      3.3.0
      3.2.0
      3.1.0
      3.0.0
      2.0.0
      1.9
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for cpp-httplib at 0.27.0.
  Available versions:
      0.11.3#1
      0.11.3
      0.11.2
      0.10.7
      0.10.3
      0.9.7
      0.9.4
      0.9.1
      0.8.9
      0.8.6
      0.8.4
      0.7.18
      0.7.15
      0.7.0
      0.5.1
      0.4.2
      0.2.5
      0.2.4
      0.2.2
      0.2.1
      0.2.0
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for discord-rpc at 3.4.0#4.
  Available versions:
      3.4.0#2
      3.4.0#1
      3.4.0
      3.3.0-2
      3.3.0-1
      3.3.0
      3.2.0
      3.1.0
      3.0.0
      2.1.0
      2.0.1
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for fmt at 12.1.0.
  Available versions:
      9.1.0#1
      9.1.0
      9.0.0
      8.1.1#2
      8.1.1#1
      8.1.1
      8.1.0
      8.0.1
      7.1.3#5
      7.1.3#4
      7.1.3#3
      7.1.3#2
      7.1.3#1
      7.1.3
      7.1.2
      7.1.1
      7.1.0
      7.0.3#3
      7.0.3#2
      7.0.3
      7.0.2
      6.2.1
      6.2.0-1
      6.2.0
      6.1.2
      6.0.0-1
      6.0.0
      5.3.0-2
      5.3.0-1
      5.3.0
      5.2.1
      5.2.0
      5.1.0
      5.0.0-1
      5.0.0
      4.1.0
      4.0.0-1
      4.0.0
      3.0.2
      3.0.1-4
      3.0.1-3
      3.0.1-2
      3.0.1-1
      3.0.1
      3.0.0-1
      3.0.0
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for freetype at 2.13.3.
  Available versions:
      2.12.1#3
      2.12.1#2
      2.12.1#1
      2.12.1
      2.11.1#1
      2.11.1
      2.11.0#2
      2.11.0#1
      2.11.0
      2.10.4
      2.10.2#7
      2.10.2#6
      2.10.2#5
      2.10.2#4
      2.10.2#3
      2.10.2#2
      2.10.2#1
      2.10.1-6
      2.10.1-5
      2.10.1-4
      2.10.1-3
      2.10.1-2
      2.10.1-1
      2.10.0-1
      2.10.0
      2.9.1-2
      2.9.1-1
      2.9.1
      2.8.1-4
      2.8.1-3
      2.8.1-1
      2.8-1
      2.8
      2.6.3-5
      2.6.3-4
      2.6.3-3
      2.6.3-2
      2.6.3-1
      2.6.3
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for fribidi at 1.0.16.
  Available versions:
      1.0.12
      1.0.11#3
      1.0.11#2
      1.0.11#1
      1.0.11
      1.0.10#3
      1.0.10#2
      1.0.10#1
      1.0.10
      1.0.9-1
      1.0.9
      2019-02-04-3
      2019-02-04-2
      2019-02-04-1
      58c6cb3
      1.0.5
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for glew at 2.2.0#6.
  Available versions:
      2.2.0
      2.1.0#11
      2.1.0#10
      2.1.0#9
      2.1.0-8
      2.1.0-7
      2.1.0-6
      2.1.0-5
      2.1.0-4
      2.1.0-3
      2.1.0-2
      2.1.0-1
      2.1.0
      2.0.0-2
      2.0.0-1
      2.0.0
      1.13.0
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for harfbuzz at 12.2.0.
  Available versions:
      7.0.0
      6.0.0#1
      6.0.0
      5.3.1#1
      5.3.1
      5.0.1#3
      5.0.1#2
      5.0.1#1
      5.0.1
      4.2.0#1
      4.2.0
      3.2.0#3
      3.2.0#2
      3.2.0#1
      3.2.0
      3.0.0#1
      3.0.0
      2.9.0
      2.8.2
      2.8.1#1
      2.8.1
      2.7.4#2
      2.7.4#1
      2.7.4
      2.7.2#1
      2.7.2
      2.6.6#1
      2.6.6
      2.5.3-1
      2.5.3
      2.5.1-1
      2.5.1
      2.4.0
      2.3.1-3
      2.3.1-2
      2.3.1
      1.8.4-4
      1.8.4-3
      1.8.4-2
      1.8.4-1
      1.8.4
      1.8.2-3
      1.8.2-2
      1.8.2
      1.8.1
      1.8.0
      1.7.6-1
      1.7.6
      1.7.5
      1.7.4
      1.6.3-1
      1.7.1
      1.6.3-1
      1.6.3
      1.4.6-2
      1.4.6-1
      1.4.6
      1.3.4-2
      1.3.4-1
      1.3.4
      1.3.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for liblzma at 5.8.1.
  Available versions:
      5.4.1#1
      5.4.1
      5.4.0
      5.2.5#6
      5.2.5#5
      5.2.5#4
      5.2.5#3
      5.2.5#2
      5.2.5#1
      5.2.5
      5.2.4-5
      5.2.4-4
      5.2.4-3
      5.2.4-2
      5.2.4-1
      5.2.4
      5.2.3-2
      5.2.3-1
      5.2.3
      5.2.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for libogg at 1.3.6#1.
  Available versions:
      1.3.5#1
      1.3.5
      1.3.4#3
      1.3.4#2
      1.3.4
      1.3.3-4
      1.3.3-3
      1.3.3-2
      1.3.3-1
      1.3.3
      1.3.2-cab46b1-3
      1.3.2-cab46b1-2
      2017-07-27-cab46b19847
      1.3.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for libvorbis at 1.3.7#4.
  Available versions:
      1.3.7#2
      1.3.7#1
      1.3.7
      1.3.6-4d963fe#2
      1.3.6-4d963fe
      1.3.6-9eadecc-3
      1.3.6-9eadecc-1
      1.3.6-112d3bd-1
      1.3.6-112d3bd
      1.3.5-143caf4-3
      1.3.5-143caf4-2
      1.3.5-1-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee
      1.3.5-143caf4023a90c09a5eb685fdd46fb9b9c36b1ee
      
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for luajit at 2023-01-04#7.
  Available versions:
      2023-01-04
      2022-11-22
      2022-08-11#2
      2022-08-11#1
      2022-08-11
      2.0.5#8
      2.0.5#7
      2.0.5#6
      2.0.5#5
      2.0.5#4
      2.0.5-3
      2.0.5-2
      2.0.5-1
      2.0.5
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for nlohmann-json at 3.12.0#1.
  Available versions:
      3.11.2
      3.10.5#3
      3.10.5#2
      3.10.5#1
      3.10.5
      3.10.4
      3.10.2
      3.9.1
      3.9.0
      3.8.0#2
      3.8.0
      3.7.3
      3.7.0
      3.6.1
      3.6.0
      3.5.0-5
      3.5.0
      3.4.0
      3.3.0
      3.2.0
      3.1.2
      3.1.0
      3.0.1
      3.0.0
      2.1.1-1
      2.1.1
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for openal-soft at 1.24.3#1.
  Available versions:
      1.23.0
      1.22.2#5
      1.22.2#4
      1.22.2#3
      1.22.2#2
      1.22.2#1
      1.22.2
      1.22.0
      1.21.1#5
      1.21.1#4
      1.21.1#3
      1.21.1#2
      1.21.1#1
      1.21.1
      1.20.1#6
      1.20.1#5
      1.20.1#4
      1.20.1-2
      1.20.1-1
      1.20.1
      1.20.0
      1.19.1-2
      1.19.1-1
      1.19.1
      1.19.0
      1.18.2-2
      1.18.2-1
      1.18.1-1
      1.18.1
      1.18.0
      1.17.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for opengl-registry at 2024-02-10#1.
  Available versions:
      2022-09-29#1
      2022-09-29
      2021-11-17
      2020-03-25#1
      2020-03-25
      2020-02-03
      2019-08-22
      2018-06-30-1
      2018-06-30
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for openssl at 3.6.0#3.
  Available versions:
      3.1.0#1
      3.1.0
      3.0.8#2
      3.0.8#1
      3.0.8
      3.0.7#2
      3.0.7#1
      3.0.7
      3.0.5#5
      3.0.5#4
      3.0.5#3
      3.0.5#2
      3.0.5#1
      3.0.5
      3.0.4
      3.0.3#2
      3.0.3#1
      3.0.3
      3.0.2#3
      3.0.2#2
      3.0.2#1
      3.0.2
      1.1.1n#1
      1.1.1n
      1.1.1m#2
      1.1.1m#1
      1.1.1m
      1.1.1l#4
      1.1.1l#3
      1.1.1l#2
      1.1.1l#1
      1.1.1l
      1.1.1k#8
      1.1.1k#7
      1.1.1k#6
      1.1.1k#5
      1.1.1k#4
      1.1.1k#3
      1.1.1k#2
      1.1.1k#1
      1.1.1k
      1.1.1j#2
      1.1.1j#1
      1.1.1j
      1.1.1i
      1.1.1h#5
      1.1.1h#4
      1.1.1h#3
      1.1.1h#2
      1.1.1h#1
      1.1.1g#1
      1.1.1g
      1.1.1d
      1
      0
      1.0.2o-3
      1.0.2o-2
      1.0.2o-1
      1.0.2o
      1.0.2n-3
      1.0.2n-2
      1.0.2n-1
      1.0.2n
      1.0.2m
      1.0.2l-3
      1.0.2l-2
      1.0.2l-1
      1.0.21-1
      1.0.2k-5
      1.0.2k-4
      1.0.2k-3
      1.0.2k-2
      1.0.2k-1
      1.0.2j-2
      1.0.2j-1
      1.0.2j
      1.0.2h-1
      1.0.2j
      1.0.2h-1
      1.0.2h
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for parallel-hashmap at 2.0.0.
  Available versions:
      1.3.8
      1.36
      1.34
      1.33#1
      1.33
      1.32
      1.30
      1.27
      1.24
      1.23
      1.22
      1.1.0
      1.0.0
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for pkgconf at 2.5.1#4.
  Available versions:
      1.8.0#5
      1.8.0#4
      1.8.0#3
      1.8.0#2
      1.8.0#1
      1.8.0
      1.7.4
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for protobuf at 5.29.5#3.
  Available versions:
      3.21.12
      3.21.8
      3.21.6#1
      3.21.6
      3.21.4
      3.21.3
      3.21.2#1
      3.21.2
      3.19.4
      3.18.0#1
      3.18.0
      3.15.8#4
      3.15.8#3
      3.15.8#2
      3.15.8#1
      3.15.8
      3.14.0#4
      3.14.0#3
      3.14.0#2
      3.14.0#1
      3.14.0
      3.13.0#2
      3.13.0#1
      3.13.0
      3.12.3#2
      3.12.3#1
      3.12.3
      3.12.0-2
      3.12.0-1
      3.12.0
      3.11.4-1
      3.11.4
      3.11.3
      3.11.2
      3.11.0
      3.10.0
      3.9.1
      3.9.0
      3.8.0-1
      3.8.0
      3.7.1
      3.6.1.3-1
      3.6.1.3
      3.6.1-4
      3.6.1-2
      3.6.1-1
      3.6.0.1
      3.5.1-5
      3.5.1-4
      3.5.1-3
      3.5.1-2
      3.5.1-1
      3.5.1
      3.5.0-1
      3.5.0
      3.4.1-2
      3.4.1-1
      3.4.0-2
      3.4.0-1
      3.4.0
      3.3.0-3
      3.3.0-2
      3.3.0-1
      3.3.0
      3.2.0
      3.0.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for pugixml at 1.15#1.
  Available versions:
      1.13.0
      1.12.1#1
      1.12.1
      1.11.4#1
      1.11.4
      1.11.1
      1.10#2
      1.10-1
      1.10
      1.9-3
      1.9-2
      1.9-1
      1.8.1-3
      1.8.1-2
      1.8.1-1
      1.8.1
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for stduuid at 1.2.3.
  Available versions:
      1.2.2
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for vcpkg-cmake at 2024-04-23.
  Available versions:
      2022-12-22
      2022-11-13
      2022-10-30
      2022-09-26
      2022-09-13
      2022-08-18
      2022-07-18
      2022-07-02
      2022-06-07
      2022-05-10#1
      2022-05-10
      2022-05-06
      2022-05-05
      2022-04-21
      2022-04-12
      2022-04-07
      2022-04-05
      2022-02-14
      2022-01-19
      2021-12-20
      2021-12-05
      2021-09-13
      2021-07-30
      2021-07-26
      2021-06-25#5
      2021-06-25#4
      2021-02-28#3
      2021-02-28#2
      2021-02-28#1
      2021-02-28
      2021-02-26
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for vcpkg-cmake-config at 2024-05-23.
  Available versions:
      2022-02-06#1
      2022-02-06
      2022-01-30
      2021-12-28
      2021-12-01
      2021-11-01
      2021-09-27
      2021-05-22#1
      2021-08-11
      2021-05-22
      2021-02-26#1
      2021-02-26
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  error: no version database entry for zlib at 1.3.1.
  Available versions:
      1.2.13
      1.2.12#2
      1.2.12#1
      1.2.12
      1.2.11#13
      1.2.11#12
      1.2.11#11
      1.2.11#10
      1.2.11#9
      1.2.11#8
      1.2.11#7
      1.2.11-6
      1.2.11-5
      1.2.11-3
      1.2.11-2
      1.2.11-1
      1.2.11
      1.2.10
      1.2.8
  See `vcpkg help versioning` for more information.
  note: updating vcpkg by rerunning bootstrap-vcpkg may resolve this failure.
  libobfuscate does not exist
  Error: Last command execution failed with error code '1'.
⏱ elapsed: 1.385 seconds
Error: Last command execution failed with error code '1'.
    at BaseUtilLib.throwIfErrorCode (D:\a\_actions\lukka\run-vcpkg\v11\dist\index.js:44357:19)
    at VcpkgRunner.<anonymous> (D:\a\_actions\lukka\run-vcpkg\v11\dist\index.js:46522:28)
    at Generator.next (<anonymous>)
    at fulfilled (D:\a\_actions\lukka\run-vcpkg\v11\dist\index.js:46272:58)
    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)
Error: run-vcpkg action execution failed: Last command execution failed with error code '1'.


Annotations
2 errors and 2 warnings
build
run-vcpkg action execution failed: Last command execution failed with error code '1'.
build
Last command execution failed with error code '1'.
build
No files were found with the provided path: build/CMakeFiles/CMakeOutput.log build/CMakeFiles/CMakeError.log. No artifacts will be uploaded.
build
Failed to restore: Cache service responded with 400



