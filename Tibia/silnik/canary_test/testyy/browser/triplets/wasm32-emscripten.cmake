# Custom vcpkg triplet for wasm32-emscripten with threading support.
# Emscripten pthreads require -matomics -mbulk-memory on ALL compilation units,
# including vcpkg-installed ports.  Without these flags, wasm-ld will reject
# object files that mix shared-memory and non-shared-memory code.

set(VCPKG_TARGET_ARCHITECTURE wasm32)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Emscripten)

# Threading flags — critical for -sUSE_PTHREADS / -sPROXY_TO_PTHREAD builds.
set(VCPKG_C_FLAGS   "-pthread -matomics -mbulk-memory")
set(VCPKG_CXX_FLAGS "-pthread -matomics -mbulk-memory")
