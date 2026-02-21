/**
 * @file arena_functions.cpp
 * @brief Arena PvP Lua bindings implementation
 */

#include "lua/functions/core/game/arena_functions.hpp"

#include "creatures/players/player.hpp"
#include "game/arena/arena_system.hpp"
#include "game/game.hpp"
#include "io/ioarena.hpp"
#include "lua/functions/lua_functions_loader.hpp"

// ============================================
// Registration
// ============================================

void ArenaFunctions::init(lua_State* L) {
	// Static "Arena" table
	Lua::registerTable(L, "Arena");
	Lua::registerMethod(L, "Arena", "getPlayerStats", ArenaFunctions::luaArenaGetPlayerStats);
	Lua::registerMethod(L, "Arena", "getTopRanking", ArenaFunctions::luaArenaGetTopRanking);
	Lua::registerMethod(L, "Arena", "getPlayerHistory", ArenaFunctions::luaArenaGetPlayerHistory);
	Lua::registerMethod(L, "Arena", "getActiveMatchCount", ArenaFunctions::luaArenaGetActiveMatchCount);
	Lua::registerMethod(L, "Arena", "getQueueSize", ArenaFunctions::luaArenaGetQueueSize);

	// Arena mode constants
	Lua::registerVariable(L, "Arena", "MODE_1V1", static_cast<int>(ArenaMode::DUEL_1V1));
	Lua::registerVariable(L, "Arena", "MODE_2V2", static_cast<int>(ArenaMode::TEAM_2V2));
	Lua::registerVariable(L, "Arena", "MODE_3V3", static_cast<int>(ArenaMode::TEAM_3V3));
	Lua::registerVariable(L, "Arena", "MODE_FFA", static_cast<int>(ArenaMode::FFA));
	Lua::registerVariable(L, "Arena", "MODE_CTF", static_cast<int>(ArenaMode::CTF));
	Lua::registerVariable(L, "Arena", "MODE_KOTH", static_cast<int>(ArenaMode::KOTH));
	Lua::registerVariable(L, "Arena", "MODE_LMS", static_cast<int>(ArenaMode::LMS));
	Lua::registerVariable(L, "Arena", "MODE_TOURNAMENT", static_cast<int>(ArenaMode::TOURNAMENT));

	// Player state constants
	Lua::registerVariable(L, "Arena", "STATE_IDLE", static_cast<int>(ArenaPlayerState::IDLE));
	Lua::registerVariable(L, "Arena", "STATE_IN_QUEUE", static_cast<int>(ArenaPlayerState::IN_QUEUE));
	Lua::registerVariable(L, "Arena", "STATE_IN_MATCH", static_cast<int>(ArenaPlayerState::IN_MATCH));

	// Player instance methods (extends Player class)
	Lua::registerMethod(L, "Player", "arenaJoinQueue", ArenaFunctions::luaPlayerArenaJoinQueue);
	Lua::registerMethod(L, "Player", "arenaLeaveQueue", ArenaFunctions::luaPlayerArenaLeaveQueue);
	Lua::registerMethod(L, "Player", "arenaGetState", ArenaFunctions::luaPlayerArenaGetState);
	Lua::registerMethod(L, "Player", "arenaIsInArena", ArenaFunctions::luaPlayerArenaIsInArena);
	Lua::registerMethod(L, "Player", "arenaIsInQueue", ArenaFunctions::luaPlayerArenaIsInQueue);
	Lua::registerMethod(L, "Player", "arenaGetStats", ArenaFunctions::luaPlayerArenaGetStats);
	Lua::registerMethod(L, "Player", "arenaGetMMR", ArenaFunctions::luaPlayerArenaGetMMR);
	Lua::registerMethod(L, "Player", "arenaSendStatus", ArenaFunctions::luaPlayerArenaSendStatus);
}

// ============================================
// Arena table methods
// ============================================

