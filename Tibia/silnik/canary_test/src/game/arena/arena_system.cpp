/**
 * @file arena_system.cpp
 * @brief Arena PvP system - main system implementation
 */

#include "game/arena/arena_system.hpp"

#include "creatures/players/player.hpp"
#include "game/game.hpp"
#include "io/ioarena.hpp"
#include "lib/logging/logger.hpp"

#include <algorithm>
#include <ctime>

// ============================================
// Lifecycle
// ============================================

void ArenaSystem::init() {
	if (initialized) {
		return;
	}

	// Clear stale queue entries from DB (from previous server session)
	IOArena::clearQueue();
	matchmaking.clear();
	activeMatches.clear();
	playerToMatch.clear();
	playerStates.clear();
	nextMatchId = 0;
	initialized = true;

	g_logger().info("[Arena] System initialized");
}

void ArenaSystem::shutdown() {
	g_logger().info("[Arena] Shutting down - {} active matches", activeMatches.size());

	// Force-finish all active matches as draws
	for (auto &[matchId, match] : activeMatches) {
		if (match && match->getState() == ArenaMatchState::IN_PROGRESS) {
			match->finish(0); // Draw
			// Teleport players out
			teleportPlayersOut(*match);
		}
	}

	activeMatches.clear();
	playerToMatch.clear();
	playerStates.clear();
	matchmaking.clear();
	IOArena::clearQueue();
	initialized = false;

	g_logger().info("[Arena] System shut down");
}

void ArenaSystem::tick() {
	if (!initialized) {
		return;
	}

	// 1. Check active matches for timeouts / win conditions
	checkActiveMatches();

	// 2. Run matchmaking
	auto matchedGroups = matchmaking.tick();

	// 3. Create matches from matched groups
	for (const auto &group : matchedGroups) {
		createMatch(group);
	}
}

// ============================================
// Queue
// ============================================

bool ArenaSystem::joinQueue(const std::shared_ptr<Player> &player, ArenaMode mode) {
	if (!player || !initialized) {
		return false;
	}

	uint32_t playerId = player->getGUID();

	// Already in queue or match?
	if (isPlayerInQueue(playerId) || isPlayerInArena(playerId)) {
		player->sendTextMessage(MESSAGE_STATUS, "You are already in the arena queue or in a match.");
		return false;
	}

	// Ensure player has arena stats entry
	auto stats = IOArena::getPlayerStats(playerId);
	if (stats.playerId == 0 || stats.mmr == 0) {
		IOArena::createPlayerEntry(playerId);
		stats.mmr = 1000;
	}

	// Add to matchmaking queue
	if (!matchmaking.addToQueue(playerId, mode, stats.mmr)) {
		return false;
	}

	// Backup to DB (for crash recovery, not critical)
	IOArena::addToQueue(playerId, mode, stats.mmr);

	playerStates[playerId] = ArenaPlayerState::IN_QUEUE;

	player->sendTextMessage(MESSAGE_STATUS,
		fmt::format("You joined the {} arena queue. Searching for opponents...", arenaModeToString(mode)));

	g_logger().info("[Arena] Player {} ({}) joined {} queue (MMR: {})",
		player->getName(), playerId, arenaModeToString(mode), stats.mmr);

	return true;
}

bool ArenaSystem::leaveQueue(const std::shared_ptr<Player> &player) {
	if (!player) {
		return false;
	}

	uint32_t playerId = player->getGUID();

	if (!isPlayerInQueue(playerId)) {
		player->sendTextMessage(MESSAGE_STATUS, "You are not in the arena queue.");
		return false;
	}

	matchmaking.removeFromQueue(playerId);
	IOArena::removeFromQueue(playerId);
	playerStates.erase(playerId);

	player->sendTextMessage(MESSAGE_STATUS, "You left the arena queue.");
	return true;
}

bool ArenaSystem::isPlayerInQueue(uint32_t playerId) const {
	auto it = playerStates.find(playerId);
	return it != playerStates.end() && it->second == ArenaPlayerState::IN_QUEUE;
}

