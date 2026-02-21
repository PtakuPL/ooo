/**
 * @file arena_match.cpp
 * @brief Arena PvP system - single match implementation
 */

#include "game/arena/arena_match.hpp"

#include "lib/logging/logger.hpp"
#include "utils/tools.hpp"

#include <algorithm>
#include <ctime>

ArenaMatch::ArenaMatch(uint32_t id, ArenaMode mode, uint32_t mapId) :
	matchId(id), mode(mode), mapId(mapId) {
	maxDuration = getMatchDuration(mode);
}

// ============================================
// Player management
// ============================================

void ArenaMatch::addPlayer(uint32_t playerId, uint8_t team) {
	ArenaPlayerMatchStats stats;
	stats.playerId = playerId;
	stats.team = team;
	players[playerId] = stats;
}

void ArenaMatch::removePlayer(uint32_t playerId) {
	players.erase(playerId);
}

bool ArenaMatch::hasPlayer(uint32_t playerId) const {
	return players.contains(playerId);
}

uint8_t ArenaMatch::getPlayerTeam(uint32_t playerId) const {
	auto it = players.find(playerId);
	if (it != players.end()) {
		return it->second.team;
	}
	return 0;
}

std::vector<uint32_t> ArenaMatch::getTeamPlayerIds(uint8_t team) const {
	std::vector<uint32_t> ids;
	for (const auto &[playerId, stats] : players) {
		if (stats.team == team) {
			ids.push_back(playerId);
		}
	}
	return ids;
}

std::vector<uint32_t> ArenaMatch::getAllPlayerIds() const {
	std::vector<uint32_t> ids;
	ids.reserve(players.size());
	for (const auto &[playerId, _] : players) {
		ids.push_back(playerId);
	}
	return ids;
}

uint32_t ArenaMatch::getAliveCount(uint8_t team) const {
	uint32_t count = 0;
	for (const auto &[playerId, stats] : players) {
		if (stats.team == team && !isPlayerDead(playerId)) {
			count++;
		}
	}
	return count;
}

// ============================================
// Match lifecycle
// ============================================

void ArenaMatch::setState(ArenaMatchState newState) {
	state = newState;
}

void ArenaMatch::setStartTime(int64_t time) {
	startTime = time;
}

void ArenaMatch::start() {
	state = ArenaMatchState::IN_PROGRESS;
	startTime = std::time(nullptr);
	deadPlayers.clear();
	g_logger().info("[Arena] Match {} started (mode: {})", matchId, arenaModeToString(mode));
}

void ArenaMatch::finish(uint8_t winner) {
	state = ArenaMatchState::FINISHED;
	winnerTeam = winner;
	g_logger().info("[Arena] Match {} finished (winner team: {})", matchId, winner);
}

// ============================================
// Combat events
// ============================================

void ArenaMatch::onKill(uint32_t killerId, uint32_t victimId) {
	if (auto it = players.find(killerId); it != players.end()) {
		it->second.kills++;
	}
	if (auto it = players.find(victimId); it != players.end()) {
		it->second.deaths++;
	}
}

void ArenaMatch::onDamage(uint32_t attackerId, int64_t damage) {
	if (auto it = players.find(attackerId); it != players.end()) {
		it->second.damageDealt += damage;
	}
}

void ArenaMatch::onHeal(uint32_t healerId, int64_t amount) {
	if (auto it = players.find(healerId); it != players.end()) {
		it->second.healingDone += amount;
	}
}

void ArenaMatch::onPlayerDeath(uint32_t playerId) {
	markPlayerDead(playerId);
}

// ============================================
// Win condition
// ============================================

