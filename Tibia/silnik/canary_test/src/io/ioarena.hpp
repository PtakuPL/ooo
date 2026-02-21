/**
 * @file ioarena.hpp
 * @brief Arena PvP system - database I/O layer (pattern: IOMarket)
 */

#pragma once

#include "database/database.hpp"
#include "game/arena/arena_definitions.hpp"
#include "lib/di/container.hpp"

class IOArena {
public:
	IOArena() = default;

	static IOArena &getInstance() {
		return inject<IOArena>();
	}

	// Player stats
	static ArenaPlayerStats getPlayerStats(uint32_t playerId);
	static bool createPlayerEntry(uint32_t playerId);
	static bool updatePlayerStats(uint32_t playerId, const ArenaPlayerStats &stats);
	static bool addArenaPoints(uint32_t playerId, int32_t points);

	// Match lifecycle
	static uint32_t createMatch(ArenaMode mode, uint32_t mapId, uint32_t seasonId);
	static bool finishMatch(uint32_t matchId, int32_t duration, uint8_t winnerTeam);
	static bool saveMatchPlayer(uint32_t matchId, const ArenaPlayerMatchStats &stats);

	// Queue (mainly used as backup; primary queue is in-memory)
	static bool addToQueue(uint32_t playerId, ArenaMode mode, int32_t mmr);
	static bool removeFromQueue(uint32_t playerId);
	static void clearQueue();

	// Rankings
	static std::vector<ArenaRankEntry> getTopRanking(uint32_t limit, uint32_t offset);
	static std::vector<ArenaMatchHistory> getPlayerMatchHistory(uint32_t playerId, uint32_t limit);

	// MMR update after match
	static bool updateMMR(uint32_t playerId, int32_t mmrChange, bool won);
};
