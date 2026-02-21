/**
 * @file arena_matchmaking.hpp
 * @brief Arena PvP system - matchmaking algorithm
 */

#pragma once

#include "game/arena/arena_definitions.hpp"

#include <cstdint>
#include <map>
#include <mutex>
#include <vector>

class ArenaMatchmaking {
public:
	ArenaMatchmaking() = default;

	// Queue management
	bool addToQueue(uint32_t playerId, ArenaMode mode, int32_t mmr);
	bool removeFromQueue(uint32_t playerId);
	bool isInQueue(uint32_t playerId) const;
	ArenaMode getQueuedMode(uint32_t playerId) const;
	uint32_t getQueueSize(ArenaMode mode) const;

	// Matchmaking tick — returns matched groups ready for a match
	struct MatchGroup {
		ArenaMode mode;
		std::vector<ArenaQueueEntry> players;
	};
	std::vector<MatchGroup> tick();

	// Clear all queues (server restart)
	void clear();

private:
	// Try to find a match in a specific mode's queue
	bool tryMatchMode(ArenaMode mode, std::vector<ArenaQueueEntry> &queue, std::vector<MatchGroup> &results);

	// Check if two entries can be matched (MMR within expanded range)
	bool canMatch(const ArenaQueueEntry &a, const ArenaQueueEntry &b) const;

	// Get current MMR search range based on time in queue
	int32_t getSearchRange(const ArenaQueueEntry &entry) const;

	// Expand ranges for entries that have been waiting
	void expandRanges(std::vector<ArenaQueueEntry> &queue);

	// All queues by mode
	std::map<ArenaMode, std::vector<ArenaQueueEntry>> queues;

	// Quick lookup: playerId -> mode
	std::map<uint32_t, ArenaMode> playerQueue;
};
