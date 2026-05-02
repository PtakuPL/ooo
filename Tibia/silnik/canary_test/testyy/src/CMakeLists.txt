
project(otclient)

# *****************************************************************************
# Options
# *****************************************************************************
if(CMAKE_BASE_NAME STREQUAL "em++")
  set(WASM ON)
  message(STATUS "WASM: ON")
endif()

option(TOGGLE_FRAMEWORK_GRAPHICS "Use Graphics " ON)
option(TOGGLE_FRAMEWORK_SOUND "Use SOUND " ON)
option(TOGGLE_FRAMEWORK_XML "Use XML " ON)
option(TOGGLE_FRAMEWORK_NET "Use NET " ON)
option(TOGGLE_FRAMEWORK_EDITOR "Use Editor " OFF)
option(TOGGLE_DIRECTX "Use DX9 support" OFF)
option(TOGGLE_BIN_FOLDER "Use build/bin folder for generate compilation files" OFF)
option(DEBUG_LOG "Enable Debug Log" OFF)
option(ASAN_ENABLED "Build this target with AddressSanitizer" OFF)
option(BUILD_STATIC_LIBRARY "Build using static libraries" OFF)
option(TOGGLE_PRE_COMPILED_HEADER "Use precompiled header (speed up compile)" ON)
option(SPEED_UP_BUILD_UNITY "Compile using build unity for speed up build" ON)
option(OTC_ENABLE_PHYSFS "Enable PhysFS (file system abstraction)" ON)
option(OTC_ENABLE_LZMA "Enable LibLZMA (xz) support" ON)
option(OTC_ENABLE_NLOHMANN_JSON "Enable nlohmann/json (JSON support)" ON)
option(OTC_ENABLE_PUGIXML "Enable pugixml (XML support)" ON)
option(OTC_ENABLE_FMT "Enable fmt (formatting library)" ON)
option(OTC_ENABLE_HTTPLIB "Enable cpp-httplib (HTTP server/client)" ON)
option(OTC_ENABLE_GMP "Enable GMP (multiprecision library)" ON)
option(OTC_ENABLE_OPENSSL "Enable OpenSSL (cryptographic library)" ON)
option(OTC_ENABLE_ABSEIL "Enable Abseil (Google C++ library)" ON)
option(OTCLIENT_PLAYER_BUILD "Build sealed player runtime; ignores OTC_DEV_MODE" OFF)

# *****************************************************************************
# Cmake Features
# *****************************************************************************
set(GNUCXX_MINIMUM_VERSION 9)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)


# Make will print more details
set(CMAKE_VERBOSE_MAKEFILE OFF)

# Generate compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# *****************************************************************************
# Client
# *****************************************************************************
if (MSVC)
  add_executable(${PROJECT_NAME} "" ../cmake/icon/otcicon.rc)
elseif(ANDROID)
  add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})
else()
  add_executable(${PROJECT_NAME} "")
endif()

# *****************************************************************************
# Options Code
# *****************************************************************************

# Define Framework options for use in compilation
set(FRAMEWORK_DEFINITIONS "")
if (TOGGLE_FRAMEWORK_GRAPHICS)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DFRAMEWORK_GRAPHICS)
endif()
if (TOGGLE_FRAMEWORK_SOUND)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DFRAMEWORK_SOUND)
endif()
if (TOGGLE_FRAMEWORK_XML)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DFRAMEWORK_XML)
endif()
if (TOGGLE_FRAMEWORK_NET)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DFRAMEWORK_NET)
endif()

if (TOGGLE_FRAMEWORK_EDITOR)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DFRAMEWORK_EDITOR)
endif()
if (ANDROID OR WASM)
  set(FRAMEWORK_DEFINITIONS ${FRAMEWORK_DEFINITIONS} -DOPENGL_ES=2)
endif()

# Set for use precompiled header
if(TOGGLE_PRE_COMPILED_HEADER)
  # === PRECOMPILED HEADER ===
  target_precompile_headers(${PROJECT_NAME} PRIVATE framework/pch.h)
  message(STATUS "Use precompiled header: ON")
else()
  message(STATUS "Use precompiled header: OFF")
endif(TOGGLE_PRE_COMPILED_HEADER)

# === UNITY BUILD (compile time reducer) ===
if(SPEED_UP_BUILD_UNITY)
  if(MSVC)
    set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD OFF)
    log_option_disabled("Build unity for speed up compilation (disabled on MSVC)")
  else()
    set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD ON)
    log_option_enabled("Build unity for speed up compilation")
  endif()
else()
  set_target_properties(${PROJECT_NAME} PROPERTIES UNITY_BUILD OFF)
  log_option_disabled("Build unity for speed up compilation")
endif()

set(VERSION "1.0.0")

# *****************************************************************************
# Build flags
# *****************************************************************************
if (NOT MSVC)
  if (CMAKE_COMPILER_IS_GNUCXX)
    target_compile_options(${PROJECT_NAME}  PRIVATE  -Wno-deprecated-declarations)
  endif()
endif()

if (MSVC)
  # Ensure MSVC treats source files as UTF-8 and can emit larger object files without ICEs
  target_compile_options(${PROJECT_NAME} PUBLIC /utf-8 /bigobj)
  # Prevent Windows.h from defining min/max macros that conflict with std::min/std::max
  target_compile_definitions(${PROJECT_NAME} PRIVATE NOMINMAX)

  # The following workarounds apply ONLY to Microsoft's cl.exe compiler.
  # Clang-CL also sets MSVC=TRUE but doesn't need (and rejects) these flags.
  if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # ── ICE C1001 prevention strategy ──────────────────────────────────────
    # MSVC P2 codegen (p2\main.cpp:258) crashes on template-heavy TUs.
    # #pragma optimize("",off) does NOT help — the crash is in P2 codegen,
    # not in the optimizer.  Strategy:
    #   1. /O1 globally (less aggressive than /O2)
    #   2. /d2SSAOptimizer- per-file (disables SSA optimizer in P2 backend)
    #   3. /Ob0 per-file (disables inlining which triggers P2 template crash)
    #   4. PCH stays enabled (reducing header re-parse reduces ICE surface)
    string(REPLACE "/O2" "/O1" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
    string(REPLACE "/O2" "/O1" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}" CACHE STRING "" FORCE)
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}" CACHE STRING "" FORCE)

    # Per-file ICE suppression for the two TUs that consistently crash.
    # NOTE: COMPILE_OPTIONS on set_source_files_properties does NOT work with
    # Ninja generator. Use COMPILE_FLAGS (space-separated, older CMake property
    # that works reliably with all generators) instead.
    #
    # CRITICAL: SKIP_PRECOMPILE_HEADERS must be ON for these files!
    # Without it, MSVC warns C4653 (optimization inconsistent with PCH)
    # and IGNORES our /Od flag, so the ICE still occurs.
    # With SKIP_PRECOMPILE_HEADERS ON, the files compile without the .pch
    # and our /Od /Ob0 /d2SSAOptimizer- flags actually take effect.
    # The files still get all headers via their own #include chain:
    #   declarations.h -> global.h -> pch.h
    set_source_files_properties(
      framework/otml/otmlnode.cpp
      framework/otml/otmlparser.cpp
      PROPERTIES
        COMPILE_FLAGS "/Od /Ob0 /d2SSAOptimizer-"
        SKIP_PRECOMPILE_HEADERS ON
        COMPILE_DEFINITIONS "OTML_NO_FMT"
    )

    # Disable LTCG/GL — they amplify ICE surface across TUs
    set_target_properties(${PROJECT_NAME} PROPERTIES
      INTERPROCEDURAL_OPTIMIZATION FALSE
      INTERPROCEDURAL_OPTIMIZATION_RELEASE FALSE
      INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO FALSE
    )
    target_link_options(${PROJECT_NAME} PRIVATE /LTCG:OFF)
    target_compile_options(${PROJECT_NAME} PRIVATE /GL-)
  endif() # CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"
