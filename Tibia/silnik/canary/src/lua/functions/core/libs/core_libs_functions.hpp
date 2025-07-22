#ifndef __SRC_LUA_FUNCTIONS_CORE_LIBS_CORE_LIBS_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_CORE_LIBS_CORE_LIBS_FUNCTIONS_HPP_

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
#include "lua/functions/core/libs/db_functions.hpp"
#include "lua/functions/core/libs/result_functions.hpp"
#include "lua/functions/core/libs/logger_functions.hpp"
#include "lua/functions/core/libs/metrics_functions.hpp"
#include "lua/functions/core/libs/kv_functions.hpp"

class CoreLibsFunctions final : LuaScriptInterface {
public:
	explicit CoreLibsFunctions(lua_State* L) :
		LuaScriptInterface("CoreLibsFunctions") {
		init(L);
	}
	~CoreLibsFunctions() override = default;

	static void init(lua_State* L) {
		DBFunctions::init(L);
		ResultFunctions::init(L);
		LoggerFunctions::init(L);
		MetricsFunctions::init(L);
		KVFunctions::init(L);
	}

private:
};

#endif // __SRC_LUA_FUNCTIONS_CORE_LIBS_CORE_LIBS_FUNCTIONS_HPP_
