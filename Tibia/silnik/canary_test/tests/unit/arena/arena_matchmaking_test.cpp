/**
 * @file arena_matchmaking_test.cpp
 * @brief Unit tests for ArenaMatchmaking queue and matching logic
 */

#include "pch.hpp"

#include <boost/ut.hpp>

#include "game/arena/arena_matchmaking.hpp"

using namespace boost::ut;

// ============================================
// Queue management tests
// ============================================

suite<"arena_matchmaking"> queueAddRemoveTest = [] {
	"addToQueue: basic add"_test = [] {
		ArenaMatchmaking mm;
		expect(mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000));
		expect(mm.isInQueue(1));
		expect(eq(1u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
	};

	"addToQueue: duplicate returns false"_test = [] {
		ArenaMatchmaking mm;
		expect(mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000));
		expect(!mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000));
		expect(!mm.addToQueue(1, ArenaMode::TEAM_2V2, 1000)); // same player, different mode
		expect(eq(1u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
	};

	"removeFromQueue: basic remove"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		expect(mm.removeFromQueue(1));
		expect(!mm.isInQueue(1));
		expect(eq(0u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
	};

	"removeFromQueue: non-existent returns false"_test = [] {
		ArenaMatchmaking mm;
		expect(!mm.removeFromQueue(999));
	};

	"isInQueue: returns false for non-queued player"_test = [] {
		ArenaMatchmaking mm;
		expect(!mm.isInQueue(1));
	};

	"getQueuedMode: returns correct mode"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::TEAM_2V2, 1200);
		expect(eq(ArenaMode::TEAM_2V2, mm.getQueuedMode(1)));
	};

	"getQueuedMode: returns NONE for non-queued"_test = [] {
		ArenaMatchmaking mm;
		expect(eq(ArenaMode::NONE, mm.getQueuedMode(999)));
	};

	"getQueueSize: empty queue returns 0"_test = [] {
		ArenaMatchmaking mm;
		expect(eq(0u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
		expect(eq(0u, mm.getQueueSize(ArenaMode::TEAM_3V3)));
	};

	"getQueueSize: multiple modes tracked independently"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::DUEL_1V1, 1050);
		mm.addToQueue(3, ArenaMode::TEAM_2V2, 1100);
		expect(eq(2u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
		expect(eq(1u, mm.getQueueSize(ArenaMode::TEAM_2V2)));
	};

	"clear: empties all queues"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::TEAM_2V2, 1050);
		mm.addToQueue(3, ArenaMode::FFA, 1100);
		mm.clear();
		expect(eq(0u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
		expect(eq(0u, mm.getQueueSize(ArenaMode::TEAM_2V2)));
		expect(eq(0u, mm.getQueueSize(ArenaMode::FFA)));
		expect(!mm.isInQueue(1));
		expect(!mm.isInQueue(2));
		expect(!mm.isInQueue(3));
	};
};

// ============================================
// Matchmaking tick - 1v1 tests
// ============================================

suite<"arena_matchmaking"> matchmaking1v1Test = [] {
	"tick: 1v1 no match with only 1 player"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		auto results = mm.tick();
		expect(results.empty());
		expect(mm.isInQueue(1)); // Still in queue
	};

	"tick: 1v1 match with 2 close MMR players"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::DUEL_1V1, 1050);
		auto results = mm.tick();
		expect(eq(1u, static_cast<uint32_t>(results.size())));
		if (!results.empty()) {
			expect(eq(ArenaMode::DUEL_1V1, results[0].mode));
			expect(eq(2u, static_cast<uint32_t>(results[0].players.size())));
		}
		// Players should be removed from queue
		expect(!mm.isInQueue(1));
		expect(!mm.isInQueue(2));
		expect(eq(0u, mm.getQueueSize(ArenaMode::DUEL_1V1)));
	};

	"tick: 1v1 no match if MMR too far apart (initial range)"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::DUEL_1V1, 1200); // 200 apart, initial range is 100
		auto results = mm.tick();
		// Should not match at initial range (0s waited = ±100)
		expect(results.empty());
		expect(mm.isInQueue(1));
		expect(mm.isInQueue(2));
	};
};

// ============================================
// Matchmaking tick - team mode tests
// ============================================

