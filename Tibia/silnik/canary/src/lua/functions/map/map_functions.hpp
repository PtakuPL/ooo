#ifndef __SRC_LUA_FUNCTIONS_MAP_MAP_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_MAP_MAP_FUNCTIONS_HPP_

#include "pch.hpp"
#include "lua/global/shared_object.hpp"
#include <functional>
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

#include "lua/scripts/luascript.hpp"
#include <string>
#include <vector>
#include <map>
#include <cstdint>
#include "lua/functions/map/house_functions.hpp"
#include "lua/functions/map/position_functions.hpp"
#include "lua/functions/map/teleport_functions.hpp"
#include "lua/functions/map/tile_functions.hpp"
#include "lua/functions/map/town_functions.hpp"

class MapFunctions final : LuaScriptInterface {
public:
	explicit MapFunctions(lua_State* L) :
		LuaScriptInterface("MapFunctions") {
		init(L);
	}
	~MapFunctions() override = default;

	static void init(lua_State* L) {
		HouseFunctions::init(L);
		PositionFunctions::init(L);
		TeleportFunctions::init(L);
		TileFunctions::init(L);
		TownFunctions::init(L);
	}
};

#endif // __SRC_LUA_FUNCTIONS_MAP_MAP_FUNCTIONS_HPP_