bool ArenaMatch::checkWinCondition() {
	if (state != ArenaMatchState::IN_PROGRESS) {
		return false;
	}

	switch (mode) {
		case ArenaMode::DUEL_1V1: {
			// One player dead = other wins
			auto team1Alive = getAliveCount(1);
			auto team2Alive = getAliveCount(2);
			if (team1Alive == 0) {
				finish(2);
				return true;
			}
			if (team2Alive == 0) {
				finish(1);
				return true;
			}
			break;
		}

		case ArenaMode::TEAM_2V2:
		case ArenaMode::TEAM_3V3: {
			// All players on one team dead
			auto team1Alive = getAliveCount(1);
			auto team2Alive = getAliveCount(2);
			if (team1Alive == 0 && team2Alive > 0) {
				finish(2);
				return true;
			}
			if (team2Alive == 0 && team1Alive > 0) {
				finish(1);
				return true;
			}
			break;
		}

		case ArenaMode::FFA:
		case ArenaMode::LMS: {
			// Last player alive wins
			uint32_t aliveCount = 0;
			uint32_t lastAliveId = 0;
			for (const auto &[playerId, _] : players) {
				if (!isPlayerDead(playerId)) {
					aliveCount++;
					lastAliveId = playerId;
				}
			}
			if (aliveCount <= 1 && !players.empty()) {
				// Winner is the last alive player's team (which is their own ID in FFA)
				auto it = players.find(lastAliveId);
				finish(it != players.end() ? it->second.team : 0);
				return true;
			}
			break;
		}

		default:
			break;
	}

	// Time up check
	if (isTimeUp()) {
		// Team with more kills wins; in FFA, player with most kills
		if (mode == ArenaMode::FFA || mode == ArenaMode::LMS) {
			uint32_t bestId = 0;
			uint16_t bestKills = 0;
			for (const auto &[playerId, stats] : players) {
				if (stats.kills > bestKills) {
					bestKills = stats.kills;
					bestId = playerId;
					// In FFA each player is their own team
				}
			}
			auto it = players.find(bestId);
			finish(it != players.end() ? it->second.team : 0);
		} else {
			auto team1Kills = getTeamKills(1);
			auto team2Kills = getTeamKills(2);
			if (team1Kills > team2Kills) {
				finish(1);
			} else if (team2Kills > team1Kills) {
				finish(2);
			} else {
				finish(0); // Draw
			}
		}
		return true;
	}

	return false;
}

int64_t ArenaMatch::getRemainingTime() const {
	if (startTime == 0) {
		return maxDuration;
	}
	int64_t elapsed = std::time(nullptr) - startTime;
	int64_t remaining = maxDuration - elapsed;
	return remaining > 0 ? remaining : 0;
}

bool ArenaMatch::isTimeUp() const {
	return startTime > 0 && getRemainingTime() <= 0;
}

// ============================================
// Score
// ============================================

uint16_t ArenaMatch::getTeamKills(uint8_t team) const {
	uint16_t total = 0;
	for (const auto &[_, stats] : players) {
		if (stats.team == team) {
			total += stats.kills;
		}
	}
	return total;
}

ArenaPlayerMatchStats* ArenaMatch::getPlayerStats(uint32_t playerId) {
	auto it = players.find(playerId);
	if (it != players.end()) {
		return &it->second;
	}
	return nullptr;
}

// ============================================
// Spawn positions
// ============================================

void ArenaMatch::setSpawnPositions(uint8_t team, const std::vector<Position> &positions) {
	spawnPositions[team] = positions;
}

Position ArenaMatch::getSpawnPosition(uint32_t playerId) const {
	auto playerIt = players.find(playerId);
	if (playerIt == players.end()) {
		return exitPosition;
	}

	uint8_t team = playerIt->second.team;
	auto spawnIt = spawnPositions.find(team);
	if (spawnIt == spawnPositions.end() || spawnIt->second.empty()) {
		return exitPosition;
	}

	// Find player's index within their team
	uint32_t index = 0;
	for (const auto &[pid, stats] : players) {
		if (stats.team == team) {
			if (pid == playerId) {
				break;
			}
			index++;
		}
	}

	// Wrap around if more players than spawn points
	return spawnIt->second[index % spawnIt->second.size()];
}

void ArenaMatch::setExitPosition(const Position &pos) {
	exitPosition = pos;
}

// ============================================
// Dead players tracking
// ============================================

void ArenaMatch::markPlayerDead(uint32_t playerId) {
	if (!isPlayerDead(playerId)) {
		deadPlayers.push_back(playerId);
	}
}

void ArenaMatch::markPlayerAlive(uint32_t playerId) {
	auto it = std::find(deadPlayers.begin(), deadPlayers.end(), playerId);
	if (it != deadPlayers.end()) {
		deadPlayers.erase(it);
	}
}

bool ArenaMatch::isPlayerDead(uint32_t playerId) const {
	return std::find(deadPlayers.begin(), deadPlayers.end(), playerId) != deadPlayers.end();
}

// ============================================
// Convenience accessors for protocol layer
// ============================================

int64_t ArenaMatch::getElapsedSeconds() const {
	if (startTime == 0) {
		return 0;
	}
	return static_cast<int64_t>(std::time(nullptr)) - startTime;
}

std::map<uint8_t, uint16_t> ArenaMatch::getTeamScores() const {
	std::map<uint8_t, uint16_t> scores;
	for (const auto &[pid, pstats] : players) {
		scores[pstats.team] += pstats.kills;
	}
	return scores;
}

std::string ArenaMatch::getPlayerName(uint32_t playerId) const {
	// Lookup from game's player list (online players)
	// If offline, return empty string - the caller should handle it
	(void)playerId;
	return ""; // Will be resolved by protocol layer using g_game().getPlayerByGUID()
}