// ============================================
// Match state
// ============================================

bool ArenaSystem::isPlayerInArena(uint32_t playerId) const {
	auto it = playerStates.find(playerId);
	return it != playerStates.end() && it->second == ArenaPlayerState::IN_MATCH;
}

ArenaPlayerState ArenaSystem::getPlayerState(uint32_t playerId) const {
	auto it = playerStates.find(playerId);
	if (it != playerStates.end()) {
		return it->second;
	}
	return ArenaPlayerState::IDLE;
}

ArenaMatch* ArenaSystem::getPlayerMatch(uint32_t playerId) {
	auto it = playerToMatch.find(playerId);
	if (it != playerToMatch.end()) {
		auto matchIt = activeMatches.find(it->second);
		if (matchIt != activeMatches.end()) {
			return matchIt->second.get();
		}
	}
	return nullptr;
}

const ArenaMatch* ArenaSystem::getPlayerMatch(uint32_t playerId) const {
	auto it = playerToMatch.find(playerId);
	if (it != playerToMatch.end()) {
		auto matchIt = activeMatches.find(it->second);
		if (matchIt != activeMatches.end()) {
			return matchIt->second.get();
		}
	}
	return nullptr;
}

// ============================================
// Combat hooks
// ============================================

void ArenaSystem::onArenaKill(uint32_t killerId, uint32_t victimId) {
	auto* match = getPlayerMatch(killerId);
	if (!match || match->getState() != ArenaMatchState::IN_PROGRESS) {
		return;
	}

	match->onKill(killerId, victimId);
	match->onPlayerDeath(victimId);

	// Notify players
	auto killerPlayer = g_game().getPlayerByGUID(killerId);
	auto victimPlayer = g_game().getPlayerByGUID(victimId);
	if (killerPlayer && victimPlayer) {
		sendMatchMessage(*match,
			fmt::format("{} killed {}!", killerPlayer->getName(), victimPlayer->getName()));
	}

	// Check win condition after kill
	if (match->checkWinCondition()) {
		finishMatch(match->getId());
	}
}

void ArenaSystem::onArenaDeath(uint32_t playerId) {
	auto* match = getPlayerMatch(playerId);
	if (!match || match->getState() != ArenaMatchState::IN_PROGRESS) {
		return;
	}

	match->onPlayerDeath(playerId);

	if (match->checkWinCondition()) {
		finishMatch(match->getId());
	}
}

void ArenaSystem::onArenaLogout(uint32_t playerId) {
	// If in queue, remove
	if (isPlayerInQueue(playerId)) {
		matchmaking.removeFromQueue(playerId);
		IOArena::removeFromQueue(playerId);
		playerStates.erase(playerId);
		return;
	}

	// If in match, count as death/loss
	if (isPlayerInArena(playerId)) {
		auto* match = getPlayerMatch(playerId);
		if (match && match->getState() == ArenaMatchState::IN_PROGRESS) {
			match->onPlayerDeath(playerId);

			g_logger().info("[Arena] Player {} disconnected during match {}", playerId, match->getId());

			if (match->checkWinCondition()) {
				finishMatch(match->getId());
			}
		}
	}
}

void ArenaSystem::onArenaDamage(uint32_t attackerId, uint32_t targetId, int64_t damage) {
	auto* match = getPlayerMatch(attackerId);
	if (!match || match->getState() != ArenaMatchState::IN_PROGRESS) {
		return;
	}

	match->onDamage(attackerId, damage);
}

void ArenaSystem::onArenaHeal(uint32_t healerId, int64_t amount) {
	auto* match = getPlayerMatch(healerId);
	if (!match || match->getState() != ArenaMatchState::IN_PROGRESS) {
		return;
	}

	match->onHeal(healerId, amount);
}

// ============================================
// Stats / Rankings
// ============================================

ArenaPlayerStats ArenaSystem::getPlayerStats(uint32_t playerId) {
	return IOArena::getPlayerStats(playerId);
}

std::vector<ArenaRankEntry> ArenaSystem::getTopRanking(uint32_t limit, uint32_t offset) {
	return IOArena::getTopRanking(limit, offset);
}