endif()

if(THREADS_HAVE_PTHREAD_ARG)
  target_compile_options(${PROJECT_NAME} PUBLIC "-pthread")
endif()

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  add_definitions(-DNDEBUG)
endif()

# *****************************************************************************
# Definitions code
# *****************************************************************************


# === ASAN ===
if(ASAN_ENABLED)
  log_option_enabled("asan")

  if(MSVC)
    string(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    target_compile_options(${PROJECT_NAME} PUBLIC /fsanitize=address)
    target_link_options(${PROJECT_NAME} PUBLIC /fsanitize=address)
  else()
    target_compile_options(${PROJECT_NAME} PUBLIC -fsanitize=address)
    target_link_options(${PROJECT_NAME} PUBLIC -fsanitize=address)
  endif()
else()
  log_option_disabled("asan")
endif()


# === DEBUG LOG ===
# cmake -DDEBUG_LOG=ON ..
if(CMAKE_BUILD_TYPE MATCHES Debug)
  target_compile_definitions(${PROJECT_NAME} PRIVATE -DDEBUG_LOG=ON )
  log_option_enabled("DEBUG LOG")
else()
  log_option_disabled("DEBUG LOG")
endif(CMAKE_BUILD_TYPE MATCHES Debug)

# *****************************************************************************
# Sanity Check
# *****************************************************************************

# === GCC Minimum Version ===
if (CMAKE_COMPILER_IS_GNUCXX)
  if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS GNUCXX_MINIMUM_VERSION)
    message(FATAL_ERROR "GCC version must be at least ${GNUCXX_MINIMUM_VERSION}!")
  endif()
endif()


# Multiprocessor compiller
if(CMake_MSVC_PARALLEL)
  if(CMake_MSVC_PARALLEL GREATER 0)
    add_definitions(/MP${CMake_MSVC_PARALLEL})
  else()
    add_definitions(/MP)
  endif()
endif()


# Client options
add_definitions(-DCLIENT)
add_definitions(${FRAMEWORK_DEFINITIONS})
target_compile_definitions(${PROJECT_NAME} PRIVATE "VERSION=${VERSION}")

if(OTCLIENT_PLAYER_BUILD)
  target_compile_definitions(${PROJECT_NAME} PRIVATE OTCLIENT_PLAYER_BUILD=1)
  log_option_enabled("sealed player runtime")
else()
  log_option_disabled("sealed player runtime")
endif()

