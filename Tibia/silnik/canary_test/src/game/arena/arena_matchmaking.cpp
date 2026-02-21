/**
 * @file arena_matchmaking.cpp
 * @brief Arena PvP system - matchmaking implementation
 */

#include "game/arena/arena_matchmaking.hpp"

#include "lib/logging/logger.hpp"

#include <algorithm>
#include <ctime>

// ============================================
// Queue management
// ============================================

bool ArenaMatchmaking::addToQueue(uint32_t playerId, ArenaMode mode, int32_t mmr) {
	// Already in queue?
	if (isInQueue(playerId)) {
		return false;
	}

	ArenaQueueEntry entry;
	entry.playerId = playerId;
	entry.mode = mode;
	entry.mmr = mmr;
	entry.queuedAt = std::time(nullptr);
	entry.expandedRange = 0;

	queues[mode].push_back(entry);
	playerQueue[playerId] = mode;

	g_logger().info("[Arena] Player {} joined queue for {} (MMR: {})", playerId, arenaModeToString(mode), mmr);
	return true;
}

bool ArenaMatchmaking::removeFromQueue(uint32_t playerId) {
	auto modeIt = playerQueue.find(playerId);
	if (modeIt == playerQueue.end()) {
		return false;
	}

	ArenaMode mode = modeIt->second;
	auto &queue = queues[mode];

	auto it = std::find_if(queue.begin(), queue.end(), [playerId](const ArenaQueueEntry &e) {
		return e.playerId == playerId;
	});

	if (it != queue.end()) {
		queue.erase(it);
	}

	playerQueue.erase(modeIt);
	g_logger().info("[Arena] Player {} left queue", playerId);
	return true;
}

bool ArenaMatchmaking::isInQueue(uint32_t playerId) const {
	return playerQueue.contains(playerId);
}

ArenaMode ArenaMatchmaking::getQueuedMode(uint32_t playerId) const {
	auto it = playerQueue.find(playerId);
	if (it != playerQueue.end()) {
		return it->second;
	}
	return ArenaMode::NONE;
}

uint32_t ArenaMatchmaking::getQueueSize(ArenaMode mode) const {
	auto it = queues.find(mode);
	if (it != queues.end()) {
		return static_cast<uint32_t>(it->second.size());
	}
	return 0;
}

// ============================================
// Matchmaking tick
// ============================================

std::vector<ArenaMatchmaking::MatchGroup> ArenaMatchmaking::tick() {
	std::vector<MatchGroup> results;

	for (auto &[mode, queue] : queues) {
		if (queue.empty()) {
			continue;
		}

		// Expand ranges for entries that waited
		expandRanges(queue);

		// Try to form matches
		tryMatchMode(mode, queue, results);
	}

	return results;
}

void ArenaMatchmaking::clear() {
	queues.clear();
	playerQueue.clear();
}

// ============================================
// Internal matching logic
// ============================================