std::vector<ArenaMatchHistory> ArenaSystem::getPlayerHistory(uint32_t playerId, uint32_t limit) {
	return IOArena::getPlayerMatchHistory(playerId, limit);
}

// ============================================
// Info
// ============================================

uint32_t ArenaSystem::getActiveMatchCount() const {
	return static_cast<uint32_t>(activeMatches.size());
}

uint32_t ArenaSystem::getQueueSize(ArenaMode mode) const {
	return matchmaking.getQueueSize(mode);
}

// ============================================
// Internal: Match creation
// ============================================

void ArenaSystem::createMatch(const ArenaMatchmaking::MatchGroup &group) {
	// Create DB record
	uint32_t dbMatchId = IOArena::createMatch(group.mode, 0, 0);
	if (dbMatchId == 0) {
		g_logger().error("[Arena] Failed to create match in database");
		// Put players back in queue
		for (const auto &entry : group.players) {
			playerStates.erase(entry.playerId);
		}
		return;
	}

	auto match = std::make_shared<ArenaMatch>(dbMatchId, group.mode);

	// Assign teams
	assignTeams(*match, group.players);

	// Set temporary exit position (temple of first player)
	auto firstPlayer = g_game().getPlayerByGUID(group.players[0].playerId);
	if (firstPlayer) {
		match->setExitPosition(firstPlayer->getTemplePosition());
	}

	// TODO: Set spawn positions from map config
	// For now, use temporary hardcoded positions for testing
	// These will be replaced when map system is implemented
	match->setSpawnPositions(1, { Position(32369, 32241, 7) });
	match->setSpawnPositions(2, { Position(32369, 32235, 7) });

	// Register match
	activeMatches[dbMatchId] = match;
	for (const auto &entry : group.players) {
		playerToMatch[entry.playerId] = dbMatchId;
		playerStates[entry.playerId] = ArenaPlayerState::IN_MATCH;
		// Remove from DB queue
		IOArena::removeFromQueue(entry.playerId);
	}

	g_logger().info("[Arena] Match {} created (mode: {}, {} players)",
		dbMatchId, arenaModeToString(group.mode), group.players.size());

	// Teleport players in and start
	teleportPlayersIn(*match);

	// Start match after brief countdown (immediate for now)
	match->start();

	// Notify all participants
	sendMatchMessage(*match, "The arena match has started! Fight!");
}

// ============================================
// Internal: Match finish
// ============================================

