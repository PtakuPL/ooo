-- Arena PvP System - Configuration & Helpers
-- Loaded via data/libs/systems/load.lua
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

ArenaConfig = {
	-- Enable/disable the arena system (set to true when C++ ArenaSystem is ready)
	enabled = false,

	-- Minimum level to join arena
	minLevel = 50,
	-- Cooldown between arena joins (seconds)
	joinCooldownSeconds = 30,

	-- AFK timeout in seconds (0 = disabled)
	afkTimeout = 60,

	-- Max match duration in seconds (0 = unlimited)
	matchMaxDuration = 600,

	-- Storage keys
	storage = {
		lastArenaMatch = 960001,
		arenaWins = 960002,
		arenaTitle = 960003,
		globalMMR = 960004,
	},

	-- Arena Points rewards per result
	rewards = {
		win = 25,
		loss = 5,
		mvp = 15,
		killingSpree = 3,
	},

	-- MMR settings
	mmr = {
		initial = 1000,
		minGainOnWin = 10,
		maxLossOnDefeat = -30,
	},

	-- Anti-cheat settings
	antiCheat = {
		enabled = true,
		maxSameOpponentDaily = 3,
		dailyMaxMMRGain = 200,
		minMatchDuration = 30,
		suspiciousThreshold = 5,
	},

	-- Mode i18n key mapping
	modeI18nKeys = {
		[Arena.MODE_1V1] = "arena.mode.1v1",
		[Arena.MODE_2V2] = "arena.mode.2v2",
		[Arena.MODE_3V3] = "arena.mode.3v3",
		[Arena.MODE_FFA] = "arena.mode.ffa",
		[Arena.MODE_CTF] = "arena.mode.ctf",
		[Arena.MODE_KOTH] = "arena.mode.koth",
		[Arena.MODE_LMS] = "arena.mode.lms",
		[Arena.MODE_TOURNAMENT] = "arena.mode.tournament",
	},

	-- Mode descriptions i18n keys
	modeDescI18nKeys = {
		[Arena.MODE_1V1] = "arena.mode.1v1.desc",
		[Arena.MODE_2V2] = "arena.mode.2v2.desc",
		[Arena.MODE_3V3] = "arena.mode.3v3.desc",
		[Arena.MODE_FFA] = "arena.mode.ffa.desc",
		[Arena.MODE_CTF] = "arena.mode.ctf.desc",
		[Arena.MODE_KOTH] = "arena.mode.koth.desc",
		[Arena.MODE_LMS] = "arena.mode.lms.desc",
		[Arena.MODE_TOURNAMENT] = "arena.mode.tournament.desc",
	},

	-- Arena titles based on MMR
	titles = {
		{ minMMR = 0, name = "Novice", i18nKey = "arena.title.novice" },
		{ minMMR = 1100, name = "Apprentice", i18nKey = "arena.title.apprentice" },
		{ minMMR = 1200, name = "Contender", i18nKey = "arena.title.contender" },
		{ minMMR = 1300, name = "Fighter", i18nKey = "arena.title.fighter" },
		{ minMMR = 1400, name = "Warrior", i18nKey = "arena.title.warrior" },
		{ minMMR = 1500, name = "Veteran", i18nKey = "arena.title.veteran" },
		{ minMMR = 1600, name = "Elite", i18nKey = "arena.title.elite" },
		{ minMMR = 1700, name = "Champion", i18nKey = "arena.title.champion" },
		{ minMMR = 1800, name = "Gladiator", i18nKey = "arena.title.gladiator" },
		{ minMMR = 2000, name = "Legend", i18nKey = "arena.title.legend" },
		{ minMMR = 2200, name = "Mythic", i18nKey = "arena.title.mythic" },
		{ minMMR = 2500, name = "Immortal", i18nKey = "arena.title.immortal" },
	},

	-- Reward shop items
	shop = {
		{ name = "Arena Trophy (Small)", i18nKey = "arena.shop.item.trophy_small", itemId = 5805, cost = 100, category = "decoration" },
		{ name = "Arena Trophy (Large)", i18nKey = "arena.shop.item.trophy_large", itemId = 5806, cost = 250, category = "decoration" },
		{ name = "Gladiator Shield", i18nKey = "arena.shop.item.gladiator_shield", itemId = 2536, cost = 500, category = "equipment" },
		{ name = "Arena Amulet", i18nKey = "arena.shop.item.arena_amulet", itemId = 2125, cost = 300, category = "equipment" },
	},
}

-- ============================================
-- Helper functions
-- ============================================

function ArenaConfig.getTitleForMMR(mmr)
	local title = "Novice"
	for _, t in ipairs(ArenaConfig.titles) do
		if mmr >= t.minMMR then
			title = t.name
		end
	end
	return title
end

function ArenaConfig.getTitleI18nKey(titleName)
	for _, t in ipairs(ArenaConfig.titles) do
		if t.name == titleName then
			return t.i18nKey
		end
	end
	return "arena.title.novice"
end

function ArenaConfig.getModeName(player, modeId)
	local key = ArenaConfig.modeI18nKeys[modeId]
	if key and player then
		return player:getTranslation(key)
	end
	local fallback = {
		[Arena.MODE_1V1] = "1v1 Duel",
		[Arena.MODE_2V2] = "2v2 Team",
		[Arena.MODE_3V3] = "3v3 Team",
		[Arena.MODE_FFA] = "Free For All",
		[Arena.MODE_CTF] = "Capture The Flag",
		[Arena.MODE_KOTH] = "King of the Hill",
		[Arena.MODE_LMS] = "Last Man Standing",
		[Arena.MODE_TOURNAMENT] = "Tournament",
	}
	return fallback[modeId] or "Unknown"
end

function ArenaConfig.getTranslatedTitle(player, mmr)
	local titleName = ArenaConfig.getTitleForMMR(mmr)
	local key = ArenaConfig.getTitleI18nKey(titleName)
	return player:getTranslation(key)
end

function ArenaConfig.getWinRate(stats)
	if not stats then return 0 end
	local total = stats.wins + stats.losses
	return (total > 0) and math.floor(stats.wins / total * 100) or 0
end

function ArenaConfig.canPlayerJoin(player)
	if not player then
		return false, "Player not found"
	end
	if player:getLevel() < ArenaConfig.minLevel then
		return false, player:getTranslation("arena.check.level_required", {tostring(ArenaConfig.minLevel)})
	end
	if player:arenaIsInArena() then
		return false, player:getTranslation("arena.check.already_in_match")
	end
	if player:arenaIsInQueue() then
		return false, player:getTranslation("arena.check.already_in_queue")
	end
	local lastMatch = player:getStorageValue(ArenaConfig.storage.lastArenaMatch)
	if lastMatch > 0 then
		local timeSince = os.time() - lastMatch
		if timeSince < ArenaConfig.joinCooldownSeconds then
			local remaining = ArenaConfig.joinCooldownSeconds - timeSince
			return false, player:getTranslation("arena.check.cooldown", {tostring(remaining)})
		end
	end
	if player:getCondition(CONDITION_INFIGHT) then
		return false, player:getTranslation("arena.check.in_combat")
	end
	return true
end

function ArenaConfig.formatRecord(player, stats)
	if not stats then
		return player:getTranslation("arena.check.no_stats")
	end
	local wr = ArenaConfig.getWinRate(stats)
	return player:getTranslation("arena.record.format",
		{tostring(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(wr)})
end

function ArenaConfig.formatKDR(kills, deaths)
	if deaths > 0 then
		return string.format("%.2f", kills / deaths)
	end
	return tostring(kills)
end
