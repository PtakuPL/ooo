/**
 * @file arena_match.hpp
 * @brief Arena PvP system - single match state management
 */

#pragma once

#include "game/arena/arena_definitions.hpp"
#include "game/movement/position.hpp"

#include <cstdint>
#include <map>
#include <memory>
#include <vector>

class Player;

class ArenaMatch {
public:
	ArenaMatch(uint32_t id, ArenaMode mode, uint32_t mapId = 0);

	// Getters
	uint32_t getId() const {
		return matchId;
	}
	ArenaMode getMode() const {
		return mode;
	}
	ArenaMatchState getState() const {
		return state;
	}
	uint8_t getWinnerTeam() const {
		return winnerTeam;
	}
	int64_t getStartTime() const {
		return startTime;
	}
	int64_t getMaxDuration() const {
		return maxDuration;
	}
	uint32_t getMapId() const {
		return mapId;
	}
	const std::map<uint32_t, ArenaPlayerMatchStats> &getPlayers() const {
		return players;
	}

	// Player management
	void addPlayer(uint32_t playerId, uint8_t team);
	void removePlayer(uint32_t playerId);
	bool hasPlayer(uint32_t playerId) const;
	uint8_t getPlayerTeam(uint32_t playerId) const;
	std::vector<uint32_t> getTeamPlayerIds(uint8_t team) const;
	std::vector<uint32_t> getAllPlayerIds() const;
	uint32_t getAliveCount(uint8_t team) const;

	// Match lifecycle
	void setState(ArenaMatchState newState);
	void setStartTime(int64_t time);
	void start();
	void finish(uint8_t winner);

	// Combat events
	void onKill(uint32_t killerId, uint32_t victimId);
	void onDamage(uint32_t attackerId, int64_t damage);
	void onHeal(uint32_t healerId, int64_t amount);
	void onPlayerDeath(uint32_t playerId);

	// Win condition
	bool checkWinCondition();
	int64_t getRemainingTime() const;
	bool isTimeUp() const;

	// Score
	uint16_t getTeamKills(uint8_t team) const;
	ArenaPlayerMatchStats* getPlayerStats(uint32_t playerId);

	// Convenience accessors for protocol layer
	uint8_t getPlayerCount() const {
		return static_cast<uint8_t>(players.size());
	}
	const std::map<uint32_t, ArenaPlayerMatchStats> &getPlayerStats() const {
		return players;
	}
	int64_t getElapsedSeconds() const;
	std::map<uint8_t, uint16_t> getTeamScores() const;
	std::string getPlayerName(uint32_t playerId) const;

	// Spawn positions (temporary hardcoded, later from map config)
	void setSpawnPositions(uint8_t team, const std::vector<Position> &positions);
	Position getSpawnPosition(uint32_t playerId) const;
	void setExitPosition(const Position &pos);
	Position getExitPosition() const {
		return exitPosition;
	}

	// Dead players tracking (for respawn / elimination modes)
	void markPlayerDead(uint32_t playerId);
	void markPlayerAlive(uint32_t playerId);
	bool isPlayerDead(uint32_t playerId) const;

private:
	uint32_t matchId;
	ArenaMode mode;
	ArenaMatchState state = ArenaMatchState::WAITING;
	uint32_t mapId;
	int64_t startTime = 0;
	int64_t maxDuration; // seconds
	uint8_t winnerTeam = 0;

	std::map<uint32_t, ArenaPlayerMatchStats> players; // playerId -> stats
	std::map<uint8_t, std::vector<Position>> spawnPositions; // team -> positions
	std::vector<uint32_t> deadPlayers; // eliminated players (LMS/1v1)
	Position exitPosition;
};
