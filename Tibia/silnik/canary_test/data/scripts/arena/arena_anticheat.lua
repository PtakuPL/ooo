-- Arena PvP - Anti-Boost & Anti-Wintrading System
-- Phase 8.2: Detection and prevention of arena MMR manipulation
-- Tracks: repeat opponents, daily MMR limits, surrender detection, min match time
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

ArenaAntiCheat = {}

-- Storage: opponent tracking per day
-- Format: playerOpponents[playerId][opponentId] = {count=N, date="YYYY-MM-DD"}
ArenaAntiCheat.playerOpponents = {}

-- Storage: daily MMR gain tracking
-- Format: dailyMMRGain[playerId] = {date="YYYY-MM-DD", gain=N}
ArenaAntiCheat.dailyMMRGain = {}

-- Storage: suspicious flags
-- Format: suspiciousPlayers[playerId] = {flags={}, count=N}
ArenaAntiCheat.suspiciousPlayers = {}

-- ============================================
-- Configuration (read from config.lua or fallback)
-- ============================================
local function getConfig()
	return {
		maxSameOpponentDaily = ArenaConfig.antiCheat and ArenaConfig.antiCheat.maxSameOpponentDaily or 3,
		dailyMaxMMRGain = ArenaConfig.antiCheat and ArenaConfig.antiCheat.dailyMaxMMRGain or 200,
		minMatchDuration = ArenaConfig.antiCheat and ArenaConfig.antiCheat.minMatchDuration or 30,
		suspiciousThreshold = 5, -- N flags before GM alert
		enabled = ArenaConfig.antiCheat and ArenaConfig.antiCheat.enabled ~= false,
	}
end

-- ============================================
-- Check if match result should count for MMR
-- ============================================

--- Validate a match result before awarding MMR
---@param matchData table {matchId, mode, duration, players: [{id, team, kills, deaths}]}
---@return boolean valid Whether the match should count for MMR
---@return string? reason I18n key explaining why it was invalidated
function ArenaAntiCheat.validateMatchResult(matchData)
	local config = getConfig()

	if not config.enabled then
		return true
	end

	-- 1. Minimum match duration check
	if matchData.duration and matchData.duration < config.minMatchDuration then
		ArenaAntiCheat.flagSuspicious(matchData, "instant_surrender",
			"Match too short: " .. matchData.duration .. "s")
		return false, "arena.anticheat.match_too_short"
	end

	-- 2. Check for repeat opponents (anti-wintrading)
	local today = os.date("%Y-%m-%d")
	local repeatOffenders = {}

	for _, pDataA in ipairs(matchData.players) do
		if not ArenaAntiCheat.playerOpponents[pDataA.id] then
			ArenaAntiCheat.playerOpponents[pDataA.id] = {}
		end

		for _, pDataB in ipairs(matchData.players) do
			if pDataA.id ~= pDataB.id and pDataA.team ~= pDataB.team then
				local key = pDataB.id
				local record = ArenaAntiCheat.playerOpponents[pDataA.id][key]

				if not record or record.date ~= today then
					ArenaAntiCheat.playerOpponents[pDataA.id][key] = {count = 1, date = today}
				else
					record.count = record.count + 1
					if record.count > config.maxSameOpponentDaily then
						table.insert(repeatOffenders, {playerId = pDataA.id, opponentId = pDataB.id, count = record.count})
					end
				end
			end
		end
	end

	if #repeatOffenders > 0 then
		local firstOffender = repeatOffenders[1]
		ArenaAntiCheat.flagSuspicious(matchData, "repeat_opponent",
			string.format("Player %d vs %d: %d times today",
				firstOffender.playerId, firstOffender.opponentId, firstOffender.count))
		return false, "arena.anticheat.repeat_opponent"
	end

	return true
end

-- ============================================
-- Check daily MMR cap
-- ============================================

