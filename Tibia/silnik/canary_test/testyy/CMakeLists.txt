cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

# CMAKE
# apt install build-essential git
# git clone https://github.com/Kitware/CMake/; cd CMake
# ./bootstrap && make && sudo make install

# VCPKG
# cmake -DCMAKE_TOOLCHAIN_FILE=/opt/workspace/vcpkg/scripts/buildsystems/vcpkg.cmake ..
# .\vcpkg --triplet x64-windows asio luajit glew physfs openal-soft libogg libvorbis zlib opengl nlohmann-json protobuf liblzma openssl
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
	set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
endif()

if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET} AND NOT DEFINED VCPKG_TARGET_TRIPLET)
	set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
endif()

set(VCPKG_FEATURE_FLAGS "versions")
set(VCPKG_BUILD_TYPE "release")

# For static triplet (x64-windows-static), use static runtime library (/MT)
# This ensures consistency between vcpkg libraries and project code
# Must be set BEFORE project() for it to take effect on MSVC
# Check for static triplet by name pattern (works before project() call)
set(_vcpkg_triplet_to_check "${VCPKG_TARGET_TRIPLET}")
if(NOT _vcpkg_triplet_to_check AND DEFINED ENV{VCPKG_DEFAULT_TRIPLET})
    set(_vcpkg_triplet_to_check "$ENV{VCPKG_DEFAULT_TRIPLET}")
endif()

if(_vcpkg_triplet_to_check MATCHES ".*-static$")
    # Set policy CMP0091 to NEW to enable CMAKE_MSVC_RUNTIME_LIBRARY
    cmake_policy(SET CMP0091 NEW)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>" CACHE STRING "MSVC runtime library")
endif()

unset(_vcpkg_triplet_to_check)

if (VCPKG_TARGET_ANDROID)
    include("cmake/vcpkg_android.cmake")
	set(Android_INCLUDES ${Android_INCLUDES} ${CMAKE_SOURCE_DIR}/android/app/libs/include)
	set(Android_LIBRARIES ${Android_LIBRARIES} ${CMAKE_SOURCE_DIR}/android/app/libs/lib/${CMAKE_ANDROID_ARCH_ABI})
	include_directories(Android_INCLUDES)
endif()

# *****************************************************************************
# Project otclient
# *****************************************************************************
project(otclient)

# *****************************************************************************
# Append cmake search path
# *****************************************************************************
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# *****************************************************************************
# Include cmake tools
# *****************************************************************************
include(MessageColors)
include(LoggingHelper)
include(GNUInstallDirs)

# *****************************************************************************
# Options
# *****************************************************************************
option(OPTIONS_ENABLE_CCACHE "Enable ccache" OFF)
option(OPTIONS_ENABLE_SCCACHE "Use sccache to speed up compilation process" OFF)
option(OPTIONS_ENABLE_IPO "Check and Enable interprocedural optimization (IPO/LTO)" ON)

# *****************************************************************************
# Options Code
# *****************************************************************************

# === CCACHE ===
if(OPTIONS_ENABLE_CCACHE)
	find_program(CCACHE ccache)
	if(CCACHE)
		log_option_enabled("ccache")
		set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE})
		else()
		log_option_disabled("ccache")
	endif()
endif()


# === SCCACHE ===
if(OPTIONS_ENABLE_SCCACHE)
  find_program(SCCACHE_PATH sccache)
  if(SCCACHE_PATH)
    log_option_enabled("sccache")
    set(CMAKE_C_COMPILER_LAUNCHER ${SCCACHE_PATH})
    set(CMAKE_CXX_COMPILER_LAUNCHER ${SCCACHE_PATH})
  else()
    log_option_disabled("sccache")
  endif()
endif()


# === IPO ===
option(OPTIONS_ENABLE_IPO "Check and Enable interprocedural optimization (IPO/LTO)" ON)
if(OPTIONS_ENABLE_IPO)
	if(MSVC)
		log_war("IPO/LTCG disabled on MSVC to avoid internal compiler error C1001")
	else()
		log_option_enabled("ipo")

		include(CheckIPOSupported)
		check_ipo_supported(RESULT result OUTPUT output)
		if(result)
			set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
		else()
			log_war("IPO is not supported: ${output}")
		endif()
	endif()
else()
	log_option_disabled("ipo")
endif()


# *****************************************************************************
# Add project
# *****************************************************************************

# ===== Text stack (TTF + HarfBuzz + FriBidi) =====
# Options (enabled by default to get full i18n rendering)
option(OTC_ENABLE_TTF     "Enable TTF/Freetype text rendering" ON)
option(OTC_ENABLE_HARFBUZZ "Enable HarfBuzz shaping" ON)
option(OTC_ENABLE_FRIBIDI  "Enable FriBidi bidi support" ON)

