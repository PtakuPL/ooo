#ifndef __SRC_LUA_FUNCTIONS_CORE_LIBS_KV_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_CORE_LIBS_KV_FUNCTIONS_HPP_

#include "pch.hpp"
#include "lua/global/shared_object.hpp"
#include <map>
#include <cstdint>
#include <string>
#include <memory>

#include <cstdint>
#include <string>
#include <memory>

/**
 * Canary - A free and open-source MMORPG server emulator
 * Copyright (©) 2019-2024 OpenTibiaBR <opentibiabr@outlook.com>
 * Repository: https://github.com/opentibiabr/canary
 * License: https://github.com/opentibiabr/canary/blob/main/LICENSE
 * Contributors: https://github.com/opentibiabr/canary/graphs/contributors
 * Website: https://docs.opentibiabr.com/
 */

#pragma once

class ValueWrapper;

#ifndef USE_PRECOMPILED_HEADERS
	#include <string>
	#include <optional>
	#include <vector>
	#include <memory>
	#include <parallel_hashmap/phmap.h>
#endif

using MapType = phmap::flat_hash_map<std::string, std::shared_ptr<ValueWrapper>>;

struct lua_State;

class KVFunctions {
public:
	static void init(lua_State* L);

private:
	static int luaKVScoped(lua_State* L);
	static int luaKVSet(lua_State* L);
	static int luaKVGet(lua_State* L);
	static int luaKVKeys(lua_State* L);
	static int luaKVRemove(lua_State* L);

	static std::optional<ValueWrapper> getValueWrapper(lua_State* L);
	static void pushStringValue(lua_State* L, const std::string &value);
	static void pushIntValue(lua_State* L, const int &value);
	static void pushDoubleValue(lua_State* L, const double &value);
	static void pushArrayValue(lua_State* L, const std::vector<ValueWrapper> &value);
	static void pushMapValue(lua_State* L, const MapType &value);
	static void pushValueWrapper(lua_State* L, const ValueWrapper &valueWrapper);
};

#endif // __SRC_LUA_FUNCTIONS_CORE_LIBS_KV_FUNCTIONS_HPP_
