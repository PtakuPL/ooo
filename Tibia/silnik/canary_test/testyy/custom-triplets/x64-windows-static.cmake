# Custom triplet for zero-DLL OTClient build (GHA-007)
# Forces all vcpkg libraries to link statically with static CRT (/MT)

set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