# === Build options ===
# Use target_compile_definitions instead of add_definitions for string defines.
# The old add_definitions(-D"BUILD_TYPE=\\\"...\\\") escaping produces a bare $
# in the Ninja build file with CMake 3.22.1 (Android SDK), causing:
#   ninja: error: build.ninja:NNN: bad $-escape
message(STATUS "Build type: " ${CMAKE_BUILD_TYPE})
message(STATUS "Build commit: ${BUILD_COMMIT}")
message(STATUS "Build revision: ${BUILD_REVISION}")
target_compile_definitions(${PROJECT_NAME} PRIVATE
    "BUILD_TYPE=\"${CMAKE_BUILD_TYPE}\""
    "BUILD_COMMIT=\"${BUILD_COMMIT}\""
    "BUILD_REVISION=\"${BUILD_REVISION}\""
)
# *****************************************************************************
# Packages / Libs
# *****************************************************************************
include(FetchContent)

  find_package(OpenSSL QUIET)
  if(OTC_ENABLE_PHYSFS)
    find_package(PhysFS CONFIG QUIET)
    if(TARGET PhysFS::PhysFS)
      get_target_property(PHYSFS_INCLUDE_DIR PhysFS::PhysFS INTERFACE_INCLUDE_DIRECTORIES)
      set(PHYSFS_LIBRARY PhysFS::PhysFS)
    elseif(TARGET PhysFS::PhysFS-static)
      # vcpkg with static triplets provides PhysFS::PhysFS-static
      get_target_property(PHYSFS_INCLUDE_DIR PhysFS::PhysFS-static INTERFACE_INCLUDE_DIRECTORIES)
      set(PHYSFS_LIBRARY PhysFS::PhysFS-static)
    else()
      # Fallback: Try to find PhysFS manually (vcpkg may install without CMake config)
      find_path(PHYSFS_INCLUDE_DIR NAMES physfs.h)
      find_library(PHYSFS_LIBRARY_FOUND NAMES physfs physfs-static)
      if(PHYSFS_INCLUDE_DIR AND PHYSFS_LIBRARY_FOUND)
        set(PHYSFS_LIBRARY ${PHYSFS_LIBRARY_FOUND})
        if(NOT TARGET PhysFS::PhysFS)
          add_library(PhysFS::PhysFS UNKNOWN IMPORTED)
          set_target_properties(PhysFS::PhysFS PROPERTIES
            IMPORTED_LOCATION "${PHYSFS_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${PHYSFS_INCLUDE_DIR}")
        endif()
      else()
        # Last resort: try pkg-config (Linux/macOS)
        find_package(PkgConfig QUIET)
        if(PKG_CONFIG_FOUND)
          pkg_check_modules(PHYSFS physfs)
        endif()
        if(PHYSFS_FOUND)
          set(PHYSFS_LIBRARY ${PHYSFS_LINK_LIBRARIES})
          set(PHYSFS_INCLUDE_DIR ${PHYSFS_INCLUDE_DIRS})
          if(NOT TARGET PhysFS::PhysFS)
            add_library(PhysFS::PhysFS INTERFACE IMPORTED)
            target_include_directories(PhysFS::PhysFS INTERFACE ${PHYSFS_INCLUDE_DIRS})
            target_link_libraries(PhysFS::PhysFS INTERFACE ${PHYSFS_LINK_LIBRARIES})
          endif()
        else()
          message(FATAL_ERROR "Could not find PhysFS; install physfs or libphysfs-dev")
        endif()
      endif()
    endif()
  else()
    # Optional: allow disabling PhysFS (e.g., Android static analysis without the dependency)
    if(NOT TARGET PhysFS::PhysFS)
      add_library(PhysFS::PhysFS INTERFACE IMPORTED)
    endif()
    set(PHYSFS_INCLUDE_DIR "")
    set(PHYSFS_LIBRARY PhysFS::PhysFS)
  endif()
  find_package(ZLIB REQUIRED)
  find_package(absl CONFIG QUIET)
  if(OTC_ENABLE_PROTOBUF)
    find_package(Protobuf REQUIRED)
  else()
    # When protobuf is disabled, set empty variables to avoid CMake errors
    set(Protobuf_INCLUDE_DIRS "")
    set(PROTOBUF_LIBRARY "")
  endif()
  if(OTC_ENABLE_LZMA)
    find_package(LibLZMA REQUIRED)
  else()
    # Allow disabling LZMA for trimmed CI builds (e.g., Android static analysis)
    set(LIBLZMA_INCLUDE_DIR "")
    set(LIBLZMA_LIBRARY "")
  endif()
  if(OTC_ENABLE_NLOHMANN_JSON)
    find_package(nlohmann_json CONFIG QUIET)
    if(TARGET nlohmann_json::nlohmann_json)
      get_target_property(NLOHMANN_JSON_INCLUDE_DIR nlohmann_json::nlohmann_json INTERFACE_INCLUDE_DIRECTORIES)
      set(NLOHMANN_JSON_LIBRARY nlohmann_json::nlohmann_json)
    else()
      find_path(NLOHMANN_JSON_INCLUDE_DIR NAMES nlohmann/json.hpp)
      if(NOT NLOHMANN_JSON_INCLUDE_DIR)
        message(FATAL_ERROR "Could not find nlohmann/json.hpp; install nlohmann-json3-dev or provide a CMake package")
      endif()
      add_library(nlohmann_json::nlohmann_json INTERFACE IMPORTED)
      target_include_directories(nlohmann_json::nlohmann_json INTERFACE ${NLOHMANN_JSON_INCLUDE_DIR})
      set(NLOHMANN_JSON_LIBRARY nlohmann_json::nlohmann_json)
    endif()
  else()
    # Allow disabling JSON dependency (e.g., Android static analysis)
    if(NOT TARGET nlohmann_json::nlohmann_json)
      add_library(nlohmann_json::nlohmann_json INTERFACE IMPORTED)
    endif()
    set(NLOHMANN_JSON_INCLUDE_DIR "")
    set(NLOHMANN_JSON_LIBRARY nlohmann_json::nlohmann_json)
  endif()
  find_package(asio CONFIG QUIET)
  if(TARGET asio::asio)
    get_target_property(ASIO_INCLUDE_DIR asio::asio INTERFACE_INCLUDE_DIRECTORIES)
  else()
    find_path(ASIO_INCLUDE_DIR NAMES asio.hpp)
    if(NOT ASIO_INCLUDE_DIR)
      FetchContent_Declare(asio
        GIT_REPOSITORY https://github.com/chriskohlhoff/asio.git
        GIT_TAG asio-1-30-2
      )
      FetchContent_MakeAvailable(asio)
      set(ASIO_INCLUDE_DIR ${asio_SOURCE_DIR}/asio/include)
    endif()
    if(NOT TARGET asio::asio)
      add_library(asio::asio INTERFACE IMPORTED)
      target_include_directories(asio::asio INTERFACE ${ASIO_INCLUDE_DIR})
      target_compile_definitions(asio::asio INTERFACE ASIO_STANDALONE)
    endif()
  endif()
  find_package(Threads REQUIRED)
  if(OTC_ENABLE_PUGIXML)
    find_package(pugixml CONFIG QUIET)
    if(TARGET pugixml::pugixml)
      get_target_property(PUGIXML_INCLUDE_DIR pugixml::pugixml INTERFACE_INCLUDE_DIRECTORIES)
      set(PUGIXML_TARGET pugixml::pugixml)
    elseif(TARGET pugixml::static)
      # vcpkg with static triplets may provide pugixml::static
      get_target_property(PUGIXML_INCLUDE_DIR pugixml::static INTERFACE_INCLUDE_DIRECTORIES)
      set(PUGIXML_TARGET pugixml::static)
    else()
      find_path(PUGIXML_INCLUDE_DIR NAMES pugixml.hpp)
      find_library(PUGIXML_LIBRARY NAMES pugixml)
      if(NOT PUGIXML_INCLUDE_DIR OR NOT PUGIXML_LIBRARY)
        message(FATAL_ERROR "Could not find pugixml; install libpugixml-dev or provide a CMake package")
      endif()
      add_library(pugixml::pugixml INTERFACE IMPORTED)
      target_include_directories(pugixml::pugixml INTERFACE ${PUGIXML_INCLUDE_DIR})
      target_link_libraries(pugixml::pugixml INTERFACE ${PUGIXML_LIBRARY})
      set(PUGIXML_TARGET pugixml::pugixml)
    endif()
  else()
    if(NOT TARGET pugixml::pugixml)
      add_library(pugixml::pugixml INTERFACE IMPORTED)
    endif()
    set(PUGIXML_INCLUDE_DIR "")
    set(PUGIXML_TARGET pugixml::pugixml)
  endif()
  find_package(ZLIB REQUIRED)
  if(OTC_ENABLE_FMT)
    find_package(fmt CONFIG QUIET)
    if(TARGET fmt::fmt)
      set(FMT_TARGET fmt::fmt)
    elseif(TARGET fmt::fmt-header-only)
      set(FMT_TARGET fmt::fmt-header-only)
    else()
      find_path(FMT_INCLUDE_DIR NAMES fmt/format.h)
      if(NOT FMT_INCLUDE_DIR)
        message(FATAL_ERROR "Could not find fmt headers; install libfmt-dev or provide a CMake package")
      endif()
      add_library(fmt::fmt-header-only INTERFACE IMPORTED)
      target_include_directories(fmt::fmt-header-only INTERFACE ${FMT_INCLUDE_DIR})
      add_library(fmt::fmt ALIAS fmt::fmt-header-only)
      set(FMT_TARGET fmt::fmt-header-only)
    endif()
  else()
    if(NOT TARGET fmt::fmt-header-only)
      add_library(fmt::fmt-header-only INTERFACE IMPORTED)
    endif()
    add_library(fmt::fmt ALIAS fmt::fmt-header-only)
    set(FMT_TARGET fmt::fmt-header-only)
  endif()

  set(ABSL_LOG_TARGET fmt::fmt)
  if(TARGET absl::log_internal_check_op)
    set(ABSL_LOG_TARGET absl::log_internal_check_op)
  elseif(TARGET absl::raw_logging_internal)
    set(ABSL_LOG_TARGET absl::raw_logging_internal)
  elseif(TARGET absl::log_severity)
    set(ABSL_LOG_TARGET absl::log_severity)
  elseif(TARGET absl::base)
    set(ABSL_LOG_TARGET absl::base)
  endif()