void ArenaSystem::finishMatch(uint32_t matchId) {
	auto matchIt = activeMatches.find(matchId);
	if (matchIt == activeMatches.end()) {
		return;
	}

	auto &match = matchIt->second;
	if (match->getState() == ArenaMatchState::FINISHED) {
		// Already being processed
	} else {
		match->finish(match->getWinnerTeam());
	}

	uint8_t winnerTeam = match->getWinnerTeam();
	int32_t duration = static_cast<int32_t>(std::time(nullptr) - match->getStartTime());

	// Update DB match record
	IOArena::finishMatch(matchId, duration, winnerTeam);

	// Calculate average MMR for each team
	std::map<uint8_t, int32_t> teamMMRSum;
	std::map<uint8_t, int32_t> teamCount;
	for (const auto &[playerId, stats] : match->getPlayers()) {
		auto playerStats = IOArena::getPlayerStats(playerId);
		teamMMRSum[stats.team] += playerStats.mmr;
		teamCount[stats.team]++;
	}

	std::map<uint8_t, int32_t> teamAvgMMR;
	for (const auto &[team, sum] : teamMMRSum) {
		teamAvgMMR[team] = teamCount[team] > 0 ? sum / teamCount[team] : 1000;
	}

	// Process each player
	for (const auto &[playerId, matchStats] : match->getPlayers()) {
		bool won = (matchStats.team == winnerTeam && winnerTeam != 0);
		bool draw = (winnerTeam == 0);

		// Get opponent team's average MMR
		uint8_t opponentTeam = (matchStats.team == 1) ? 2 : 1;
		int32_t opponentAvgMMR = teamAvgMMR.count(opponentTeam) ? teamAvgMMR[opponentTeam] : 1000;

		auto playerStats = IOArena::getPlayerStats(playerId);
		int32_t mmrChange = 0;

		if (draw) {
			mmrChange = 0;
		} else {
			mmrChange = calculateMMRChange(playerStats.mmr, opponentAvgMMR, won);
		}

		// Save match player stats to DB
		ArenaPlayerMatchStats finalStats = matchStats;
		finalStats.mmrChange = mmrChange;
		IOArena::saveMatchPlayer(matchId, finalStats);

		// Update player MMR and stats
		if (!draw) {
			IOArena::updateMMR(playerId, mmrChange, won);
		}

		// Update cumulative stats
		playerStats.totalDamage += matchStats.damageDealt;
		playerStats.totalHealing += matchStats.healingDone;
		playerStats.totalKills += matchStats.kills;
		playerStats.totalDeaths += matchStats.deaths;

		auto query = fmt::format(
			"UPDATE `arena_players` SET `total_damage` = {}, `total_healing` = {}, "
			"`total_kills` = {}, `total_deaths` = {} WHERE `player_id` = {}",
			playerStats.totalDamage + matchStats.damageDealt,
			playerStats.totalHealing + matchStats.healingDone,
			playerStats.totalKills + matchStats.kills,
			playerStats.totalDeaths + matchStats.deaths,
			playerId
		);
		g_database().executeQuery(query);

		// Award arena points
		int32_t points = won ? 25 : 5;
		IOArena::addArenaPoints(playerId, points);

		// Send result to player
		auto player = g_game().getPlayerByGUID(playerId);
		if (player) {
			std::string resultMsg;
			if (draw) {
				resultMsg = fmt::format("Arena match ended in a DRAW! (+0 MMR, +5 Arena Points)");
			} else if (won) {
				resultMsg = fmt::format("VICTORY! +{} MMR, +{} Arena Points. K/D: {}/{}",
					mmrChange, points, matchStats.kills, matchStats.deaths);
			} else {
				resultMsg = fmt::format("DEFEAT. {} MMR, +{} Arena Points. K/D: {}/{}",
					mmrChange, points, matchStats.kills, matchStats.deaths);
			}
			player->sendTextMessage(MESSAGE_EVENT_ADVANCE, resultMsg);
		}

		// Clean up player state
		playerToMatch.erase(playerId);
		playerStates.erase(playerId);
	}

	// Teleport players out
	teleportPlayersOut(*match);

	// Remove match from active list
	activeMatches.erase(matchIt);

	g_logger().info("[Arena] Match {} finished. Winner team: {}, Duration: {}s",
		matchId, winnerTeam, duration);
}

// ============================================
// Internal: MMR calculation
// ============================================

int32_t ArenaSystem::calculateMMRChange(int32_t playerMMR, int32_t opponentAverageMMR, bool won) const {
	// ELO-style formula
	// Expected score: E = 1 / (1 + 10^((Ropp - Rself) / 400))
	double expected = 1.0 / (1.0 + std::pow(10.0, static_cast<double>(opponentAverageMMR - playerMMR) / 400.0));
	double actual = won ? 1.0 : 0.0;
	double K = 25.0; // K-factor

	int32_t change = static_cast<int32_t>(std::round(K * (actual - expected)));

	// Clamp: winners get at least +10, losers lose at most -30
	if (won) {
		change = std::max(change, 10);
	} else {
		change = std::max(change, -30);
	}

	return change;
}

// ============================================
// Internal: Team assignment
// ============================================

