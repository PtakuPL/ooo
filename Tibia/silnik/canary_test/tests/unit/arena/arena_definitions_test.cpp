/**
 * @file arena_definitions_test.cpp
 * @brief Unit tests for arena definitions helpers
 */

#include "pch.hpp"

#include <boost/ut.hpp>

#include "game/arena/arena_definitions.hpp"

using namespace boost::ut;

// ============================================
// arenaModeToString tests
// ============================================

suite<"arena_definitions"> arenaModeToStringTest = [] {
	"arenaModeToString: 1v1"_test = [] {
		expect(eq(std::string("1v1"), arenaModeToString(ArenaMode::DUEL_1V1)));
	};

	"arenaModeToString: 2v2"_test = [] {
		expect(eq(std::string("2v2"), arenaModeToString(ArenaMode::TEAM_2V2)));
	};

	"arenaModeToString: 3v3"_test = [] {
		expect(eq(std::string("3v3"), arenaModeToString(ArenaMode::TEAM_3V3)));
	};

	"arenaModeToString: ffa"_test = [] {
		expect(eq(std::string("ffa"), arenaModeToString(ArenaMode::FFA)));
	};

	"arenaModeToString: ctf"_test = [] {
		expect(eq(std::string("ctf"), arenaModeToString(ArenaMode::CTF)));
	};

	"arenaModeToString: koth"_test = [] {
		expect(eq(std::string("koth"), arenaModeToString(ArenaMode::KOTH)));
	};

	"arenaModeToString: lms"_test = [] {
		expect(eq(std::string("lms"), arenaModeToString(ArenaMode::LMS)));
	};

	"arenaModeToString: tournament"_test = [] {
		expect(eq(std::string("tournament"), arenaModeToString(ArenaMode::TOURNAMENT)));
	};

	"arenaModeToString: NONE"_test = [] {
		expect(eq(std::string("none"), arenaModeToString(ArenaMode::NONE)));
	};
};

// ============================================
// stringToArenaMode tests
// ============================================

suite<"arena_definitions"> stringToArenaModeTest = [] {
	"stringToArenaMode: 1v1"_test = [] {
		expect(eq(ArenaMode::DUEL_1V1, stringToArenaMode("1v1")));
	};

	"stringToArenaMode: 2v2"_test = [] {
		expect(eq(ArenaMode::TEAM_2V2, stringToArenaMode("2v2")));
	};

	"stringToArenaMode: 3v3"_test = [] {
		expect(eq(ArenaMode::TEAM_3V3, stringToArenaMode("3v3")));
	};

	"stringToArenaMode: ffa"_test = [] {
		expect(eq(ArenaMode::FFA, stringToArenaMode("ffa")));
	};

	"stringToArenaMode: ctf"_test = [] {
		expect(eq(ArenaMode::CTF, stringToArenaMode("ctf")));
	};

	"stringToArenaMode: koth"_test = [] {
		expect(eq(ArenaMode::KOTH, stringToArenaMode("koth")));
	};

	"stringToArenaMode: lms"_test = [] {
		expect(eq(ArenaMode::LMS, stringToArenaMode("lms")));
	};

	"stringToArenaMode: tournament"_test = [] {
		expect(eq(ArenaMode::TOURNAMENT, stringToArenaMode("tournament")));
	};

	"stringToArenaMode: invalid returns NONE"_test = [] {
		expect(eq(ArenaMode::NONE, stringToArenaMode("invalid")));
		expect(eq(ArenaMode::NONE, stringToArenaMode("")));
		expect(eq(ArenaMode::NONE, stringToArenaMode("1V1"))); // case sensitive
	};

	"stringToArenaMode: roundtrip"_test = [] {
		for (uint8_t i = 0; i <= 8; i++) {
			auto mode = static_cast<ArenaMode>(i);
			auto str = arenaModeToString(mode);
			auto back = stringToArenaMode(str);
			expect(eq(mode, back)) << "Roundtrip failed for mode " << static_cast<int>(i);
		}
	};
};

// ============================================
// getRequiredPlayers tests
// ============================================

