-- Arena PvP System - Configuration & Helpers
-- Loaded via data/libs/systems/load.lua

ArenaConfig = {
	-- Minimum level to join arena
	minLevel = 50,

	-- Cooldown between arena joins (seconds)
	joinCooldownSeconds = 30,

	-- Storage keys
	storage = {
		lastArenaMatch = 960001,  -- timestamp of last match
		totalArenaWins = 960002,
		arenaTitle = 960003,      -- current arena title ID
		seasonalMMR = 960004,
	},

	-- Arena Points rewards per result
	rewards = {
		win = 25,
		loss = 5,
		draw = 3,
		mvp = 10,        -- extra for MVP (most kills/damage)
		firstBlood = 5,  -- first kill in match
		killingSpree = 3, -- per kill in spree (3+)
	},

	-- MMR settings
	mmr = {
		initial = 1000,
		kFactor = 25,
		minGainOnWin = 10,
		maxLossOnDefeat = -30,
	},

	-- Mode display names
	modeNames = {
		[Arena.MODE_1V1] = "1v1 Duel",
		[Arena.MODE_2V2] = "2v2 Team",
		[Arena.MODE_3V3] = "3v3 Team",
		[Arena.MODE_FFA] = "Free For All",
		[Arena.MODE_CTF] = "Capture The Flag",
		[Arena.MODE_KOTH] = "King of the Hill",
		[Arena.MODE_LMS] = "Last Man Standing",
		[Arena.MODE_TOURNAMENT] = "Tournament",
	},

	-- Mode descriptions for NPC/UI
	modeDescriptions = {
		[Arena.MODE_1V1] = "A classic duel between two warriors. 5 minute time limit.",
		[Arena.MODE_2V2] = "Two teams of two battle it out. 7 minute time limit.",
		[Arena.MODE_3V3] = "Two teams of three clash. 10 minute time limit.",
		[Arena.MODE_FFA] = "Every player for themselves! Most kills wins. 5 minutes.",
		[Arena.MODE_CTF] = "Capture the enemy flag and bring it to your base. 10 minutes.",
		[Arena.MODE_KOTH] = "Hold the central point to accumulate score. 8 minutes.",
		[Arena.MODE_LMS] = "No respawns. Last one standing wins. 15 minutes.",
		[Arena.MODE_TOURNAMENT] = "Bracket-style elimination tournament. Special event.",
	},

	-- Arena titles based on MMR
	titles = {
		{ minMMR = 0,    name = "Novice" },
		{ minMMR = 1100, name = "Apprentice" },
		{ minMMR = 1200, name = "Contender" },
		{ minMMR = 1300, name = "Fighter" },
		{ minMMR = 1400, name = "Warrior" },
		{ minMMR = 1500, name = "Veteran" },
		{ minMMR = 1600, name = "Elite" },
		{ minMMR = 1700, name = "Champion" },
		{ minMMR = 1800, name = "Gladiator" },
		{ minMMR = 2000, name = "Legend" },
		{ minMMR = 2200, name = "Mythic" },
		{ minMMR = 2500, name = "Immortal" },
	},

	-- Reward shop items (arena points cost)
	shop = {
		{ id = 1, name = "Arena Trophy (Small)", itemId = 5805, cost = 100, category = "decoration" },
		{ id = 2, name = "Arena Trophy (Large)", itemId = 5806, cost = 250, category = "decoration" },
		{ id = 3, name = "Gladiator Shield",     itemId = 2536, cost = 500, category = "equipment" },
		{ id = 4, name = "Arena Amulet",         itemId = 2125, cost = 300, category = "equipment" },
	},
}

-- ============================================
-- Helper functions
-- ============================================

--- Get arena title for a given MMR
---@param mmr number
---@return string
function ArenaConfig.getTitleForMMR(mmr)
	local title = "Novice"
	for _, t in ipairs(ArenaConfig.titles) do
		if mmr >= t.minMMR then
			title = t.name
		end
	end
	return title
end

--- Get mode name by ID
---@param modeId number
---@return string
function ArenaConfig.getModeName(modeId)
	return ArenaConfig.modeNames[modeId] or "Unknown"
end

--- Check if player meets requirements to join arena
---@param player Player
---@return boolean, string? -- success, error message
function ArenaConfig.canPlayerJoin(player)
	if not player then
		return false, "Player not found"
	end

	if player:getLevel() < ArenaConfig.minLevel then
		return false, string.format("You need at least level %d to join the arena.", ArenaConfig.minLevel)
	end

	if player:arenaIsInArena() then
		return false, "You are already in an arena match!"
	end

	if player:arenaIsInQueue() then
		return false, "You are already in the queue!"
	end

	-- Cooldown check
	local lastMatch = player:getStorageValue(ArenaConfig.storage.lastArenaMatch)
	if lastMatch > 0 then
		local timeSince = os.time() - lastMatch
		if timeSince < ArenaConfig.joinCooldownSeconds then
			local remaining = ArenaConfig.joinCooldownSeconds - timeSince
			return false, string.format("You must wait %d seconds before joining again.", remaining)
		end
	end

	-- Can't join during combat
	if player:getCondition(CONDITION_INFIGHT) then
		return false, "You cannot join the arena while in combat."
	end

	return true
end

--- Format a win/loss record string
---@param stats table
---@return string
function ArenaConfig.formatRecord(stats)
	if not stats then
		return "No stats"
	end
	local total = stats.wins + stats.losses
	local wr = (total > 0) and math.floor(stats.wins / total * 100) or 0
	return string.format("%dW / %dL / %dD (%d%% WR)", stats.wins, stats.losses, stats.draws, wr)
end

--- Format KDR string
---@param kills number
---@param deaths number
---@return string
function ArenaConfig.formatKDR(kills, deaths)
	if deaths > 0 then
		return string.format("%.2f", kills / deaths)
	end
	return tostring(kills)
end
