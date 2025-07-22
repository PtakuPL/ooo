cmake_minimum_required(VERSION 3.22 FATAL_ERROR)

# VCPKG toolchain - wczytanie jeśli zmienna środowiskowa jest ustawiona
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
endif()

if(DEFINED ENV{VCPKG_DEFAULT_TRIPLET} AND NOT DEFINED VCPKG_TARGET_TRIPLET)
    set(VCPKG_TARGET_TRIPLET "$ENV{VCPKG_DEFAULT_TRIPLET}" CACHE STRING "")
endif()

set(CMAKE_TOOLCHAIN_FILE "/wsl.localhost/Ubuntu/home/ptaku/vcpkg/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")

set(VCPKG_FEATURE_FLAGS "versions")
set(VCPKG_BUILD_TYPE "release")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Projekt
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    project(canary-debug LANGUAGES CXX)
else()
    project(canary LANGUAGES CXX)
endif()
set(CMAKE_CXX_STANDARD 20)
add_compile_options(-fcoroutines)

# Ścieżka do modułów cmake
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

# Flagi kompilatora do kompatybilności na CPU (opcjonalne)
if(NOT MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=x86-64 -mtune=generic -mno-avx -mno-sse4")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=x86-64 -mtune=generic -mno-avx -mno-sse4")
endif()

include_directories(${CMAKE_SOURCE_DIR}/vcpkg_installed/x64-linux/include)
include_directories(${CMAKE_SOURCE_DIR}/budowa_silnik/vcpkg_installed/x64-linux/include)
include_directories(/home/ptaku/serweryt/Tibia/silnik/canary/vcpkg_installed/x64-linux/include/luajit-2.1)


# Załaduj moduły pomocnicze
include(MessageColors)
include(LoggingHelper)

# Opcje build
option(OPTIONS_ENABLE_CCACHE "Enable ccache" OFF)
option(OPTIONS_ENABLE_SCCACHE "Use sccache to speed up compilation process" OFF)
option(OPTIONS_ENABLE_IPO "Enable IPO/LTO" ON)
option(FEATURE_METRICS "Enable metrics feature" OFF)
option(BUILD_TESTS "Build tests" OFF)
option(RUN_TESTS_AFTER_BUILD "Run tests after build" OFF)

# Włączenie ccache/sccache (jeśli są zainstalowane)
if(OPTIONS_ENABLE_CCACHE)
    find_program(CCACHE ccache)
    if(CCACHE)
        log_option_enabled("ccache")
        set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE})
    else()
        log_option_disabled("ccache")
    endif()
endif()

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

if(FEATURE_METRICS)
    log_option_enabled("metrics")
else()
    log_option_disabled("metrics")
endif()

# Znajdź pakiety przez vcpkg
find_package(asio CONFIG REQUIRED)
find_package(pugixml CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(CURL CONFIG REQUIRED)
find_package(protobuf CONFIG REQUIRED)
find_path(PARALLEL_HASHMAP_INCLUDE_DIRS "parallel_hashmap/btree.h"
  PATHS "${CMAKE_SOURCE_DIR}/vcpkg/installed/x64-linux/include"
        "/home/ptaku/vcpkg/installed/x64-linux/include"
)
if(NOT PARALLEL_HASHMAP_INCLUDE_DIRS)
  message(FATAL_ERROR "parallel_hashmap include directory not found. Upewnij się, że masz zainstalowany parallel-hashmap w vcpkg.")
endif()
include_directories(${PARALLEL_HASHMAP_INCLUDE_DIRS})

find_package(magic_enum CONFIG REQUIRED)
find_package(mio CONFIG REQUIRED)

include_directories("/home/ptaku/vcpkg/installed/x64-linux/include/luajit-2.1")
link_directories("/home/ptaku/vcpkg/installed/x64-linux/lib")


find_package(unofficial-libmariadb CONFIG REQUIRED)
find_package(absl CONFIG REQUIRED)
find_package(ZLIB REQUIRED)
find_package(fmt REQUIRED)
find_package(Boost REQUIRED)

# bshoshany-thread-pool i inne header-only:
find_path(BSHOSHANY_THREAD_POOL_INCLUDE_DIRS "BS_thread_pool.hpp")
find_path(ATOMIC_QUEUE_INCLUDE_DIRS "atomic_queue/atomic_queue.h")
find_path(BEXT_DI_INCLUDE_DIRS "boost/di.hpp")

# Dodaj pliki źródłowe jako bibliotekę statyczną
file(GLOB_RECURSE CANARY_SOURCES src/*.cpp src/*.c)
add_library(canary_lib STATIC ${CANARY_SOURCES})
target_include_directories(${PROJECT_NAME}_lib PUBLIC /home/ptaku/serweryt/Tibia/silnik/canary/vcpkg_installed/x64-linux/include)
target_include_directories(canary_lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_include_directories(canary_lib PRIVATE

    ${BSHOSHANY_THREAD_POOL_INCLUDE_DIRS}
    ${ATOMIC_QUEUE_INCLUDE_DIRS}
    ${BEXT_DI_INCLUDE_DIRS}
    ${PARALLEL_HASHMAP_INCLUDE_DIRS}
)

target_link_libraries(canary_lib PRIVATE
    asio::asio
    pugixml::pugixml
    spdlog::spdlog
    CURL::libcurl
    protobuf::libprotobuf
    magic_enum::magic_enum
    mio::mio
    unofficial::libmariadb
    absl::base
    absl::log
    ZLIB::ZLIB
)

# Dodaj executable, główny plik src/main.cpp
add_executable(canary src/main.cpp)
target_link_libraries(canary PRIVATE canary_lib)
target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)

# Testy jeśli wybrane
if(BUILD_TESTS OR PACKAGE_TESTS)
    add_subdirectory(tests)
endif()