# Header-only BS_thread_pool (task scheduler)
find_path(BS_THREAD_POOL_INCLUDE_DIR NAMES BS_thread_pool.hpp)
if(NOT BS_THREAD_POOL_INCLUDE_DIR)
  FetchContent_Declare(bs_thread_pool
    GIT_REPOSITORY https://github.com/bshoshany/thread-pool.git
    GIT_TAG v4.1.0
  )
  FetchContent_MakeAvailable(bs_thread_pool)
  set(BS_THREAD_POOL_INCLUDE_DIR ${bs_thread_pool_SOURCE_DIR}/include)
endif()

# phmap (parallel-hashmap) may be available via a CMake config (e.g. vcpkg)
# or only as system headers. Try the imported target first, then fall back to
# discovering the include path manually.
find_package(phmap CONFIG QUIET)
  if(TARGET phmap::phmap)
    get_target_property(PARALLEL_HASHMAP_INCLUDE_DIRS phmap::phmap INTERFACE_INCLUDE_DIRECTORIES)
  elseif(NOT PARALLEL_HASHMAP_INCLUDE_DIRS)
    find_path(PARALLEL_HASHMAP_INCLUDE_DIRS NAMES parallel_hashmap/phmap.h)
    if(NOT PARALLEL_HASHMAP_INCLUDE_DIRS)
      FetchContent_Declare(parallel_hashmap
        GIT_REPOSITORY https://github.com/greg7mdp/parallel-hashmap.git
        GIT_TAG v1.3.11
      )
      FetchContent_MakeAvailable(parallel_hashmap)
      set(PARALLEL_HASHMAP_INCLUDE_DIRS ${parallel_hashmap_SOURCE_DIR})
    endif()
    if(NOT TARGET phmap::phmap)
      add_library(phmap::phmap INTERFACE IMPORTED)
      target_include_directories(phmap::phmap INTERFACE ${PARALLEL_HASHMAP_INCLUDE_DIRS})
    endif()
  endif()

# stduuid is header-only; prefer a config package but allow system headers.
find_package(STDUUID CONFIG QUIET)
if(TARGET stduuid::stduuid)
  set(STDUUID stduuid::stduuid)
  get_target_property(STDUUID_INCLUDE_DIRS stduuid::stduuid INTERFACE_INCLUDE_DIRECTORIES)
elseif(TARGET stduuid)
  set(STDUUID stduuid)
  get_target_property(STDUUID_INCLUDE_DIRS stduuid INTERFACE_INCLUDE_DIRECTORIES)
endif()
if(NOT STDUUID)
  find_path(STDUUID_INCLUDE_DIRS NAMES stduuid/uuid.h)

  if(NOT STDUUID_INCLUDE_DIRS)
    # Fetch a header-only copy when no package is available.
    FetchContent_Declare(stduuid_fetch
      GIT_REPOSITORY https://github.com/mariusbancila/stduuid.git
      GIT_TAG v1.2.3
    )
    FetchContent_MakeAvailable(stduuid_fetch)
    set(STDUUID_INCLUDE_DIRS ${stduuid_fetch_SOURCE_DIR}/include)
  endif()

  add_library(stduuid::stduuid INTERFACE IMPORTED)
  target_include_directories(stduuid::stduuid INTERFACE ${STDUUID_INCLUDE_DIRS})
  set(STDUUID stduuid::stduuid)
endif()

# cpp-httplib (HTTP server/client) with pkg-config fallback
  if(OTC_ENABLE_HTTPLIB)
    find_package(httplib CONFIG QUIET)
    if(TARGET httplib::httplib)
      set(HTTPLIB_LIBRARY httplib::httplib)
    else()
      find_package(PkgConfig QUIET)
      if(PKG_CONFIG_FOUND)
        pkg_check_modules(HTTPLIB cpp-httplib)
      endif()
      if(HTTPLIB_FOUND)
        if(NOT TARGET httplib::httplib)
          add_library(httplib::httplib INTERFACE IMPORTED)
          target_include_directories(httplib::httplib INTERFACE ${HTTPLIB_INCLUDE_DIRS})
          target_compile_definitions(httplib::httplib INTERFACE ${HTTPLIB_CFLAGS_OTHER})
        endif()
        set(HTTPLIB_LIBRARY httplib::httplib)
      else()
        FetchContent_Declare(cpp_httplib
          GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
          GIT_TAG v0.15.3
        )
        FetchContent_MakeAvailable(cpp_httplib)
        if(NOT TARGET httplib::httplib)
          add_library(httplib::httplib INTERFACE IMPORTED)
          target_include_directories(httplib::httplib INTERFACE ${cpp_httplib_SOURCE_DIR})
        endif()
        set(HTTPLIB_LIBRARY httplib::httplib)
      endif()
    endif()
  else()
    if(NOT TARGET httplib::httplib)
      add_library(httplib::httplib INTERFACE IMPORTED)
    endif()
    set(HTTPLIB_LIBRARY httplib::httplib)
  endif()
if(APPLE)
  # Required for Physfs
  find_library(FOUNDATION Foundation REQUIRED)
  find_library(IOKIT IOKit REQUIRED)
endif()
if(UNIX AND NOT ANDROID AND NOT WASM)
  find_package(X11 REQUIRED)
endif()
if(WIN32)
  # DbgHelp is only reliably available with MSVC; make it optional for MinGW/other compilers
  if(MSVC)
    find_package(DbgHelp REQUIRED)
  else()
    find_package(DbgHelp QUIET)
  endif()
endif(WIN32)
if(NOT OPENSSL_FOUND)
  if(OTC_ENABLE_GMP)
    find_package(GMP REQUIRED)
  else()
    if(NOT TARGET GMP::GMP)
      add_library(GMP::GMP INTERFACE IMPORTED)
    endif()
    set(GMP_INCLUDE_DIR "")
    set(GMP_LIBRARY GMP::GMP)
  endif()
endif()
if(TOGGLE_DIRECTX)
  find_package(DirectX REQUIRED)
endif()
if(TOGGLE_FRAMEWORK_SOUND)
  if(NOT WASM)
        find_package(OpenAL CONFIG QUIET)
    if(NOT TARGET OpenAL::OpenAL)
      find_package(OpenAL REQUIRED)
    endif()
  endif()
  find_package(VorbisFile REQUIRED)
  find_package(Vorbis CONFIG QUIET)
  if(NOT TARGET Vorbis::vorbis)
    find_package(Vorbis REQUIRED)
  endif()
  find_package(Ogg CONFIG QUIET)
  if(NOT TARGET Ogg::ogg)
    find_package(Ogg REQUIRED)
  endif()

  if(OGG_FOUND AND NOT TARGET Ogg::ogg)
    add_library(Ogg::ogg UNKNOWN IMPORTED)
    set_target_properties(Ogg::ogg PROPERTIES
      IMPORTED_LOCATION ${OGG_LIBRARY}
      INTERFACE_INCLUDE_DIRECTORIES ${OGG_INCLUDE_DIR})
  endif()

  if(Vorbis_FOUND AND NOT TARGET Vorbis::vorbis)
    add_library(Vorbis::vorbis UNKNOWN IMPORTED)
    set_target_properties(Vorbis::vorbis PROPERTIES
      IMPORTED_LOCATION ${VORBIS_LIBRARY}
      INTERFACE_INCLUDE_DIRECTORIES ${VORBIS_INCLUDE_DIR})
  endif()

  if(VorbisFile_FOUND AND NOT TARGET Vorbis::vorbisfile)
    add_library(Vorbis::vorbisfile UNKNOWN IMPORTED)
    set_target_properties(Vorbis::vorbisfile PROPERTIES
      IMPORTED_LOCATION ${VORBISFILE_LIBRARY}
      INTERFACE_INCLUDE_DIRECTORIES ${VORBISFILE_INCLUDE_DIR})
  endif()
