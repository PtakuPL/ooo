# Try to find the lua library
#  LUA_FOUND - system has lua
#  LUA_INCLUDE_DIR - the lua include directory
#  LUA_LIBRARY - the lua library
#  LUA_LIBRARIES - the lua library and it's dependencies

# For WASM/Emscripten builds, look for Lua 5.4+ (vcpkg's lua package)
# For other builds, look for Lua 5.1
if(EMSCRIPTEN OR WASM)
    # vcpkg's lua package uses lua54 for Lua 5.4
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua54 lua5.4 lua)
    SET(_LUA_STATIC_LIBS liblua54.a liblua5.4.a liblua.a lua54 lua5.4 lua)
    SET(_LUA_SHARED_LIBS lua54 lua5.4 lua)
else()
    # Standard Lua 5.1 paths
    FIND_PATH(LUA_INCLUDE_DIR NAMES lua.h PATH_SUFFIXES lua51 lua5-1 lua5.1 lua)
    SET(_LUA_STATIC_LIBS liblua51.a liblua5.1.a liblua-5.1.a liblua.a)
    SET(_LUA_SHARED_LIBS lua51 lua5.1 lua-5.1 lua)
endif()

IF(USE_STATIC_LIBS)
    FIND_LIBRARY(LUA_LIBRARY NAMES ${_LUA_STATIC_LIBS} ${_LUA_SHARED_LIBS})
ELSE()
    FIND_LIBRARY(LUA_LIBRARY NAMES ${_LUA_SHARED_LIBS} ${_LUA_STATIC_LIBS})
ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(Lua DEFAULT_MSG LUA_LIBRARY LUA_INCLUDE_DIR)
MARK_AS_ADVANCED(LUA_LIBRARY LUA_INCLUDE_DIR)
