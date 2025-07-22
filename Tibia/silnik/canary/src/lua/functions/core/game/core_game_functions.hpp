#ifndef __SRC_LUA_FUNCTIONS_CORE_GAME_CORE_GAME_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_CORE_GAME_CORE_GAME_FUNCTIONS_HPP_

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
#include "lua/functions/core/game/config_functions.hpp"
#include "lua/functions/core/game/game_functions.hpp"
#include "lua/functions/core/game/bank_functions.hpp"
#include "lua/functions/core/game/global_functions.hpp"
#include "lua/functions/core/game/lua_enums.hpp"
#include "lua/functions/core/game/modal_window_functions.hpp"

class CoreGameFunctions final : LuaScriptInterface {
public:
	explicit CoreGameFunctions(lua_State* L) :
		LuaScriptInterface("CoreGameFunctions") {
		init(L);
	}
	~CoreGameFunctions() override = default;

	static void init(lua_State* L) {
		ConfigFunctions::init(L);
		GameFunctions::init(L);
		BankFunctions::init(L);
		GlobalFunctions::init(L);
		LuaEnums::init(L);
		ModalWindowFunctions::init(L);
	}

private:
};

#endif // __SRC_LUA_FUNCTIONS_CORE_GAME_CORE_GAME_FUNCTIONS_HPP_
