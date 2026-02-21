/**
 * @file arena_definitions.hpp
 * @brief Arena PvP system - enumerations and data structures
 */

#pragma once

#include <cstdint>
#include <string>
#include <map>
#include <vector>

// ============================================
// Enumerations
// ============================================

enum class ArenaMode : uint8_t {
	NONE = 0,
	DUEL_1V1 = 1,
	TEAM_2V2 = 2,
	TEAM_3V3 = 3,
	FFA = 4,
	CTF = 5,
	KOTH = 6,
	LMS = 7,
	TOURNAMENT = 8,
};

enum class ArenaMatchState : uint8_t {
	WAITING = 0,
	COUNTDOWN = 1,
	IN_PROGRESS = 2,
	FINISHED = 3,
};

enum class ArenaPlayerState : uint8_t {
	IDLE = 0,
	IN_QUEUE = 1,
	IN_MATCH = 2,
};

// ============================================
// Data structures
// ============================================

struct ArenaPlayerStats {
	uint32_t playerId = 0;
	int32_t mmr = 1000;
	uint32_t wins = 0;
	uint32_t losses = 0;
	uint32_t draws = 0;
	int32_t winStreak = 0;
	int32_t bestStreak = 0;
	int64_t totalDamage = 0;
	int64_t totalHealing = 0;
	uint32_t totalKills = 0;
	uint32_t totalDeaths = 0;
	int32_t arenaPoints = 0;
};

struct ArenaPlayerMatchStats {
	uint32_t playerId = 0;
	uint8_t team = 0;
	uint16_t kills = 0;
	uint16_t deaths = 0;
	int64_t damageDealt = 0;
	int64_t healingDone = 0;
	int32_t mmrChange = 0;
};

struct ArenaQueueEntry {
	uint32_t playerId = 0;
	ArenaMode mode = ArenaMode::NONE;
	int32_t mmr = 1000;
	int64_t queuedAt = 0; // timestamp in seconds
	int32_t expandedRange = 0;
};

struct ArenaRankEntry {
	uint32_t playerId = 0;
	std::string playerName;
	int32_t mmr = 1000;
	uint32_t wins = 0;
	uint32_t losses = 0;
	int32_t winStreak = 0;
	int32_t bestStreak = 0;
};

struct ArenaMatchHistory {
	uint32_t matchId = 0;
	ArenaMode mode = ArenaMode::NONE;
	int64_t startedAt = 0;
	int32_t duration = 0;
	uint8_t winnerTeam = 0;
	uint16_t kills = 0;
	uint16_t deaths = 0;
	int64_t damageDealt = 0;
	int64_t healingDone = 0;
	int32_t mmrChange = 0;
	uint8_t playerTeam = 0;
};

// ============================================
// Helper functions
// ============================================

inline std::string arenaModeToString(ArenaMode mode) {
	switch (mode) {
		case ArenaMode::DUEL_1V1:
			return "1v1";
		case ArenaMode::TEAM_2V2:
			return "2v2";
		case ArenaMode::TEAM_3V3:
			return "3v3";
		case ArenaMode::FFA:
			return "ffa";
		case ArenaMode::CTF:
			return "ctf";
		case ArenaMode::KOTH:
			return "koth";
		case ArenaMode::LMS:
			return "lms";
		case ArenaMode::TOURNAMENT:
			return "tournament";
		default:
			return "none";
	}
}

inline ArenaMode stringToArenaMode(const std::string &str) {
	if (str == "1v1") {
		return ArenaMode::DUEL_1V1;
	}
	if (str == "2v2") {
		return ArenaMode::TEAM_2V2;
	}
	if (str == "3v3") {
		return ArenaMode::TEAM_3V3;
	}
	if (str == "ffa") {
		return ArenaMode::FFA;
	}
	if (str == "ctf") {
		return ArenaMode::CTF;
	}
	if (str == "koth") {
		return ArenaMode::KOTH;
	}
	if (str == "lms") {
		return ArenaMode::LMS;
	}
	if (str == "tournament") {
		return ArenaMode::TOURNAMENT;
	}
	return ArenaMode::NONE;
}

inline uint8_t getRequiredPlayers(ArenaMode mode) {
	switch (mode) {
		case ArenaMode::DUEL_1V1:
			return 2;
		case ArenaMode::TEAM_2V2:
			return 4;
		case ArenaMode::TEAM_3V3:
			return 6;
		case ArenaMode::FFA:
			return 4; // minimum
		case ArenaMode::CTF:
			return 6;
		case ArenaMode::KOTH:
			return 4;
		case ArenaMode::LMS:
			return 4; // minimum
		case ArenaMode::TOURNAMENT:
			return 8;
		default:
			return 0;
	}
}

inline int64_t getMatchDuration(ArenaMode mode) {
	switch (mode) {
		case ArenaMode::DUEL_1V1:
			return 5 * 60; // 5 min
		case ArenaMode::TEAM_2V2:
			return 7 * 60;
		case ArenaMode::TEAM_3V3:
			return 10 * 60;
		case ArenaMode::FFA:
			return 5 * 60;
		case ArenaMode::CTF:
			return 10 * 60;
		case ArenaMode::KOTH:
			return 8 * 60;
		case ArenaMode::LMS:
			return 15 * 60;
		case ArenaMode::TOURNAMENT:
			return 10 * 60;
		default:
			return 5 * 60;
	}
}
