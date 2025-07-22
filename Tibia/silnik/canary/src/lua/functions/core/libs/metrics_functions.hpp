#ifndef __SRC_LUA_FUNCTIONS_CORE_LIBS_METRICS_FUNCTIONS_HPP_
#define __SRC_LUA_FUNCTIONS_CORE_LIBS_METRICS_FUNCTIONS_HPP_

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

class MetricsFunctions {
public:
	static void init(lua_State* L);

private:
	static int luaMetricsAddCounter(lua_State* L);
	static std::map<std::string, std::string> getAttributes(lua_State* L, int32_t index);
};

#endif // __SRC_LUA_FUNCTIONS_CORE_LIBS_METRICS_FUNCTIONS_HPP_