bool ArenaMatchmaking::tryMatchMode(ArenaMode mode, std::vector<ArenaQueueEntry> &queue, std::vector<MatchGroup> &results) {
	uint8_t required = getRequiredPlayers(mode);
	if (queue.size() < required) {
		return false;
	}

	// Sort by MMR for better matching
	std::sort(queue.begin(), queue.end(), [](const ArenaQueueEntry &a, const ArenaQueueEntry &b) {
		return a.mmr < b.mmr;
	});

	bool matched = false;

	switch (mode) {
		case ArenaMode::DUEL_1V1: {
			// Find the best pair (closest MMR that can match)
			for (size_t i = 0; i + 1 < queue.size(); i++) {
				if (canMatch(queue[i], queue[i + 1])) {
					MatchGroup group;
					group.mode = mode;
					group.players.push_back(queue[i]);
					group.players.push_back(queue[i + 1]);
					results.push_back(group);

					// Remove matched players from playerQueue lookup
					playerQueue.erase(queue[i].playerId);
					playerQueue.erase(queue[i + 1].playerId);

					// Remove from queue (erase back-to-front)
					queue.erase(queue.begin() + static_cast<long>(i + 1));
					queue.erase(queue.begin() + static_cast<long>(i));

					matched = true;
					break; // One match per tick per mode to avoid index issues
				}
			}
			break;
		}

		case ArenaMode::TEAM_2V2:
		case ArenaMode::TEAM_3V3: {
			// Need 'required' players with compatible MMR
			// Find a group where all can match each other
			if (queue.size() >= required) {
				// Take the first 'required' players sorted by MMR — they're the closest group
				bool allMatch = true;
				for (size_t i = 0; i < required && allMatch; i++) {
					for (size_t j = i + 1; j < required && allMatch; j++) {
						if (!canMatch(queue[i], queue[j])) {
							allMatch = false;
						}
					}
				}

				if (allMatch) {
					MatchGroup group;
					group.mode = mode;
					for (size_t i = 0; i < required; i++) {
						group.players.push_back(queue[i]);
						playerQueue.erase(queue[i].playerId);
					}
					results.push_back(group);

					// Remove matched players from queue
					queue.erase(queue.begin(), queue.begin() + static_cast<long>(required));
					matched = true;
				}
			}
			break;
		}

		case ArenaMode::FFA:
		case ArenaMode::LMS: {
			// Need at least 'required' players, take up to 8
			uint8_t maxPlayers = 8;
			uint8_t minPlayers = required;

			if (queue.size() >= minPlayers) {
				uint8_t count = std::min(static_cast<uint8_t>(queue.size()), maxPlayers);

				// Check if first 'count' players can all match
				bool allMatch = true;
				for (size_t i = 0; i < count && allMatch; i++) {
					for (size_t j = i + 1; j < count && allMatch; j++) {
						if (!canMatch(queue[i], queue[j])) {
							// Reduce count to just before the mismatch
							count = static_cast<uint8_t>(i > 0 ? i : 0);
							allMatch = (count >= minPlayers);
						}
					}
				}

				if (allMatch && count >= minPlayers) {
					MatchGroup group;
					group.mode = mode;
					for (size_t i = 0; i < count; i++) {
						group.players.push_back(queue[i]);
						playerQueue.erase(queue[i].playerId);
					}
					results.push_back(group);
					queue.erase(queue.begin(), queue.begin() + count);
					matched = true;
				}
			}
			break;
		}

		default:
			break;
	}

	return matched;
}

bool ArenaMatchmaking::canMatch(const ArenaQueueEntry &a, const ArenaQueueEntry &b) const {
	int32_t rangeA = getSearchRange(a);
	int32_t rangeB = getSearchRange(b);
	int32_t range = std::max(rangeA, rangeB);
	int32_t diff = std::abs(a.mmr - b.mmr);
	return diff <= range;
}

int32_t ArenaMatchmaking::getSearchRange(const ArenaQueueEntry &entry) const {
	int64_t now = std::time(nullptr);
	int64_t waited = now - entry.queuedAt;

	// Progressive range expansion:
	// 0-30s:   ±100
	// 30-60s:  ±200
	// 60-120s: ±500
	// 120s+:   ±9999 (match anyone)
	if (waited < 30) {
		return 100;
	}
	if (waited < 60) {
		return 200;
	}
	if (waited < 120) {
		return 500;
	}
	return 9999;
}

void ArenaMatchmaking::expandRanges(std::vector<ArenaQueueEntry> &queue) {
	int64_t now = std::time(nullptr);
	for (auto &entry : queue) {
		int64_t waited = now - entry.queuedAt;
		if (waited >= 120) {
			entry.expandedRange = 3;
		} else if (waited >= 60) {
			entry.expandedRange = 2;
		} else if (waited >= 30) {
			entry.expandedRange = 1;
		}
	}
}
