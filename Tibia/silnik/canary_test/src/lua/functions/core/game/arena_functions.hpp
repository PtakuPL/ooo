/**
 * @file arena_functions.hpp
 * @brief Arena PvP Lua bindings - exposes Arena system to Lua scripts
 */

#pragma once

class ArenaFunctions {
public:
	static void init(lua_State* L);

private:
	// ========== "Arena" table methods ==========
	static int luaArenaGetPlayerStats(lua_State* L);
	static int luaArenaGetTopRanking(lua_State* L);
	static int luaArenaGetPlayerHistory(lua_State* L);
	static int luaArenaGetActiveMatchCount(lua_State* L);
	static int luaArenaGetQueueSize(lua_State* L);

	// ========== Player arena methods (player:arenaXxx) ==========
	static int luaPlayerArenaJoinQueue(lua_State* L);
	static int luaPlayerArenaLeaveQueue(lua_State* L);
	static int luaPlayerArenaGetState(lua_State* L);
	static int luaPlayerArenaIsInArena(lua_State* L);
	static int luaPlayerArenaIsInQueue(lua_State* L);
	static int luaPlayerArenaGetStats(lua_State* L);
	static int luaPlayerArenaGetMMR(lua_State* L);
	static int luaPlayerArenaSendStatus(lua_State* L);
};
