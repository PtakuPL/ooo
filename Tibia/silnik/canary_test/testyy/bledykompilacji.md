-- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/abseil_x64-linux/share/abseil/copyright
  -- Performing post-build validation
  Uploaded 0 package(s) to GHA in 1.4 s
  Elapsed time to handle abseil:x64-linux: 1.3 min
  Installing 4/35 asio:x64-linux...
  Building asio[core]:x64-linux...
  -- Installing port from location: /home/runner/work/ooo/ooo/vcpkg/buildtrees/versioning_/versions/asio/b134a3e21a2ef661aa5e3802cefc22386c095aaa
  -- Downloading https://github.com/chriskohlhoff/asio/archive/asio-1-24-0.tar.gz -> chriskohlhoff-asio-asio-1-24-0.tar.gz...
  -- Extracting source /home/runner/work/ooo/ooo/vcpkg/downloads/chriskohlhoff-asio-asio-1-24-0.tar.gz
  -- Using source at /home/runner/work/ooo/ooo/vcpkg/buildtrees/asio/src/sio-1-24-0-90ff3c5d9d.clean
  CMake Warning (dev) at scripts/cmake/vcpkg_find_acquire_program.cmake:70 (cmake_parse_arguments):
    The INTERPRETER keyword was followed by an empty string or no value at all.
    Policy CMP0174 is not set, so cmake_parse_arguments() will unset the
    arg_INTERPRETER variable rather than setting it to an empty string.
  Call Stack (most recent call first):
    scripts/cmake/vcpkg_find_acquire_program.cmake:594 (z_vcpkg_find_acquire_program_find_internal)
    /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/x64-linux/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:104 (vcpkg_find_acquire_program)
    buildtrees/versioning_/versions/asio/b134a3e21a2ef661aa5e3802cefc22386c095aaa/portfile.cmake:16 (vcpkg_cmake_configure)
    scripts/ports.cmake:147 (include)
  This warning is for project developers.  Use -Wno-dev to suppress it.
  CMake Warning (dev) at scripts/cmake/vcpkg_find_acquire_program.cmake:30 (cmake_parse_arguments):
    The INTERPRETER keyword was followed by an empty string or no value at all.
    Policy CMP0174 is not set, so cmake_parse_arguments() will unset the
    arg_INTERPRETER variable rather than setting it to an empty string.
  Call Stack (most recent call first):
    scripts/cmake/vcpkg_find_acquire_program.cmake:600 (z_vcpkg_find_acquire_program_find_external)
    /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/x64-linux/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:104 (vcpkg_find_acquire_program)
    buildtrees/versioning_/versions/asio/b134a3e21a2ef661aa5e3802cefc22386c095aaa/portfile.cmake:16 (vcpkg_cmake_configure)
    scripts/ports.cmake:147 (include)
  This warning is for project developers.  Use -Wno-dev to suppress it.
  -- Found external ninja('1.13.2').
  -- Configuring x64-linux
  -- Building x64-linux-dbg
  -- Building x64-linux-rel
  -- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/asio_x64-linux/share/asio/asio-config.cmake
  -- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/asio_x64-linux/share/asio/copyright
  -- Performing post-build validation
  Uploaded 0 package(s) to GHA in 166 ms
  Elapsed time to handle asio:x64-linux: 1.7 s
  Installing 5/35 bshoshany-thread-pool:x64-linux...
  Building bshoshany-thread-pool[core]:x64-linux...
  -- Installing port from location: /home/runner/work/ooo/ooo/vcpkg/buildtrees/versioning_/versions/bshoshany-thread-pool/dbe9095cfdb6128d117003b2495f84e50653c220
  -- Downloading https://github.com/bshoshany/thread-pool/archive/v3.3.0.tar.gz -> bshoshany-thread-pool-v3.3.0.tar.gz...
  -- Extracting source /home/runner/work/ooo/ooo/vcpkg/downloads/bshoshany-thread-pool-v3.3.0.tar.gz
  -- Using source at /home/runner/work/ooo/ooo/vcpkg/buildtrees/bshoshany-thread-pool/src/v3.3.0-8479d429a4.clean
  -- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/bshoshany-thread-pool_x64-linux/include/BS_thread_pool.hpp
  -- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/bshoshany-thread-pool_x64-linux/include/BS_thread_pool_light.hpp
  -- Installing: /home/runner/work/ooo/ooo/vcpkg/packages/bshoshany-thread-pool_x64-linux/share/bshoshany-thread-pool/copyright
  -- Performing post-build validation
  Uploaded 0 package(s) to GHA in 54.7 ms
  Elapsed time to handle bshoshany-thread-pool:x64-linux: 386 ms
  Installing 6/35 brotli:x64-linux...
  Building brotli[core]:x64-linux...
  -- Installing port from location: /home/runner/work/ooo/ooo/vcpkg/buildtrees/versioning_/versions/brotli/32ea6c4b0d18fa3172ad52147599983acc71d748
  -- Downloading https://github.com/google/brotli/archive/e61745a6b7add50d380cfd7d3883dd6c62fc2c71.tar.gz -> google-brotli-e61745a6b7add50d380cfd7d3883dd6c62fc2c71.tar.gz...
  -- Extracting source /home/runner/work/ooo/ooo/vcpkg/downloads/google-brotli-e61745a6b7add50d380cfd7d3883dd6c62fc2c71.tar.gz
  -- Applying patch install.patch
  -- Applying patch fix-arm-uwp.patch
  -- Applying patch pkgconfig.patch
  -- Using source at /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean
  CMake Warning (dev) at scripts/cmake/vcpkg_find_acquire_program.cmake:70 (cmake_parse_arguments):
    The INTERPRETER keyword was followed by an empty string or no value at all.
    Policy CMP0174 is not set, so cmake_parse_arguments() will unset the
    arg_INTERPRETER variable rather than setting it to an empty string.
  Call Stack (most recent call first):
    scripts/cmake/vcpkg_find_acquire_program.cmake:594 (z_vcpkg_find_acquire_program_find_internal)
    /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/x64-linux/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:104 (vcpkg_find_acquire_program)
    buildtrees/versioning_/versions/brotli/32ea6c4b0d18fa3172ad52147599983acc71d748/portfile.cmake:13 (vcpkg_cmake_configure)
    scripts/ports.cmake:147 (include)
  This warning is for project developers.  Use -Wno-dev to suppress it.
  CMake Warning (dev) at scripts/cmake/vcpkg_find_acquire_program.cmake:30 (cmake_parse_arguments):
    The INTERPRETER keyword was followed by an empty string or no value at all.
    Policy CMP0174 is not set, so cmake_parse_arguments() will unset the
    arg_INTERPRETER variable rather than setting it to an empty string.
  Call Stack (most recent call first):
    scripts/cmake/vcpkg_find_acquire_program.cmake:600 (z_vcpkg_find_acquire_program_find_external)
    /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/x64-linux/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:104 (vcpkg_find_acquire_program)
    buildtrees/versioning_/versions/brotli/32ea6c4b0d18fa3172ad52147599983acc71d748/portfile.cmake:13 (vcpkg_cmake_configure)
    scripts/ports.cmake:147 (include)
  This warning is for project developers.  Use -Wno-dev to suppress it.
  -- Found external ninja('1.13.2').
  -- Configuring x64-linux
  [LogCollection][Start]File:'/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-out.log':
  [1/2] "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" -E chdir "../../x64-linux-dbg" "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" "/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=/home/runner/work/ooo/ooo/vcpkg/packages/brotli_x64-linux/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBROTLI_DISABLE_TESTS=ON" "-DBROTLI_EMSCRIPTEN=OFF" "-DCMAKE_MAKE_PROGRAM=/home/runner/work/_temp/539483011/ninja" "-DCMAKE_SYSTEM_NAME=Linux" "-DBUILD_SHARED_LIBS=OFF" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/home/runner/work/ooo/ooo/vcpkg/scripts/toolchains/linux.cmake" "-DVCPKG_TARGET_TRIPLET=x64-linux" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=external" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCP
  FAILED: [code=1] ../../x64-linux-dbg/CMakeCache.txt 
  "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" -E chdir "../../x64-linux-dbg" "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" "/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Debug" "-DCMAKE_INSTALL_PREFIX=/home/runner/work/ooo/ooo/vcpkg/packages/brotli_x64-linux/debug" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBROTLI_DISABLE_TESTS=ON" "-DBROTLI_EMSCRIPTEN=OFF" "-DCMAKE_MAKE_PROGRAM=/home/runner/work/_temp/539483011/ninja" "-DCMAKE_SYSTEM_NAME=Linux" "-DBUILD_SHARED_LIBS=OFF" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/home/runner/work/ooo/ooo/vcpkg/scripts/toolchains/linux.cmake" "-DVCPKG_TARGET_TRIPLET=x64-linux" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=external" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APP
  CMake Error at CMakeLists.txt:5 (cmake_minimum_required):
  Error:   Compatibility with CMake < 3.5 has been removed from CMake.
    Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
    to tell CMake that the project requires at least <min> but has been updated
    to work with policies introduced by <max> or earlier.
    Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
  -- Configuring incomplete, errors occurred!
  [2/2] "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" -E chdir ".." "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" "/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=/home/runner/work/ooo/ooo/vcpkg/packages/brotli_x64-linux" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBROTLI_DISABLE_TESTS=ON" "-DBROTLI_EMSCRIPTEN=OFF" "-DCMAKE_MAKE_PROGRAM=/home/runner/work/_temp/539483011/ninja" "-DCMAKE_SYSTEM_NAME=Linux" "-DBUILD_SHARED_LIBS=OFF" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/home/runner/work/ooo/ooo/vcpkg/scripts/toolchains/linux.cmake" "-DVCPKG_TARGET_TRIPLET=x64-linux" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=external" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF"
  FAILED: [code=1] ../CMakeCache.txt 
  "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" -E chdir ".." "/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake" "/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean" "-G" "Ninja" "-DCMAKE_BUILD_TYPE=Release" "-DCMAKE_INSTALL_PREFIX=/home/runner/work/ooo/ooo/vcpkg/packages/brotli_x64-linux" "-DFETCHCONTENT_FULLY_DISCONNECTED=ON" "-DBROTLI_DISABLE_TESTS=ON" "-DBROTLI_EMSCRIPTEN=OFF" "-DCMAKE_MAKE_PROGRAM=/home/runner/work/_temp/539483011/ninja" "-DCMAKE_SYSTEM_NAME=Linux" "-DBUILD_SHARED_LIBS=OFF" "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=/home/runner/work/ooo/ooo/vcpkg/scripts/toolchains/linux.cmake" "-DVCPKG_TARGET_TRIPLET=x64-linux" "-DVCPKG_SET_CHARSET_FLAG=ON" "-DVCPKG_PLATFORM_TOOLSET=external" "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON" "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON" "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE" "-DCMAKE_VERBOSE_MAKEFILE=ON" "-DVCPKG_APPLOCAL_DEPS=OFF" "-DCM
  CMake Error at CMakeLists.txt:5 (cmake_minimum_required):
  Error:   Compatibility with CMake < 3.5 has been removed from CMake.
    Update the VERSION argument <min> value.  Or, use the <min>...<max> syntax
    to tell CMake that the project requires at least <min> but has been updated
    to work with policies introduced by <max> or earlier.
    Or, add -DCMAKE_POLICY_VERSION_MINIMUM=3.5 to try configuring anyway.
  -- Configuring incomplete, errors occurred!
  ninja: build stopped: subcommand failed.
  [LogCollection][End]File:'/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-out.log'.
  [LogCollection][Start]File:'/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-dbg-CMakeCache.txt.log':
  # This is the CMakeCache file.
  # For build in directory: /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/x64-linux-dbg
  # It was generated by CMake: /home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake
  # You can edit this file to change values found and used by cmake.
  # If you do not want to change any of the values, simply exit the editor.
  # If you do want to change a value, simply edit, save, and exit the editor.
  # The syntax for the file is as follows:
  # KEY:TYPE=VALUE
  # KEY is the name of a variable in the cache.
  # TYPE is a hint to GUIs for the type of VALUE, DO NOT EDIT TYPE!.
  # VALUE is the current value for the KEY.
  ########################
  # EXTERNAL cache entries
  ########################
  //No help, variable specified on the command line.
  BROTLI_DISABLE_TESTS:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  BROTLI_EMSCRIPTEN:UNINITIALIZED=OFF
  //No help, variable specified on the command line.
  BUILD_SHARED_LIBS:UNINITIALIZED=OFF
  //No help, variable specified on the command line.
  CMAKE_BUILD_TYPE:UNINITIALIZED=Debug
  //No help, variable specified on the command line.
  CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  CMAKE_EXPORT_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  CMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  CMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY:UNINITIALIZED=ON
  //Value Computed by CMake.
  CMAKE_FIND_PACKAGE_REDIRECTS_DIR:STATIC=/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/x64-linux-dbg/CMakeFiles/pkgRedirects
  //No help, variable specified on the command line.
  CMAKE_INSTALL_BINDIR:STRING=bin
  //No help, variable specified on the command line.
  CMAKE_INSTALL_LIBDIR:STRING=lib
  //No help, variable specified on the command line.
  CMAKE_INSTALL_PREFIX:UNINITIALIZED=/home/runner/work/ooo/ooo/vcpkg/packages/brotli_x64-linux/debug
  //No help, variable specified on the command line.
  CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP:UNINITIALIZED=TRUE
  //No help, variable specified on the command line.
  CMAKE_MAKE_PROGRAM:UNINITIALIZED=/home/runner/work/_temp/539483011/ninja
  //No help, variable specified on the command line.
  CMAKE_SYSTEM_NAME:UNINITIALIZED=Linux
  //No help, variable specified on the command line.
  CMAKE_TOOLCHAIN_FILE:UNINITIALIZED=/home/runner/work/ooo/ooo/vcpkg/scripts/buildsystems/vcpkg.cmake
  //No help, variable specified on the command line.
  CMAKE_VERBOSE_MAKEFILE:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  FETCHCONTENT_FULLY_DISCONNECTED:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  VCPKG_APPLOCAL_DEPS:UNINITIALIZED=OFF
  //No help, variable specified on the command line.
  VCPKG_CHAINLOAD_TOOLCHAIN_FILE:UNINITIALIZED=/home/runner/work/ooo/ooo/vcpkg/scripts/toolchains/linux.cmake
  //No help, variable specified on the command line.
  VCPKG_CRT_LINKAGE:UNINITIALIZED=dynamic
  //No help, variable specified on the command line.
  VCPKG_CXX_FLAGS:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_CXX_FLAGS_DEBUG:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_CXX_FLAGS_RELEASE:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_C_FLAGS:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_C_FLAGS_DEBUG:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_C_FLAGS_RELEASE:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_LINKER_FLAGS:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_LINKER_FLAGS_DEBUG:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_LINKER_FLAGS_RELEASE:UNINITIALIZED=
  //No help, variable specified on the command line.
  VCPKG_MANIFEST_INSTALL:UNINITIALIZED=OFF
  //No help, variable specified on the command line.
  VCPKG_PLATFORM_TOOLSET:UNINITIALIZED=external
  //No help, variable specified on the command line.
  VCPKG_SET_CHARSET_FLAG:UNINITIALIZED=ON
  //No help, variable specified on the command line.
  VCPKG_TARGET_ARCHITECTURE:UNINITIALIZED=x64
  //No help, variable specified on the command line.
  VCPKG_TARGET_TRIPLET:UNINITIALIZED=x64-linux
  //No help, variable specified on the command line.
  _VCPKG_INSTALLED_DIR:UNINITIALIZED=/home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed
  //No help, variable specified on the command line.
  _VCPKG_ROOT_DIR:UNINITIALIZED=/home/runner/work/ooo/ooo/vcpkg
  ########################
  # INTERNAL cache entries
  ########################
  //This is the directory where this CMakeCache.txt was created
  CMAKE_CACHEFILE_DIR:INTERNAL=/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/x64-linux-dbg
  //Major version of cmake used to create the current loaded cache
  CMAKE_CACHE_MAJOR_VERSION:INTERNAL=4
  //Minor version of cmake used to create the current loaded cache
  CMAKE_CACHE_MINOR_VERSION:INTERNAL=2
  //Patch version of cmake used to create the current loaded cache
  CMAKE_CACHE_PATCH_VERSION:INTERNAL=0
  //Path to CMake executable.
  CMAKE_COMMAND:INTERNAL=/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake
  //Path to cpack program executable.
  CMAKE_CPACK_COMMAND:INTERNAL=/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cpack
  //Path to ctest program executable.
  CMAKE_CTEST_COMMAND:INTERNAL=/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/ctest
  //Path to cache edit program executable.
  CMAKE_EDIT_COMMAND:INTERNAL=/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/bin/cmake-gui
  //Name of external makefile project generator.
  CMAKE_EXTRA_GENERATOR:INTERNAL=
  //Name of generator.
  CMAKE_GENERATOR:INTERNAL=Ninja
  //Generator instance identifier.
  CMAKE_GENERATOR_INSTANCE:INTERNAL=
  //Name of generator platform.
  CMAKE_GENERATOR_PLATFORM:INTERNAL=
  //Name of generator toolset.
  CMAKE_GENERATOR_TOOLSET:INTERNAL=
  //Source directory with the top level CMakeLists.txt file for this
  // project
  CMAKE_HOME_DIRECTORY:INTERNAL=/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/src/6c62fc2c71-3fc02d8e7f.clean
  //Name of CMakeLists files to read
  CMAKE_LIST_FILE_NAME:INTERNAL=CMakeLists.txt
  //number of local generators
  CMAKE_NUMBER_OF_MAKEFILES:INTERNAL=1
  //Path to CMake installation.
  CMAKE_ROOT:INTERNAL=/home/runner/work/_temp/539483011/cmake-4.2.0-linux-x86_64/share/cmake-4.2
  [LogCollection][End]File:'/home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-dbg-CMakeCache.txt.log'.
  CMake Error at scripts/cmake/vcpkg_execute_required_process.cmake:112 (message):
  Error:     Command failed: /home/runner/work/_temp/539483011/ninja -v
      Working Directory: /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/x64-linux-rel/vcpkg-parallel-configure
      Error code: 1
      See logs for more information:
        /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-dbg-CMakeCache.txt.log
        /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-rel-CMakeCache.txt.log
        /home/runner/work/ooo/ooo/vcpkg/buildtrees/brotli/config-x64-linux-out.log
  Call Stack (most recent call first):
    /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/x64-linux/share/vcpkg-cmake/vcpkg_cmake_configure.cmake:248 (vcpkg_execute_required_process)
    buildtrees/versioning_/versions/brotli/32ea6c4b0d18fa3172ad52147599983acc71d748/portfile.cmake:13 (vcpkg_cmake_configure)
    scripts/ports.cmake:147 (include)
  error: building brotli:x64-linux failed with: BUILD_FAILED
  Please ensure you're using the latest port files with `git pull` and `vcpkg update`.
  Then check for known issues at:
      https://github.com/microsoft/vcpkg/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+brotli
  You can submit a new issue at:
      https://github.com/microsoft/vcpkg/issues/new?title=[brotli]+Build+error&body=Copy+issue+body+from+%2Fhome%2Frunner%2Fwork%2Fooo%2Fooo%2F969f6665-88a2-4c98-938e-ca9259871fec%2Fvcpkg_installed%2Fvcpkg%2Fissue_body.md
  You can also sumbit an issue by running (GitHub cli must be installed):
      gh issue create -R microsoft/vcpkg --title "[brotli] Build failue" --body-file /home/runner/work/ooo/ooo/969f6665-88a2-4c98-938e-ca9259871fec/vcpkg_installed/vcpkg/issue_body.md
  Error: Last command execution failed with error code '1'.
⏱ elapsed: 82.383 seconds
Error: Last command execution failed with error code '1'.
    at BaseUtilLib.throwIfErrorCode (/home/runner/work/_actions/lukka/run-vcpkg/v11/dist/index.js:44357:19)
    at VcpkgRunner.<anonymous> (/home/runner/work/_actions/lukka/run-vcpkg/v11/dist/index.js:46522:28)
    at Generator.next (<anonymous>)
    at fulfilled (/home/runner/work/_actions/lukka/run-vcpkg/v11/dist/index.js:46272:58)
Error: run-vcpkg action execution failed: Last command execution failed with error code '1'.
0s