--- Check if a player has exceeded their daily MMR gain cap
---@param playerId number
---@param mmrGain number planned gain
---@return number adjustedGain actual MMR gain after cap
function ArenaAntiCheat.checkDailyMMRCap(playerId, mmrGain)
	local config = getConfig()

	if not config.enabled or config.dailyMaxMMRGain <= 0 then
		return mmrGain
	end

	-- Only cap positive gains
	if mmrGain <= 0 then
		return mmrGain
	end

	local today = os.date("%Y-%m-%d")
	local record = ArenaAntiCheat.dailyMMRGain[playerId]

	if not record or record.date ~= today then
		ArenaAntiCheat.dailyMMRGain[playerId] = {date = today, gain = 0}
		record = ArenaAntiCheat.dailyMMRGain[playerId]
	end

	local remaining = config.dailyMaxMMRGain - record.gain
	if remaining <= 0 then
		-- Already hit cap
		local player = Player(playerId)
		if player then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
				"arena.anticheat.daily_cap_reached", {tostring(config.dailyMaxMMRGain)})
		end
		return 0
	end

	local adjustedGain = math.min(mmrGain, remaining)
	record.gain = record.gain + adjustedGain

	if adjustedGain < mmrGain then
		local player = Player(playerId)
		if player then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
				"arena.anticheat.daily_cap_partial", {tostring(adjustedGain), tostring(mmrGain)})
		end
	end

	return adjustedGain
end

-- ============================================
-- Suspicious activity flagging
-- ============================================

--- Flag a match/player as suspicious
---@param matchData table
---@param flagType string type of suspicious activity
---@param detail string human-readable description
function ArenaAntiCheat.flagSuspicious(matchData, flagType, detail)
	for _, pData in ipairs(matchData.players) do
		if not ArenaAntiCheat.suspiciousPlayers[pData.id] then
			ArenaAntiCheat.suspiciousPlayers[pData.id] = {flags = {}, count = 0}
		end

		local record = ArenaAntiCheat.suspiciousPlayers[pData.id]
		table.insert(record.flags, {
			type = flagType,
			detail = detail,
			matchId = matchData.matchId,
			timestamp = os.time(),
		})
		record.count = record.count + 1

		-- Alert GMs if threshold reached
		local config = getConfig()
		if record.count >= config.suspiciousThreshold then
			ArenaAntiCheat.alertGMs(pData.id, record)
		end
	end

	-- Log to arena log
	ArenaLog.logSecurity(matchData.matchId, flagType, detail)
end

--- Alert online GMs about suspicious player
---@param playerId number
---@param record table
function ArenaAntiCheat.alertGMs(playerId, record)
	local playerName = "Unknown"
	local player = Player(playerId)
	if player then
		playerName = player:getName()
	end

	local msg = string.format("[Arena Anti-Cheat] Player %s (ID: %d) flagged %d times. Last: %s",
		playerName, playerId, record.count,
		record.flags[#record.flags] and record.flags[#record.flags].detail or "?")

	for _, p in ipairs(Game.getPlayers()) do
		if p:getAccountType() >= ACCOUNT_TYPE_GAMEMASTER then
			p:sendTextMessage(MESSAGE_EVENT_ADVANCE, msg)
		end
	end
end

-- ============================================
-- Cleanup (called periodically or on server restart)
-- ============================================

--- Reset daily tracking data (call at midnight or server start)
function ArenaAntiCheat.resetDailyData()
	-- Only clear stale entries (not today's)
	local today = os.date("%Y-%m-%d")

	for playerId, opponents in pairs(ArenaAntiCheat.playerOpponents) do
		for oppId, record in pairs(opponents) do
			if record.date ~= today then
				opponents[oppId] = nil
			end
		end
		if next(opponents) == nil then
			ArenaAntiCheat.playerOpponents[playerId] = nil
		end
	end

	for playerId, record in pairs(ArenaAntiCheat.dailyMMRGain) do
		if record.date ~= today then
			ArenaAntiCheat.dailyMMRGain[playerId] = nil
		end
	end
end

-- Register daily cleanup
local antiCheatCleanup = GlobalEvent("ArenaAntiCheatCleanup")

function antiCheatCleanup.onThink(interval)
	ArenaAntiCheat.resetDailyData()
	return true
end

antiCheatCleanup:interval(3600000) -- Cleanup every hour
antiCheatCleanup:register()

-- Export
_G.ArenaAntiCheat = ArenaAntiCheat
