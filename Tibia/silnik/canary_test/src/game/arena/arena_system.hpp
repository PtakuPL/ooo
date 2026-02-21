/**
 * @file arena_system.hpp
 * @brief Arena PvP system - main singleton managing all arena operations
 */

#pragma once

#include "game/arena/arena_definitions.hpp"
#include "game/arena/arena_match.hpp"
#include "game/arena/arena_matchmaking.hpp"
#include "lib/di/container.hpp"

#include <cstdint>
#include <map>
#include <memory>
#include <vector>

class Player;

class ArenaSystem {
public:
	ArenaSystem() = default;

	static ArenaSystem &getInstance() {
		return inject<ArenaSystem>();
	}

	// ========== Lifecycle ==========
	void init();
	void shutdown();
	void tick(); // Called every 5 seconds by Game

	// ========== Queue ==========
	bool joinQueue(const std::shared_ptr<Player> &player, ArenaMode mode);
	bool leaveQueue(const std::shared_ptr<Player> &player);
	bool isPlayerInQueue(uint32_t playerId) const;

	// ========== Match state ==========
	bool isPlayerInArena(uint32_t playerId) const;
	ArenaPlayerState getPlayerState(uint32_t playerId) const;
	ArenaMatch* getPlayerMatch(uint32_t playerId);
	const ArenaMatch* getPlayerMatch(uint32_t playerId) const;

	// ========== Combat hooks (called from existing combat system) ==========
	void onArenaKill(uint32_t killerId, uint32_t victimId);
	void onArenaDeath(uint32_t playerId);
	void onArenaLogout(uint32_t playerId);
	void onArenaDamage(uint32_t attackerId, uint32_t targetId, int64_t damage);
	void onArenaHeal(uint32_t healerId, int64_t amount);

	// ========== Stats / Rankings ==========
	ArenaPlayerStats getPlayerStats(uint32_t playerId);
	std::vector<ArenaRankEntry> getTopRanking(uint32_t limit = 50, uint32_t offset = 0);
	std::vector<ArenaMatchHistory> getPlayerHistory(uint32_t playerId, uint32_t limit = 20);

	// ========== Info ==========
	uint32_t getActiveMatchCount() const;
	uint32_t getQueueSize(ArenaMode mode) const;

private:
	// Create and start a match from matched players
	void createMatch(const ArenaMatchmaking::MatchGroup &group);

	// Finish an active match, save results, update MMR
	void finishMatch(uint32_t matchId);

	// Calculate MMR change for a player
	int32_t calculateMMRChange(int32_t playerMMR, int32_t opponentAverageMMR, bool won) const;

	// Assign teams for team modes (zigzag by MMR)
	void assignTeams(ArenaMatch &match, const std::vector<ArenaQueueEntry> &players);

	// Teleport players into/out of arena
	void teleportPlayersIn(ArenaMatch &match);
	void teleportPlayersOut(ArenaMatch &match);

	// Heal and prepare players for combat
	void preparePlayer(const std::shared_ptr<Player> &player);

	// Send status messages to players
	void sendMatchMessage(ArenaMatch &match, const std::string &message);

	// Check active matches for timeouts and win conditions
	void checkActiveMatches();

	// ========== Data ==========
	ArenaMatchmaking matchmaking;
	std::map<uint32_t, std::shared_ptr<ArenaMatch>> activeMatches; // matchId -> match
	std::map<uint32_t, uint32_t> playerToMatch; // playerId -> matchId
	std::map<uint32_t, ArenaPlayerState> playerStates; // playerId -> state
	uint32_t nextMatchId = 0; // In-memory counter (DB gives real ID)
	bool initialized = false;
};

constexpr auto g_arenaSystem = ArenaSystem::getInstance;