endif()
if(ANDROID)
  set(LUA_LIBRARY ${LUA_LIBRARY} ${Android_LIBRARIES}/liblua.a)
  set(LUAJIT_INCLUDE_DIR ${LUAJIT_LIBRARY} ${Android_INCLUDES}/luajit)
  set(LUAJIT_LIBRARY ${LUAJIT_LIBRARY} ${Android_LIBRARIES}/libluajit.a)
  set(OpenAL_LIBRARY ${OpenAL_LIBRARY} ${Android_LIBRARIES}/libopenal.a)
  set(MINIZIP_INCLUDE_DIR ${MINIZIP_INCLUDE_DIR} ${Android_INCLUDES}/minizip)
  set(MINIZIP_LIBRARY ${MINIZIP_LIBRARY} ${Android_LIBRARIES}/libminizip.a)
  # Skip game-activity when only generating compile_commands.json for analysis
  if(NOT OTC_SKIP_GAME_ACTIVITY)
    find_package(game-activity REQUIRED CONFIG)
  endif()
  find_package(EGL REQUIRED)
else()
  if(NOT WASM)
    find_package(OpenGL REQUIRED)
    find_package(GLEW REQUIRED)
    find_package(LuaJIT REQUIRED)
  else()
    # For WASM builds, use our updated FindLua.cmake which now supports Lua 5.4 for WASM
    find_package(Lua REQUIRED)
    # Use LUA_LIBRARIES if available, otherwise fall back to LUA_LIBRARY
    if(LUA_LIBRARIES)
      set(LUA_LIBRARY ${LUA_LIBRARIES})
    endif()
    # Set browser include dir but exclude lua51 since we're using vcpkg's Lua
    set(BROWSER_INCLUDE_DIR ${BROWSER_INCLUDE_DIR} ${CMAKE_SOURCE_DIR}/browser/include)
  endif()
endif()

# *****************************************************************************
# OTClient source files configuration
# *****************************************************************************
set(SOURCE_FILES
        framework/core/application.cpp
        framework/core/asyncdispatcher.cpp
        framework/core/binarytree.cpp
        framework/core/clock.cpp
        framework/core/config.cpp
        framework/core/configmanager.cpp
        framework/core/event.cpp
        framework/core/eventdispatcher.cpp
        framework/core/filestream.cpp
        framework/core/logger.cpp
        framework/core/module.cpp
        framework/core/modulemanager.cpp
        framework/core/resourcemanager.cpp
        framework/core/scheduledevent.cpp
        framework/core/unzipper.cpp
        framework/core/timer.cpp
        framework/discord/discord.cpp
        framework/luaengine/luaexception.cpp
        framework/luaengine/luainterface.cpp
        framework/luaengine/luaobject.cpp
        framework/luaengine/luavaluecasts.cpp
        framework/luafunctions.cpp
        framework/net/connection.cpp
        framework/net/inputmessage.cpp
        framework/net/outputmessage.cpp
        framework/net/protocol.cpp
        framework/net/protocolhttp.cpp
        framework/net/httplogin.cpp
        framework/net/server.cpp
        framework/otml/otmldocument.cpp
        framework/otml/otmlemitter.cpp
        framework/otml/otmlexception.cpp
        framework/otml/otmlnode.cpp
        framework/otml/otmlparser.cpp
        framework/platform/androidgameactivity.cpp
        framework/platform/androidmanager.cpp
        framework/platform/androidwindow.cpp
        framework/platform/platform.cpp
        framework/platform/platformwindow.cpp
        framework/platform/unixcrashhandler.cpp
        framework/platform/unixplatform.cpp
        framework/platform/win32crashhandler.cpp
        framework/platform/win32platform.cpp
        framework/stdext/demangle.cpp
        framework/stdext/math.cpp
        framework/stdext/net.cpp
        framework/stdext/string.cpp
        framework/stdext/time.cpp
        framework/stdext/uri.cpp
        framework/stdext/qrcodegen.cpp
        framework/util/color.cpp
        framework/util/crypt.cpp
        framework/proxy/proxy.cpp
        framework/proxy/proxy_client.cpp
        framework/net/packet_player.cpp
        framework/net/packet_recorder.cpp

        client/animatedtext.cpp
        client/animator.cpp
        client/attachableobject.cpp
        client/attachedeffect.cpp
        client/attachedeffectmanager.cpp
        client/client.cpp
        client/container.cpp
        client/creature.cpp
        client/creatures.cpp
        client/effect.cpp
        client/game.cpp
        client/gameconfig.cpp
        client/houses.cpp
        client/item.cpp
        client/itemtype.cpp
        client/lightview.cpp
        client/localplayer.cpp
        client/luafunctions.cpp
        client/luavaluecasts_client.cpp
        client/map.cpp
        client/mapio.cpp
        client/mapview.cpp
        client/minimap.cpp
        client/missile.cpp
        client/outfit.cpp
        client/player.cpp
        client/position.cpp
        client/protocolcodes.cpp
        client/protocolgame.cpp
        client/protocolgameparse.cpp
        client/protocolgamesend.cpp
        client/spriteappearances.cpp
        client/spritemanager.cpp
        client/statictext.cpp
        client/thing.cpp
        client/thingtype.cpp
        client/thingtypemanager.cpp
        client/tile.cpp
        client/towns.cpp
        client/uicreature.cpp
        client/uigraph.cpp
        client/uiitem.cpp
        client/uieffect.cpp
        client/uimissile.cpp
        client/uimap.cpp
        client/uimapanchorlayout.cpp
        client/uiminimap.cpp
        client/uiprogressrect.cpp
        client/uisprite.cpp

        main.cpp
        androidmain.cpp
)

