/**
 * @file ioarena.cpp
 * @brief Arena PvP system - database I/O implementation
 */

#include "io/ioarena.hpp"

#include "database/database.hpp"
#include "lib/logging/logger.hpp"

ArenaPlayerStats IOArena::getPlayerStats(uint32_t playerId) {
	ArenaPlayerStats stats;
	stats.playerId = playerId;

	auto query = fmt::format(
		"SELECT `mmr`, `wins`, `losses`, `draws`, `win_streak`, `best_streak`, "
		"`total_damage`, `total_healing`, `total_kills`, `total_deaths`, `arena_points` "
		"FROM `arena_players` WHERE `player_id` = {}",
		playerId
	);

	DBResult_ptr result = g_database().storeQuery(query);
	if (!result) {
		return stats;
	}

	stats.mmr = result->getNumber<int32_t>("mmr");
	stats.wins = result->getNumber<uint32_t>("wins");
	stats.losses = result->getNumber<uint32_t>("losses");
	stats.draws = result->getNumber<uint32_t>("draws");
	stats.winStreak = result->getNumber<int32_t>("win_streak");
	stats.bestStreak = result->getNumber<int32_t>("best_streak");
	stats.totalDamage = result->getNumber<int64_t>("total_damage");
	stats.totalHealing = result->getNumber<int64_t>("total_healing");
	stats.totalKills = result->getNumber<uint32_t>("total_kills");
	stats.totalDeaths = result->getNumber<uint32_t>("total_deaths");
	stats.arenaPoints = result->getNumber<int32_t>("arena_points");
	return stats;
}

bool IOArena::createPlayerEntry(uint32_t playerId) {
	auto query = fmt::format(
		"INSERT IGNORE INTO `arena_players` (`player_id`) VALUES ({})",
		playerId
	);
	return g_database().executeQuery(query);
}

bool IOArena::updatePlayerStats(uint32_t playerId, const ArenaPlayerStats &stats) {
	auto query = fmt::format(
		"UPDATE `arena_players` SET `mmr` = {}, `wins` = {}, `losses` = {}, `draws` = {}, "
		"`win_streak` = {}, `best_streak` = {}, `total_damage` = {}, `total_healing` = {}, "
		"`total_kills` = {}, `total_deaths` = {}, `arena_points` = {}, `last_match` = NOW() "
		"WHERE `player_id` = {}",
		stats.mmr, stats.wins, stats.losses, stats.draws,
		stats.winStreak, stats.bestStreak, stats.totalDamage, stats.totalHealing,
		stats.totalKills, stats.totalDeaths, stats.arenaPoints,
		playerId
	);
	return g_database().executeQuery(query);
}

bool IOArena::addArenaPoints(uint32_t playerId, int32_t points) {
	auto query = fmt::format(
		"UPDATE `arena_players` SET `arena_points` = `arena_points` + {} WHERE `player_id` = {}",
		points, playerId
	);
	return g_database().executeQuery(query);
}

uint32_t IOArena::createMatch(ArenaMode mode, uint32_t mapId, uint32_t seasonId) {
	auto query = fmt::format(
		"INSERT INTO `arena_matches` (`mode`, `map_id`, `started_at`, `season_id`) "
		"VALUES ('{}', {}, NOW(), {})",
		arenaModeToString(mode), mapId, seasonId
	);

	if (!g_database().executeQuery(query)) {
		return 0;
	}

	DBResult_ptr result = g_database().storeQuery("SELECT LAST_INSERT_ID() AS `id`");
	if (!result) {
		return 0;
	}
	return result->getNumber<uint32_t>("id");
}

bool IOArena::finishMatch(uint32_t matchId, int32_t duration, uint8_t winnerTeam) {
	auto query = fmt::format(
		"UPDATE `arena_matches` SET `ended_at` = NOW(), `duration` = {}, `winner_team` = {} "
		"WHERE `id` = {}",
		duration, winnerTeam, matchId
	);
	return g_database().executeQuery(query);
}

bool IOArena::saveMatchPlayer(uint32_t matchId, const ArenaPlayerMatchStats &stats) {
	auto query = fmt::format(
		"INSERT INTO `arena_match_players` (`match_id`, `player_id`, `team`, `kills`, "
		"`deaths`, `damage_dealt`, `healing_done`, `mmr_change`) "
		"VALUES ({}, {}, {}, {}, {}, {}, {}, {})",
		matchId, stats.playerId, stats.team, stats.kills,
		stats.deaths, stats.damageDealt, stats.healingDone, stats.mmrChange
	);
	return g_database().executeQuery(query);
}