# Create an interface target that will carry the include/libs/defines
add_library(otc_textstack INTERFACE)

# Freetype (via vcpkg CONFIG or system)
if(OTC_ENABLE_TTF)
  # Prefer modern CONFIG package (e.g. vcpkg). If not found, fall back to module mode.
  find_package(Freetype CONFIG QUIET)
  if(NOT TARGET Freetype::Freetype)
    find_package(Freetype REQUIRED)
  endif()

  target_link_libraries(otc_textstack INTERFACE Freetype::Freetype)
  target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_TTF)
endif()

# Prefer pkg-config from vcpkg host tools when available
if(NOT PKG_CONFIG_EXECUTABLE)
  find_program(PKG_CONFIG_EXECUTABLE
    NAMES pkgconf pkg-config
    PATHS
      "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/${VCPKG_HOST_TRIPLET}/tools/pkgconf"
      "$ENV{VCPKG_ROOT}/installed/${VCPKG_HOST_TRIPLET}/tools/pkgconf"
      "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/tools/pkgconf"
    NO_DEFAULT_PATH)
endif()
find_package(PkgConfig QUIET)

# HarfBuzz (via vcpkg CONFIG, with pkg-config fallback)
if(OTC_ENABLE_HARFBUZZ)
  # Try HarfBuzz from CONFIG (vcpkg)
  find_package(harfbuzz CONFIG QUIET)

  # Prefer imported target from vcpkg
  if(TARGET harfbuzz::harfbuzz)
    target_link_libraries(otc_textstack INTERFACE harfbuzz::harfbuzz)
  elseif(TARGET harfbuzz)
    target_link_libraries(otc_textstack INTERFACE harfbuzz)
  elseif(PkgConfig_FOUND)
    # Fallback: pkg-config + system includes/libs
    pkg_check_modules(HARFBUZZ REQUIRED harfbuzz)
    target_include_directories(otc_textstack INTERFACE ${HARFBUZZ_INCLUDE_DIRS})
    target_link_libraries(otc_textstack INTERFACE ${HARFBUZZ_LINK_LIBRARIES})
  else()
    message(WARNING "OTC_ENABLE_HARFBUZZ=ON but harfbuzz was not found and pkg-config is unavailable; disabling HarfBuzz")
    set(OTC_ENABLE_HARFBUZZ OFF)
  endif()

  if(OTC_ENABLE_HARFBUZZ)
    target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_HARFBUZZ)
  endif()
endif()

# FriBidi (prefer CONFIG from vcpkg, otherwise fall back to pkg-config)
if(OTC_ENABLE_FRIBIDI)
  find_package(fribidi CONFIG QUIET)
  if(TARGET fribidi::fribidi)
    target_link_libraries(otc_textstack INTERFACE fribidi::fribidi)
  elseif(TARGET fribidi)
    target_link_libraries(otc_textstack INTERFACE fribidi)
  elseif(PkgConfig_FOUND)
    pkg_check_modules(FRIBIDI REQUIRED fribidi)
    target_include_directories(otc_textstack INTERFACE ${FRIBIDI_INCLUDE_DIRS})
    target_link_libraries(otc_textstack INTERFACE ${FRIBIDI_LINK_LIBRARIES})
  else()
    message(WARNING "OTC_ENABLE_FRIBIDI=ON but fribidi was not found and pkg-config is unavailable; disabling FriBidi")
    set(OTC_ENABLE_FRIBIDI OFF)
  endif()

  if(OTC_ENABLE_FRIBIDI)
    target_compile_definitions(otc_textstack INTERFACE OTC_ENABLE_FRIBIDI)
  endif()
endif()
# ===== end text stack =====

# Protobuf (optional, can be disabled for build analysis or cross-compilation)
option(OTC_ENABLE_PROTOBUF "Enable Protobuf support" ON)
if(OTC_ENABLE_PROTOBUF)
  add_subdirectory(src/protobuf)
else()
  # Create a stub target when protobuf is disabled to satisfy link dependencies
  add_library(protobuf INTERFACE)
  # Create a fake protobuf::libprotobuf target as well
  if(NOT TARGET protobuf::libprotobuf)
    add_library(protobuf::libprotobuf ALIAS protobuf)
  endif()
endif()
# Src
add_subdirectory(src)

# Tests (optional, enable with -DBUILD_TESTING=ON)
option(BUILD_TESTING "Build unit tests" OFF)
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()