if (TOGGLE_FRAMEWORK_GRAPHICS)
  set(SOURCE_FILES ${SOURCE_FILES}
          framework/core/adaptativeframecounter.cpp
          framework/core/graphicalapplication.cpp
          framework/core/garbagecollection.cpp
          framework/input/mouse.cpp
          framework/graphics/animatedtexture.cpp
            framework/graphics/apngloader.cpp
            framework/graphics/bitmapfont.cpp
            framework/graphics/cachedtext.cpp
            framework/graphics/coordsbuffer.cpp
            framework/text/TTFFont.cpp
            framework/text/TextShaper.cpp
            framework/text/LocaleShaping.cpp
            framework/graphics/textureatlas.cpp
          framework/graphics/drawpool.cpp
          framework/graphics/drawpoolmanager.cpp
          framework/graphics/fontmanager.cpp
          framework/graphics/framebuffer.cpp
          framework/graphics/graphics.cpp
          framework/graphics/image.cpp
          framework/graphics/painter.cpp
          framework/graphics/paintershaderprogram.cpp
          framework/graphics/particle.cpp
          framework/graphics/particleaffector.cpp
          framework/graphics/particleeffect.cpp
          framework/graphics/particleemitter.cpp
          framework/graphics/particlemanager.cpp
          framework/graphics/particlesystem.cpp
          framework/graphics/particletype.cpp
          framework/graphics/shader.cpp
          framework/graphics/shaderprogram.cpp
          framework/graphics/texture.cpp
          framework/graphics/texturemanager.cpp
          framework/graphics/shadermanager.cpp
          framework/platform/win32window.cpp
          framework/platform/x11window.cpp
          framework/ui/uianchorlayout.cpp
          framework/ui/uiboxlayout.cpp
          framework/ui/uigridlayout.cpp
          framework/ui/uihorizontallayout.cpp
          framework/ui/uilayout.cpp
          framework/ui/uimanager.cpp
          framework/ui/uiparticles.cpp
          framework/ui/uitextedit.cpp
          framework/ui/uitranslator.cpp
          framework/ui/uiverticallayout.cpp
          framework/ui/uiwidget.cpp
          framework/ui/uiwidgetbasestyle.cpp
          framework/ui/uiwidgetimage.cpp
          framework/ui/uiwidgettext.cpp
          framework/ui/uiqrcode.cpp
  )
endif()

if (TOGGLE_FRAMEWORK_SOUND)
  set(SOURCE_FILES ${SOURCE_FILES}
          framework/sound/combinedsoundsource.cpp
          framework/sound/oggsoundfile.cpp
          framework/sound/soundbuffer.cpp
          framework/sound/soundchannel.cpp
          framework/sound/soundfile.cpp
          framework/sound/soundmanager.cpp
          framework/sound/soundsource.cpp
          framework/sound/streamsoundsource.cpp
          framework/sound/soundeffect.cpp
  )
endif()

if (WASM)
  set(SOURCE_FILES ${SOURCE_FILES}
          framework/platform/browserplatform.cpp
          framework/platform/browserwindow.cpp
          framework/net/webconnection.cpp
  )
endif()


target_sources(${PROJECT_NAME} PRIVATE ${SOURCE_FILES})