bool IOArena::addToQueue(uint32_t playerId, ArenaMode mode, int32_t mmr) {
	auto query = fmt::format(
		"INSERT INTO `arena_queue` (`player_id`, `mode`, `mmr`) VALUES ({}, '{}', {}) "
		"ON DUPLICATE KEY UPDATE `mode` = '{}', `mmr` = {}, `queued_at` = NOW(), `expanded_range` = 0",
		playerId, arenaModeToString(mode), mmr,
		arenaModeToString(mode), mmr
	);
	return g_database().executeQuery(query);
}

bool IOArena::removeFromQueue(uint32_t playerId) {
	auto query = fmt::format(
		"DELETE FROM `arena_queue` WHERE `player_id` = {}",
		playerId
	);
	return g_database().executeQuery(query);
}

void IOArena::clearQueue() {
	g_database().executeQuery("TRUNCATE TABLE `arena_queue`");
}

std::vector<ArenaRankEntry> IOArena::getTopRanking(uint32_t limit, uint32_t offset) {
	std::vector<ArenaRankEntry> entries;

	auto query = fmt::format(
		"SELECT ap.`player_id`, p.`name`, ap.`mmr`, ap.`wins`, ap.`losses`, "
		"ap.`win_streak`, ap.`best_streak` "
		"FROM `arena_players` ap "
		"JOIN `players` p ON ap.`player_id` = p.`id` "
		"ORDER BY ap.`mmr` DESC "
		"LIMIT {} OFFSET {}",
		limit, offset
	);

	DBResult_ptr result = g_database().storeQuery(query);
	if (!result) {
		return entries;
	}

	do {
		ArenaRankEntry entry;
		entry.playerId = result->getNumber<uint32_t>("player_id");
		entry.playerName = result->getString("name");
		entry.mmr = result->getNumber<int32_t>("mmr");
		entry.wins = result->getNumber<uint32_t>("wins");
		entry.losses = result->getNumber<uint32_t>("losses");
		entry.winStreak = result->getNumber<int32_t>("win_streak");
		entry.bestStreak = result->getNumber<int32_t>("best_streak");
		entries.push_back(entry);
	} while (result->next());

	return entries;
}

std::vector<ArenaMatchHistory> IOArena::getPlayerMatchHistory(uint32_t playerId, uint32_t limit) {
	std::vector<ArenaMatchHistory> history;

	auto query = fmt::format(
		"SELECT m.`id`, m.`mode`, UNIX_TIMESTAMP(m.`started_at`) AS `started_ts`, "
		"m.`duration`, m.`winner_team`, mp.`team`, mp.`kills`, mp.`deaths`, "
		"mp.`damage_dealt`, mp.`healing_done`, mp.`mmr_change` "
		"FROM `arena_match_players` mp "
		"JOIN `arena_matches` m ON mp.`match_id` = m.`id` "
		"WHERE mp.`player_id` = {} "
		"ORDER BY m.`started_at` DESC LIMIT {}",
		playerId, limit
	);

	DBResult_ptr result = g_database().storeQuery(query);
	if (!result) {
		return history;
	}

	do {
		ArenaMatchHistory entry;
		entry.matchId = result->getNumber<uint32_t>("id");
		entry.mode = stringToArenaMode(result->getString("mode"));
		entry.startedAt = result->getNumber<int64_t>("started_ts");
		entry.duration = result->getNumber<int32_t>("duration");
		entry.winnerTeam = result->getNumber<uint8_t>("winner_team");
		entry.playerTeam = result->getNumber<uint8_t>("team");
		entry.kills = result->getNumber<uint16_t>("kills");
		entry.deaths = result->getNumber<uint16_t>("deaths");
		entry.damageDealt = result->getNumber<int64_t>("damage_dealt");
		entry.healingDone = result->getNumber<int64_t>("healing_done");
		entry.mmrChange = result->getNumber<int32_t>("mmr_change");
		history.push_back(entry);
	} while (result->next());

	return history;
}

bool IOArena::updateMMR(uint32_t playerId, int32_t mmrChange, bool won) {
	std::string streakUpdate;
	if (won) {
		streakUpdate = fmt::format(
			"`wins` = `wins` + 1, `win_streak` = `win_streak` + 1, "
			"`best_streak` = GREATEST(`best_streak`, `win_streak` + 1)"
		);
	} else {
		streakUpdate = "`losses` = `losses` + 1, `win_streak` = 0";
	}

	auto query = fmt::format(
		"UPDATE `arena_players` SET `mmr` = GREATEST(0, `mmr` + ({})), {}, "
		"`last_match` = NOW() WHERE `player_id` = {}",
		mmrChange, streakUpdate, playerId
	);
	return g_database().executeQuery(query);
}