suite<"arena_matchmaking"> matchmakingTeamTest = [] {
	"tick: 2v2 needs 4 players"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::TEAM_2V2, 1000);
		mm.addToQueue(2, ArenaMode::TEAM_2V2, 1050);
		mm.addToQueue(3, ArenaMode::TEAM_2V2, 1030);
		auto results = mm.tick();
		// Only 3 players, need 4
		expect(results.empty());
	};

	"tick: 2v2 matches 4 close-MMR players"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::TEAM_2V2, 1000);
		mm.addToQueue(2, ArenaMode::TEAM_2V2, 1020);
		mm.addToQueue(3, ArenaMode::TEAM_2V2, 1040);
		mm.addToQueue(4, ArenaMode::TEAM_2V2, 1060);
		auto results = mm.tick();
		expect(eq(1u, static_cast<uint32_t>(results.size())));
		if (!results.empty()) {
			expect(eq(ArenaMode::TEAM_2V2, results[0].mode));
			expect(eq(4u, static_cast<uint32_t>(results[0].players.size())));
		}
	};

	"tick: 3v3 needs 6 players"_test = [] {
		ArenaMatchmaking mm;
		for (uint32_t i = 1; i <= 5; i++) {
			mm.addToQueue(i, ArenaMode::TEAM_3V3, 1000 + static_cast<int32_t>(i) * 10);
		}
		auto results = mm.tick();
		expect(results.empty()); // Only 5, need 6
	};

	"tick: 3v3 matches 6 close-MMR players"_test = [] {
		ArenaMatchmaking mm;
		for (uint32_t i = 1; i <= 6; i++) {
			mm.addToQueue(i, ArenaMode::TEAM_3V3, 1000 + static_cast<int32_t>(i) * 10);
		}
		auto results = mm.tick();
		expect(eq(1u, static_cast<uint32_t>(results.size())));
		if (!results.empty()) {
			expect(eq(ArenaMode::TEAM_3V3, results[0].mode));
			expect(eq(6u, static_cast<uint32_t>(results[0].players.size())));
		}
	};
};

// ============================================
// Matchmaking tick - FFA tests
// ============================================

suite<"arena_matchmaking"> matchmakingFFATest = [] {
	"tick: FFA needs at least 4 players"_test = [] {
		ArenaMatchmaking mm;
		for (uint32_t i = 1; i <= 3; i++) {
			mm.addToQueue(i, ArenaMode::FFA, 1000 + static_cast<int32_t>(i) * 10);
		}
		auto results = mm.tick();
		expect(results.empty());
	};

	"tick: FFA matches 4+ close-MMR players"_test = [] {
		ArenaMatchmaking mm;
		for (uint32_t i = 1; i <= 5; i++) {
			mm.addToQueue(i, ArenaMode::FFA, 1000 + static_cast<int32_t>(i) * 10);
		}
		auto results = mm.tick();
		expect(eq(1u, static_cast<uint32_t>(results.size())));
		if (!results.empty()) {
			expect(eq(ArenaMode::FFA, results[0].mode));
			auto numPlayers = static_cast<uint32_t>(results[0].players.size());
			expect(numPlayers >= 4u) << "FFA should have at least 4 players, got " << numPlayers;
		}
	};
};

// ============================================
// Cross-mode isolation tests
// ============================================

suite<"arena_matchmaking"> crossModeIsolationTest = [] {
	"tick: different modes don't mix"_test = [] {
		ArenaMatchmaking mm;
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::TEAM_2V2, 1010);
		auto results = mm.tick();
		// 1v1 has 1 player, 2v2 has 1 player — no match possible
		expect(results.empty());
		expect(mm.isInQueue(1));
		expect(mm.isInQueue(2));
	};
};

// ============================================
// Multiple match groups per tick
// ============================================

suite<"arena_matchmaking"> multipleMatchesTest = [] {
	"tick: can produce matches from different modes"_test = [] {
		ArenaMatchmaking mm;
		// 2 players for 1v1
		mm.addToQueue(1, ArenaMode::DUEL_1V1, 1000);
		mm.addToQueue(2, ArenaMode::DUEL_1V1, 1050);
		// 4 players for 2v2
		mm.addToQueue(10, ArenaMode::TEAM_2V2, 1000);
		mm.addToQueue(11, ArenaMode::TEAM_2V2, 1020);
		mm.addToQueue(12, ArenaMode::TEAM_2V2, 1040);
		mm.addToQueue(13, ArenaMode::TEAM_2V2, 1060);
		auto results = mm.tick();
		expect(eq(2u, static_cast<uint32_t>(results.size())));
	};
};