suite<"arena_definitions"> getRequiredPlayersTest = [] {
	"getRequiredPlayers: 1v1 needs 2"_test = [] {
		expect(eq(static_cast<uint8_t>(2), getRequiredPlayers(ArenaMode::DUEL_1V1)));
	};

	"getRequiredPlayers: 2v2 needs 4"_test = [] {
		expect(eq(static_cast<uint8_t>(4), getRequiredPlayers(ArenaMode::TEAM_2V2)));
	};

	"getRequiredPlayers: 3v3 needs 6"_test = [] {
		expect(eq(static_cast<uint8_t>(6), getRequiredPlayers(ArenaMode::TEAM_3V3)));
	};

	"getRequiredPlayers: FFA needs 4"_test = [] {
		expect(eq(static_cast<uint8_t>(4), getRequiredPlayers(ArenaMode::FFA)));
	};

	"getRequiredPlayers: CTF needs 6"_test = [] {
		expect(eq(static_cast<uint8_t>(6), getRequiredPlayers(ArenaMode::CTF)));
	};

	"getRequiredPlayers: KOTH needs 4"_test = [] {
		expect(eq(static_cast<uint8_t>(4), getRequiredPlayers(ArenaMode::KOTH)));
	};

	"getRequiredPlayers: LMS needs 4"_test = [] {
		expect(eq(static_cast<uint8_t>(4), getRequiredPlayers(ArenaMode::LMS)));
	};

	"getRequiredPlayers: Tournament needs 8"_test = [] {
		expect(eq(static_cast<uint8_t>(8), getRequiredPlayers(ArenaMode::TOURNAMENT)));
	};

	"getRequiredPlayers: NONE returns 0"_test = [] {
		expect(eq(static_cast<uint8_t>(0), getRequiredPlayers(ArenaMode::NONE)));
	};
};

// ============================================
// getMatchDuration tests
// ============================================

suite<"arena_definitions"> getMatchDurationTest = [] {
	"getMatchDuration: 1v1 is 5 min"_test = [] {
		expect(eq(static_cast<int64_t>(5 * 60), getMatchDuration(ArenaMode::DUEL_1V1)));
	};

	"getMatchDuration: 2v2 is 7 min"_test = [] {
		expect(eq(static_cast<int64_t>(7 * 60), getMatchDuration(ArenaMode::TEAM_2V2)));
	};

	"getMatchDuration: 3v3 is 10 min"_test = [] {
		expect(eq(static_cast<int64_t>(10 * 60), getMatchDuration(ArenaMode::TEAM_3V3)));
	};

	"getMatchDuration: FFA is 5 min"_test = [] {
		expect(eq(static_cast<int64_t>(5 * 60), getMatchDuration(ArenaMode::FFA)));
	};

	"getMatchDuration: CTF is 10 min"_test = [] {
		expect(eq(static_cast<int64_t>(10 * 60), getMatchDuration(ArenaMode::CTF)));
	};

	"getMatchDuration: KOTH is 8 min"_test = [] {
		expect(eq(static_cast<int64_t>(8 * 60), getMatchDuration(ArenaMode::KOTH)));
	};

	"getMatchDuration: LMS is 15 min"_test = [] {
		expect(eq(static_cast<int64_t>(15 * 60), getMatchDuration(ArenaMode::LMS)));
	};

	"getMatchDuration: Tournament is 10 min"_test = [] {
		expect(eq(static_cast<int64_t>(10 * 60), getMatchDuration(ArenaMode::TOURNAMENT)));
	};

	"getMatchDuration: NONE defaults to 5 min"_test = [] {
		expect(eq(static_cast<int64_t>(5 * 60), getMatchDuration(ArenaMode::NONE)));
	};
};

// ============================================
// ArenaPlayerStats default values tests
// ============================================

suite<"arena_definitions"> arenaPlayerStatsDefaultsTest = [] {
	"ArenaPlayerStats: defaults"_test = [] {
		ArenaPlayerStats stats;
		expect(eq(0u, stats.playerId));
		expect(eq(1000, stats.mmr));
		expect(eq(0u, stats.wins));
		expect(eq(0u, stats.losses));
		expect(eq(0u, stats.draws));
		expect(eq(0, stats.winStreak));
		expect(eq(0, stats.bestStreak));
		expect(eq(static_cast<int64_t>(0), stats.totalDamage));
		expect(eq(static_cast<int64_t>(0), stats.totalHealing));
		expect(eq(0u, stats.totalKills));
		expect(eq(0u, stats.totalDeaths));
		expect(eq(0, stats.arenaPoints));
	};
};

// ============================================
// ArenaQueueEntry default values tests
// ============================================

suite<"arena_definitions"> arenaQueueEntryDefaultsTest = [] {
	"ArenaQueueEntry: defaults"_test = [] {
		ArenaQueueEntry entry;
		expect(eq(0u, entry.playerId));
		expect(eq(ArenaMode::NONE, entry.mode));
		expect(eq(1000, entry.mmr));
		expect(eq(static_cast<int64_t>(0), entry.queuedAt));
		expect(eq(0, entry.expandedRange));
	};
};