// Arena.getPlayerStats(playerId) -> table or nil
int ArenaFunctions::luaArenaGetPlayerStats(lua_State* L) {
	uint32_t playerId = Lua::getNumber<uint32_t>(L, 1);
	auto stats = g_arenaSystem().getPlayerStats(playerId);

	if (stats.playerId == 0) {
		lua_pushnil(L);
		return 1;
	}

	lua_createtable(L, 0, 12);
	Lua::setField(L, "playerId", stats.playerId);
	Lua::setField(L, "mmr", stats.mmr);
	Lua::setField(L, "wins", stats.wins);
	Lua::setField(L, "losses", stats.losses);
	Lua::setField(L, "draws", stats.draws);
	Lua::setField(L, "winStreak", stats.winStreak);
	Lua::setField(L, "bestStreak", stats.bestStreak);
	Lua::setField(L, "totalDamage", static_cast<int64_t>(stats.totalDamage));
	Lua::setField(L, "totalHealing", static_cast<int64_t>(stats.totalHealing));
	Lua::setField(L, "totalKills", stats.totalKills);
	Lua::setField(L, "totalDeaths", stats.totalDeaths);
	Lua::setField(L, "arenaPoints", stats.arenaPoints);

	return 1;
}

// Arena.getTopRanking([limit[, offset]]) -> table
int ArenaFunctions::luaArenaGetTopRanking(lua_State* L) {
	uint32_t limit = Lua::getNumber<uint32_t>(L, 1, 50);
	uint32_t offset = Lua::getNumber<uint32_t>(L, 2, 0);

	auto entries = g_arenaSystem().getTopRanking(limit, offset);

	lua_createtable(L, static_cast<int>(entries.size()), 0);
	int index = 1;
	for (const auto &entry : entries) {
		lua_createtable(L, 0, 7);
		Lua::setField(L, "playerId", entry.playerId);
		Lua::setField(L, "name", entry.playerName);
		Lua::setField(L, "mmr", entry.mmr);
		Lua::setField(L, "wins", entry.wins);
		Lua::setField(L, "losses", entry.losses);
		Lua::setField(L, "winStreak", entry.winStreak);
		Lua::setField(L, "bestStreak", entry.bestStreak);
		lua_rawseti(L, -2, index++);
	}

	return 1;
}

// Arena.getPlayerHistory(playerId[, limit]) -> table
int ArenaFunctions::luaArenaGetPlayerHistory(lua_State* L) {
	uint32_t playerId = Lua::getNumber<uint32_t>(L, 1);
	uint32_t limit = Lua::getNumber<uint32_t>(L, 2, 20);

	auto history = g_arenaSystem().getPlayerHistory(playerId, limit);

	lua_createtable(L, static_cast<int>(history.size()), 0);
	int index = 1;
	for (const auto &entry : history) {
		lua_createtable(L, 0, 11);
		Lua::setField(L, "matchId", entry.matchId);
		Lua::setField(L, "mode", static_cast<uint8_t>(entry.mode));
		Lua::setField(L, "modeName", arenaModeToString(entry.mode));
		Lua::setField(L, "startedAt", static_cast<int64_t>(entry.startedAt));
		Lua::setField(L, "duration", entry.duration);
		Lua::setField(L, "winnerTeam", entry.winnerTeam);
		Lua::setField(L, "playerTeam", entry.playerTeam);
		Lua::setField(L, "kills", entry.kills);
		Lua::setField(L, "deaths", entry.deaths);
		Lua::setField(L, "mmrChange", entry.mmrChange);
		lua_rawseti(L, -2, index++);
	}

	return 1;
}

// Arena.getActiveMatchCount() -> number
int ArenaFunctions::luaArenaGetActiveMatchCount(lua_State* L) {
	lua_pushnumber(L, g_arenaSystem().getActiveMatchCount());
	return 1;
}

// Arena.getQueueSize(mode) -> number
int ArenaFunctions::luaArenaGetQueueSize(lua_State* L) {
	uint8_t modeId = Lua::getNumber<uint8_t>(L, 1);
	lua_pushnumber(L, g_arenaSystem().getQueueSize(static_cast<ArenaMode>(modeId)));
	return 1;
}

// ============================================
// Player instance methods
// ============================================

// player:arenaJoinQueue(mode) -> bool
int ArenaFunctions::luaPlayerArenaJoinQueue(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		Lua::reportErrorFunc("Player not found");
		lua_pushboolean(L, false);
		return 1;
	}

	uint8_t modeId = Lua::getNumber<uint8_t>(L, 2);
	auto mode = static_cast<ArenaMode>(modeId);
	if (mode == ArenaMode::NONE || modeId > static_cast<uint8_t>(ArenaMode::TOURNAMENT)) {
		lua_pushboolean(L, false);
		return 1;
	}

	bool result = g_arenaSystem().joinQueue(player, mode);
	lua_pushboolean(L, result);
	return 1;
}