void ArenaSystem::assignTeams(ArenaMatch &match, const std::vector<ArenaQueueEntry> &players) {
	ArenaMode mode = match.getMode();

	if (mode == ArenaMode::FFA || mode == ArenaMode::LMS) {
		// In FFA/LMS each player is their own "team" (indexed 1..N)
		uint8_t teamIdx = 1;
		for (const auto &entry : players) {
			match.addPlayer(entry.playerId, teamIdx++);
		}
		return;
	}

	// Team modes: zigzag assignment sorted by MMR for balance
	// E.g., for 4 players sorted by MMR: [1200, 1150, 1100, 1050]
	// Team 1: [1200, 1100], Team 2: [1150, 1050] → balanced
	std::vector<ArenaQueueEntry> sorted = players;
	std::sort(sorted.begin(), sorted.end(), [](const ArenaQueueEntry &a, const ArenaQueueEntry &b) {
		return a.mmr > b.mmr; // Descending
	});

	for (size_t i = 0; i < sorted.size(); i++) {
		uint8_t team;
		// Zigzag: 1, 2, 2, 1, 1, 2, 2, 1 ...
		size_t block = i / 2;
		if (block % 2 == 0) {
			team = (i % 2 == 0) ? 1 : 2;
		} else {
			team = (i % 2 == 0) ? 2 : 1;
		}
		match.addPlayer(sorted[i].playerId, team);
	}
}

// ============================================
// Internal: Teleport and preparation
// ============================================

void ArenaSystem::teleportPlayersIn(ArenaMatch &match) {
	for (uint32_t playerId : match.getAllPlayerIds()) {
		auto player = g_game().getPlayerByGUID(playerId);
		if (!player) {
			continue;
		}

		Position spawnPos = match.getSpawnPosition(playerId);

		// Save return position (where player was before arena)
		// We use temple position as fallback
		if (match.getExitPosition() == Position()) {
			match.setExitPosition(player->getTemplePosition());
		}

		// Teleport
		g_game().internalTeleport(player, spawnPos);
		player->sendMagicEffect(spawnPos, CONST_ME_TELEPORT);

		// Prepare player
		preparePlayer(player);
	}
}

void ArenaSystem::teleportPlayersOut(ArenaMatch &match) {
	Position exitPos = match.getExitPosition();
	for (uint32_t playerId : match.getAllPlayerIds()) {
		auto player = g_game().getPlayerByGUID(playerId);
		if (!player) {
			continue;
		}

		// Use player's own temple as exit
		Position playerExit = player->getTemplePosition();
		g_game().internalTeleport(player, playerExit);
		player->sendMagicEffect(playerExit, CONST_ME_TELEPORT);

		// Restore full HP/Mana
		preparePlayer(player);
	}
}

void ArenaSystem::preparePlayer(const std::shared_ptr<Player> &player) {
	if (!player) {
		return;
	}

	// Full HP
	player->changeHealth(player->getMaxHealth() - player->getHealth());
	player->changeMana(player->getMaxMana() - player->getMana());

	// Remove negative conditions
	player->removeCondition(CONDITION_FIRE);
	player->removeCondition(CONDITION_ENERGY);
	player->removeCondition(CONDITION_POISON);
	player->removeCondition(CONDITION_DROWN);
	player->removeCondition(CONDITION_FREEZING);
	player->removeCondition(CONDITION_DAZZLED);
	player->removeCondition(CONDITION_CURSED);
	player->removeCondition(CONDITION_BLEEDING);
	player->removeCondition(CONDITION_PARALYZE);
}

// ============================================
// Internal: Messages
// ============================================

void ArenaSystem::sendMatchMessage(ArenaMatch &match, const std::string &message) {
	for (uint32_t playerId : match.getAllPlayerIds()) {
		auto player = g_game().getPlayerByGUID(playerId);
		if (player) {
			player->sendTextMessage(MESSAGE_EVENT_ADVANCE, message);
		}
	}
}

// ============================================
// Internal: Check active matches
// ============================================

void ArenaSystem::checkActiveMatches() {
	std::vector<uint32_t> matchesToFinish;

	for (auto &[matchId, match] : activeMatches) {
		if (!match || match->getState() != ArenaMatchState::IN_PROGRESS) {
			continue;
		}

		// Check time limit
		if (match->checkWinCondition()) {
			matchesToFinish.push_back(matchId);
		}
	}

	for (uint32_t matchId : matchesToFinish) {
		finishMatch(matchId);
	}
}