# LTO (Link-Time Optimization) - Only for GCC/Clang on native platforms.
# MSVC uses /LTCG which is handled separately.
# Emscripten system libs are compiled without LTO; mixing causes wasm-ld errors.
if(NOT MSVC AND NOT CMAKE_SYSTEM_NAME STREQUAL "Emscripten" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Android")
  target_link_options(${PROJECT_NAME} PUBLIC -flto=auto)
endif()

# *****************************************************************************
# Includes and librarys
# *****************************************************************************
if(MSVC)

  # Set variables to have Windows 10 Value for full C++20 support including std::from_chars
  target_compile_definitions(${PROJECT_NAME}
          PRIVATE
          NTDDI_VERSION=0x0A000000
          _WIN32_WINNT=0x0A00
          WINVER=0x0A00
  )

  target_compile_options(${PROJECT_NAME} PUBLIC /MP /EHsc /bigobj)
  # /FS and /Zf improve PDB generation speed but are MSVC-only (clang-cl rejects /Zf)
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    target_compile_options(${PROJECT_NAME} PUBLIC /FS /Zf)
  endif()

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    string(REPLACE "/Zi" "/Z7" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
    string(REPLACE "/Zi" "/Z7" CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG}")
  elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
    string(REPLACE "/Zi" "/Z7" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
    string(REPLACE "/Zi" "/Z7" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
  elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
    string(REPLACE "/Zi" "/Z7" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
    string(REPLACE "/Zi" "/Z7" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  endif()

  if(BUILD_STATIC_LIBRARY)
    log_option_enabled("STATIC_LIBRARY")
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".lib")
    find_package(Vorbis REQUIRED)
    if(ANDROID)
      find_package(Vorbis CONFIG REQUIRED)
    endif()
    set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    # VCPKG_TARGET_TRIPLET is set before project() in root CMakeLists.txt or via -D flag.
    # Do NOT override here — it's too late (after project()), vcpkg toolchain already resolved.

    # Static GLEW requires GLEW_STATIC to avoid __declspec(dllimport)
    target_compile_definitions(${PROJECT_NAME} PRIVATE GLEW_STATIC)

    # System libs required by statically-linked OpenAL, OpenSSL, etc.
    target_link_libraries(${PROJECT_NAME} PRIVATE ole32 winmm Shell32 Advapi32 Crypt32 Ws2_32)
  else()
    log_option_disabled("STATIC_LIBRARY")
    # VCPKG_TARGET_TRIPLET inherited from root CMakeLists.txt or -D flag.
  endif()

  target_include_directories(${PROJECT_NAME}
          PRIVATE
          $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/>
          $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
          ${LUAJIT_INCLUDE_DIR}
          ${Protobuf_INCLUDE_DIRS}
          ${VORBISFILE_INCLUDE_DIR}
          ${GMP_INCLUDE_DIR}
          ${OPENSSL_INCLUDE_DIR}
          ${PHYSFS_INCLUDE_DIR}
          ${PARALLEL_HASHMAP_INCLUDE_DIRS}
          ${NLOHMANN_JSON_INCLUDE_DIR}
          ${BS_THREAD_POOL_INCLUDE_DIR}
          ${STDUUID_INCLUDE_DIRS}
  )
  target_link_libraries(${PROJECT_NAME}
          PRIVATE
          ${LUAJIT_LIBRARY}
          ${CMAKE_THREAD_LIBS_INIT}
          ${PHYSFS_LIBRARY}
          ${ZLIB_LIBRARY}
          ${NLOHMANN_JSON_LIBRARY}
          ${OPENGL_LIBRARIES}
          ${DirectX_LIBRARY}
          ${DirectX_LIBRARIES}
          ${GMP_LIBRARY}
          ${OPENSSL_LIBRARIES}
          ${DBGHELP_LIBRARY}
          ${STDUUID}

          protobuf::libprotobuf protobuf
          ${ABSL_LOG_TARGET}
          Threads::Threads
          GLEW::GLEW
          asio::asio
          OpenAL::OpenAL
          LibLZMA::LibLZMA
          winmm.lib
          pugixml::pugixml
          ${FMT_TARGET}
          Ogg::ogg
          Vorbis::vorbis
          Vorbis::vorbisfile
  )
elseif(ANDROID)
  target_include_directories(${PROJECT_NAME}
          PRIVATE
          $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/>
          $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
          ${LUAJIT_INCLUDE_DIR}
          ${CMAKE_THREAD_LIBS_INIT}
          $<$<BOOL:${OTC_ENABLE_PROTOBUF}>:${Protobuf_INCLUDE_DIRS}>
          $<$<BOOL:${OTC_ENABLE_GMP}>:${GMP_INCLUDE_DIR}>
          $<$<BOOL:${OTC_ENABLE_OPENSSL}>:${OPENSSL_INCLUDE_DIR}>
          $<$<BOOL:${OTC_ENABLE_PHYSFS}>:${PHYSFS_INCLUDE_DIR}>
          ${EGL_INCLUDE_DIR}
          ${PARALLEL_HASHMAP_INCLUDE_DIRS}
          $<$<BOOL:${OTC_ENABLE_NLOHMANN_JSON}>:${NLOHMANN_JSON_INCLUDE_DIR}>
          ${MINIZIP_INCLUDE_DIR}
  )
  target_link_libraries(${PROJECT_NAME}
          PRIVATE
          ${LUA_LIBRARY}
          ${LUAJIT_LIBRARY}
          $<$<BOOL:${OTC_ENABLE_PHYSFS}>:${PHYSFS_LIBRARY}>
          ${ZLIB_LIBRARY}
          $<$<BOOL:${OTC_ENABLE_NLOHMANN_JSON}>:${NLOHMANN_JSON_LIBRARY}>
          ${EGL_LIBRARY}
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:${OGG_LIBRARY}>
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:${VORBIS_LIBRARY}>
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:${VORBISFILE_LIBRARY}>
          $<$<BOOL:${OTC_ENABLE_GMP}>:${GMP_LIBRARY}>
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:${OpenAL_LIBRARY}>
          $<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::SSL>
          $<$<BOOL:${OTC_ENABLE_OPENSSL}>:OpenSSL::Crypto>
          ${STDUUID}
          ${MINIZIP_LIBRARY}

          $<$<BOOL:${OTC_ENABLE_PROTOBUF}>:protobuf::libprotobuf>
          $<$<BOOL:${OTC_ENABLE_PROTOBUF}>:protobuf>
          $<$<BOOL:${OTC_ENABLE_ABSEIL}>:absl::log_internal_check_op>
          Threads::Threads
          asio::asio
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:OpenSLES>
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:Vorbis::vorbis>
          $<$<BOOL:${TOGGLE_FRAMEWORK_SOUND}>:Vorbis::vorbisfile>
          $<$<BOOL:${OTC_ENABLE_LZMA}>:LibLZMA::LibLZMA>
          $<$<NOT:$<BOOL:${OTC_SKIP_GAME_ACTIVITY}>>:game-activity::game-activity>
          GLESv3
          android
          log
          $<$<BOOL:${OTC_ENABLE_PUGIXML}>:pugixml::pugixml>
          $<$<BOOL:${OTC_ENABLE_FMT}>:fmt::fmt-header-only>
  )

elseif(WASM)
  target_include_directories(${PROJECT_NAME}
          PRIVATE
          ${CMAKE_SOURCE_DIR}/src
          ${CMAKE_THREAD_LIBS_INIT}
          ${Protobuf_INCLUDE_DIRS}
          ${GMP_INCLUDE_DIR}
          ${PHYSFS_INCLUDE_DIR}
          ${GLEW_INCLUDE_DIR}
          ${PARALLEL_HASHMAP_INCLUDE_DIRS}
          ${NLOHMANN_JSON_INCLUDE_DIR}
          ${OPENSSL_INCLUDE_DIR}
          ${BROWSER_INCLUDE_DIR}
          ${LUA_INCLUDE_DIR}
          ${BS_THREAD_POOL_INCLUDE_DIR}
          ${STDUUID_INCLUDE_DIRS}
  )
  target_link_libraries(${PROJECT_NAME}
          PRIVATE
          ${LUA_LIBRARY}
          ${PHYSFS_LIBRARY}
          ${ZLIB_LIBRARY}
          ${PROTOBUF_LIBRARY}
          ${NLOHMANN_JSON_LIBRARY}
          ${GLEW_LIBRARY}
          ${OPENGL_LIBRARIES}
          ${DirectX_LIBRARY}
          ${DirectX_LIBRARIES}
          ${OGG_LIBRARY}
          ${VORBIS_LIBRARY}
          ${VORBISFILE_LIBRARY}
          ${GMP_LIBRARY}
          ${STDUUID}
          ${FOUNDATION}
          ${IOKIT}
          ${OPENSSL_LIBRARY}
          ${OPENSSL_CRYPTO_LIBRARY}
          ${HTTPLIB_LIBRARY}

          protobuf::libprotobuf protobuf
          ${ABSL_LOG_TARGET}

          Threads::Threads
          asio::asio
          # OpenAL::OpenAL (using emscripten openal api)
          LibLZMA::LibLZMA
          pugixml::pugixml
          ZLIB::ZLIB
          OpenSSL::SSL
          OpenSSL::Crypto
          httplib::httplib
          fmt::fmt
          Ogg::ogg
          Vorbis::vorbisfile
          Vorbis::vorbis
  )


  get_property(linkflags TARGET ${PROJECT_NAME} PROPERTY LINK_FLAGS)

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${PROJECT_NAME}
            PRIVATE
            -Wall -Wextra -Wpedantic
    )
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
    set(linkflags "${linkflags} -sASSERTIONS=1")
  endif()

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -ffast-math -frtti -pthread -fexceptions")
  set(linkflags "${linkflags}
			-sINVOKE_RUN=0 -sEXIT_RUNTIME=1 -sTEXTDECODER=0 -sCASE_INSENSITIVE_FS=1
			-lopenal -lidbfs.js -lwebsocket.js -sEXPORTED_RUNTIME_METHODS=ccall -sEXPORTED_FUNCTIONS=_main,_paste_return
			-sINCOMING_MODULE_JS_API=[locateFile,preRun,postRun,print,printErr,canvas,setStatus,monitorRunDependencies]
			-sFORCE_FILESYSTEM -sMALLOC=mimalloc -sWEBSOCKET_SUBPROTOCOL=binary -sOFFSCREENCANVAS_SUPPORT=1
			-sOFFSCREEN_FRAMEBUFFER -sENVIRONMENT=web,worker -sPROXY_TO_PTHREAD -sFULL_ES2=1
			-sMIN_WEBGL_VERSION=2 -sMAX_WEBGL_VERSION=2 -sUSE_PTHREADS=1 -sFETCH=1
			-sPTHREAD_POOL_SIZE=navigator.hardwareConcurrency -sALLOW_MEMORY_GROWTH=1
			--preload-file=../otclientrc.lua@otclientrc.lua --preload-file=../init.lua@init.lua
			--preload-file=../data@data --preload-file=../mods@mods --preload-file=../modules@modules
			--shell-file=../browser/shell.html --use-preload-cache")
  set_target_properties(${PROJECT_NAME} PROPERTIES
          LINK_FLAGS ${linkflags})
  set(CMAKE_EXECUTABLE_SUFFIX ".html")
  set(VCPKG_TARGET_TRIPLET "wasm32-emscripten" CACHE STRING "")

else() # Linux/Unix or Windows with non-MSVC compilers
  target_include_directories(${PROJECT_NAME}
          PRIVATE
          $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/>
          $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
          ${LUAJIT_INCLUDE_DIR}
          ${CMAKE_THREAD_LIBS_INIT}
          ${Protobuf_INCLUDE_DIRS}
          ${GMP_INCLUDE_DIR}
          ${PHYSFS_INCLUDE_DIR}
          ${GLEW_INCLUDE_DIR}
          ${PARALLEL_HASHMAP_INCLUDE_DIRS}
          ${NLOHMANN_JSON_INCLUDE_DIR}
          ${OPENSSL_INCLUDE_DIR}
          ${BS_THREAD_POOL_INCLUDE_DIR}
          ${STDUUID_INCLUDE_DIRS}
  )
  target_link_libraries(${PROJECT_NAME}
          PRIVATE
          ${LUAJIT_LIBRARY}
          ${PHYSFS_LIBRARY}
          ${ZLIB_LIBRARY}
          ${NLOHMANN_JSON_LIBRARY}
          ${GLEW_LIBRARY}
          ${OPENGL_LIBRARIES}
          ${DirectX_LIBRARY}
          ${DirectX_LIBRARIES}
          ${OGG_LIBRARY}
          ${VORBIS_LIBRARY}
          ${VORBISFILE_LIBRARY}
          ${GMP_LIBRARY}
          ${STDUUID}
          ${FOUNDATION}
          ${IOKIT}
          ${OPENSSL_LIBRARY}
          ${OPENSSL_CRYPTO_LIBRARY}
          ${HTTPLIB_LIBRARY}

          protobuf::libprotobuf protobuf
          ${ABSL_LOG_TARGET}
          Threads::Threads
          asio::asio
          OpenAL::OpenAL
          LibLZMA::LibLZMA
          pugixml::pugixml
          ZLIB::ZLIB
          OpenSSL::SSL
          OpenSSL::Crypto
          httplib::httplib
          fmt::fmt-header-only
          Ogg::ogg
          Vorbis::vorbisfile
          Vorbis::vorbis
  )
  
  # X11 is only available and needed on Unix/Linux systems (not Windows/macOS)
  if(UNIX AND NOT APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE X11::X11)
  endif()
  
  # Windows-specific libraries when building with MinGW/GCC instead of MSVC
  if(WIN32)
    # winmm is required for multimedia functions (timers, etc.)
    target_link_libraries(${PROJECT_NAME} PRIVATE winmm)
    # DbgHelp for debugging support (optional with MinGW)
    if(DBGHELP_FOUND)
      target_link_libraries(${PROJECT_NAME} PRIVATE ${DBGHELP_LIBRARY})
    endif()
    # Set Windows version defines for full C++20 support
    target_compile_definitions(${PROJECT_NAME}
            PRIVATE
            NTDDI_VERSION=0x0A000000
            _WIN32_WINNT=0x0A00
            WINVER=0x0A00
    )
  endif()

  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    target_compile_options(${PROJECT_NAME}
            PRIVATE
            -Wall -Wextra -Wpedantic
    )
  endif()

endif()

# Link text stack (freetype/harfbuzz/fribidi)
target_link_libraries(${PROJECT_NAME} PRIVATE otc_textstack)

# *****************************************************************************
# Enable otclient console only for debug build
# *****************************************************************************
if(WIN32)
  set_target_properties(${PROJECT_NAME}
          PROPERTIES
          LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE"
          LINK_FLAGS_RELEASE "/SUBSYSTEM:windows /ENTRY:mainCRTStartup"
          LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:CONSOLE"
          LINK_FLAGS_MINSIZEREL "/SUBSYSTEM:windows /ENTRY:mainCRTStartup"
  )
endif(WIN32)

if(ANDROID)
  # NDK r23c+ defaults to lld; only set it when not already the default to avoid
  # issues with the linker not being found on CI paths.
  # Use APPEND so we don't overwrite other flags (which can cause $-escape errors
  # in the generated build.ninja file due to incomplete flag strings).
  if(CMAKE_ANDROID_NDK_VERSION VERSION_LESS "23")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " -fuse-ld=lld")
    string(APPEND CMAKE_EXE_LINKER_FLAGS " -fuse-ld=lld")
  endif()
  # Ninja requires literal '$' to be escaped as '$$'. Some toolchains inject
  # '$' into config-specific flags (not only base CMAKE_*_FLAGS), which breaks
  # generated build.ninja on Windows+Gradle Android builds.
  if(CMAKE_GENERATOR MATCHES "Ninja")
    foreach(_flag_var
        CMAKE_C_FLAGS
        CMAKE_C_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE
        CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_C_FLAGS_MINSIZEREL
        CMAKE_CXX_FLAGS
        CMAKE_CXX_FLAGS_DEBUG
        CMAKE_CXX_FLAGS_RELEASE
        CMAKE_CXX_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS_MINSIZEREL
        CMAKE_ASM_FLAGS
        CMAKE_ASM_FLAGS_DEBUG
        CMAKE_ASM_FLAGS_RELEASE
        CMAKE_ASM_FLAGS_RELWITHDEBINFO
        CMAKE_ASM_FLAGS_MINSIZEREL
        CMAKE_EXE_LINKER_FLAGS
        CMAKE_EXE_LINKER_FLAGS_DEBUG
        CMAKE_EXE_LINKER_FLAGS_RELEASE
        CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
        CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
        CMAKE_SHARED_LINKER_FLAGS
        CMAKE_SHARED_LINKER_FLAGS_DEBUG
        CMAKE_SHARED_LINKER_FLAGS_RELEASE
        CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO
        CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL
        CMAKE_MODULE_LINKER_FLAGS
        CMAKE_MODULE_LINKER_FLAGS_DEBUG
        CMAKE_MODULE_LINKER_FLAGS_RELEASE
        CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO
        CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL
        CMAKE_STATIC_LINKER_FLAGS
        CMAKE_STATIC_LINKER_FLAGS_DEBUG
        CMAKE_STATIC_LINKER_FLAGS_RELEASE
        CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO
        CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL)
      if(DEFINED ${_flag_var} AND NOT "${${_flag_var}}" STREQUAL "")
        string(REPLACE "$" "$$" _flag_escaped "${${_flag_var}}")
        if(NOT _flag_escaped STREQUAL "${${_flag_var}}")
          message(STATUS "Android/Ninja: escaped '$' in ${_flag_var}")
          set(${_flag_var} "${_flag_escaped}" CACHE STRING "" FORCE)
        endif()
      endif()
    endforeach()
  endif()
endif()

# *****************************************************************************
# Link compilation files folder
# *****************************************************************************

## Link compilation files to build/bin folder, else link to the main dir
if (TOGGLE_BIN_FOLDER)
  set_target_properties(${PROJECT_NAME}
          PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
  )
else()
  set_target_properties(${PROJECT_NAME}
          PROPERTIES
          RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/"
  )
endif()