// player:arenaLeaveQueue() -> bool
int ArenaFunctions::luaPlayerArenaLeaveQueue(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		Lua::reportErrorFunc("Player not found");
		lua_pushboolean(L, false);
		return 1;
	}

	bool result = g_arenaSystem().leaveQueue(player);
	lua_pushboolean(L, result);
	return 1;
}

// player:arenaGetState() -> number (ArenaPlayerState enum)
int ArenaFunctions::luaPlayerArenaGetState(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		Lua::reportErrorFunc("Player not found");
		lua_pushnumber(L, 0);
		return 1;
	}

	auto state = g_arenaSystem().getPlayerState(player->getGUID());
	lua_pushnumber(L, static_cast<uint8_t>(state));
	return 1;
}

// player:arenaIsInArena() -> bool
int ArenaFunctions::luaPlayerArenaIsInArena(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		lua_pushboolean(L, false);
		return 1;
	}

	lua_pushboolean(L, g_arenaSystem().isPlayerInArena(player->getGUID()));
	return 1;
}

// player:arenaIsInQueue() -> bool
int ArenaFunctions::luaPlayerArenaIsInQueue(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		lua_pushboolean(L, false);
		return 1;
	}

	lua_pushboolean(L, g_arenaSystem().isPlayerInQueue(player->getGUID()));
	return 1;
}

// player:arenaGetStats() -> table or nil
int ArenaFunctions::luaPlayerArenaGetStats(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		lua_pushnil(L);
		return 1;
	}

	auto stats = g_arenaSystem().getPlayerStats(player->getGUID());
	if (stats.playerId == 0) {
		lua_pushnil(L);
		return 1;
	}

	lua_createtable(L, 0, 12);
	Lua::setField(L, "playerId", stats.playerId);
	Lua::setField(L, "mmr", stats.mmr);
	Lua::setField(L, "wins", stats.wins);
	Lua::setField(L, "losses", stats.losses);
	Lua::setField(L, "draws", stats.draws);
	Lua::setField(L, "winStreak", stats.winStreak);
	Lua::setField(L, "bestStreak", stats.bestStreak);
	Lua::setField(L, "totalDamage", static_cast<int64_t>(stats.totalDamage));
	Lua::setField(L, "totalHealing", static_cast<int64_t>(stats.totalHealing));
	Lua::setField(L, "totalKills", stats.totalKills);
	Lua::setField(L, "totalDeaths", stats.totalDeaths);
	Lua::setField(L, "arenaPoints", stats.arenaPoints);

	return 1;
}

// player:arenaGetMMR() -> number
int ArenaFunctions::luaPlayerArenaGetMMR(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		lua_pushnumber(L, 0);
		return 1;
	}

	auto stats = g_arenaSystem().getPlayerStats(player->getGUID());
	lua_pushnumber(L, stats.mmr);
	return 1;
}

// player:arenaSendStatus() -> bool (sends arena window/status to client)
int ArenaFunctions::luaPlayerArenaSendStatus(lua_State* L) {
	const auto &player = Lua::getPlayer(L, 1);
	if (!player) {
		lua_pushboolean(L, false);
		return 1;
	}

	// This triggers the protocol to send arena status + stats
	// For now we send a text message as a placeholder until client UI is ready
	auto stats = g_arenaSystem().getPlayerStats(player->getGUID());
	auto state = g_arenaSystem().getPlayerState(player->getGUID());

	std::string stateStr;
	switch (state) {
		case ArenaPlayerState::IN_QUEUE:
			stateStr = "In Queue";
			break;
		case ArenaPlayerState::IN_MATCH:
			stateStr = "In Match";
			break;
		default:
			stateStr = "Idle";
			break;
	}

	std::string msg = "[Arena] Status: " + stateStr + "\n";
	msg += "MMR: " + std::to_string(stats.mmr) + " | ";
	msg += "W: " + std::to_string(stats.wins) + " L: " + std::to_string(stats.losses) + " D: " + std::to_string(stats.draws) + "\n";
	msg += "Streak: " + std::to_string(stats.winStreak) + " (Best: " + std::to_string(stats.bestStreak) + ")\n";
	msg += "K/D: " + std::to_string(stats.totalKills) + "/" + std::to_string(stats.totalDeaths) + "\n";
	msg += "Points: " + std::to_string(stats.arenaPoints);

	player->sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg);
	lua_pushboolean(L, true);
	return 1;
}
