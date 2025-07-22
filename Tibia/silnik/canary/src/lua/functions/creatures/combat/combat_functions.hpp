#ifndef __SRC_LUA_FUNCTIONS_CREATURES_COMBAT_COMBAT_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_CREATURES_COMBAT_COMBAT_FUNCTIONS_HPP_

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

#include "lua/functions/creatures/combat/condition_functions.hpp"
#include <string>
#include <vector>
#include <map>
#include <cstdint>
#include "lua/functions/creatures/combat/spell_functions.hpp"
#include "lua/functions/creatures/combat/variant_functions.hpp"

class CombatFunctions {
public:
	static void init(lua_State* L);

private:
	static int luaCombatCreate(lua_State* L);

	static int luaCombatSetParameter(lua_State* L);
	static int luaCombatSetFormula(lua_State* L);

	static int luaCombatSetArea(lua_State* L);
	static int luaCombatSetCondition(lua_State* L);
	static int luaCombatSetCallback(lua_State* L);
	static int luaCombatSetOrigin(lua_State* L);

	static int luaCombatExecute(lua_State* L);
};

#endif // __SRC_LUA_FUNCTIONS_CREATURES_COMBAT_COMBAT_FUNCTIONS_HPP_
