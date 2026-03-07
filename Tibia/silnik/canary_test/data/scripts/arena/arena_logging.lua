-- Arena PvP - Logging System
-- Phase 8.3: Match logging, metrics, and audit trail
-- Logs to: logs/arena.log (structured format)
-- All entries include timestamp, matchId, event type, details

ArenaLog = {}

-- Log levels
ArenaLog.LEVEL = {
	INFO = "INFO",
	WARN = "WARN",
	ERROR = "ERROR",
	SECURITY = "SECURITY",
	METRIC = "METRIC",
}

-- ============================================
-- Core logging function
-- ============================================

--- Write a line to the arena log file
---@param level string log level
---@param category string event category
---@param message string log message
local function writeLog(level, category, message)
	local timestamp = os.date("%Y-%m-%d %H:%M:%S")
	local line = string.format("[%s] [%s] [%s] %s", timestamp, level, category, message)

	-- Use Canary's built-in file logging if available
	local logFile = io.open("logs/arena.log", "a")
	if logFile then
		logFile:write(line .. "\n")
		logFile:close()
	end
end

-- ============================================
-- Match lifecycle logging
-- ============================================

--- Log when a match is created
---@param matchId number
---@param mode number ArenaMode
---@param playerIds table array of player IDs
function ArenaLog.logMatchCreated(matchId, mode, playerIds)
	local playerNames = {}
	for _, pid in ipairs(playerIds) do
		local p = Player(pid)
		table.insert(playerNames, p and p:getName() or tostring(pid))
	end

	writeLog(ArenaLog.LEVEL.INFO, "MATCH_CREATE",
		string.format("Match #%d | Mode: %s | Players: [%s]",
			matchId, ArenaConfig.getModeName(nil, mode) or tostring(mode),
			table.concat(playerNames, ", ")))
end

--- Log match result
---@param matchId number
---@param mode number
---@param winnerTeam number
---@param duration number seconds
---@param players table {id, team, kills, deaths, damage, healing, mmrChange}
function ArenaLog.logMatchResult(matchId, mode, winnerTeam, duration, players)
	local lines = {
		string.format("Match #%d FINISHED | Mode: %s | Winner: Team %d | Duration: %ds",
			matchId, ArenaConfig.getModeName(nil, mode) or tostring(mode), winnerTeam, duration),
	}

	for _, p in ipairs(players) do
		local playerName = "?"
		local player = Player(p.id)
		if player then playerName = player:getName() end

		local won = (p.team == winnerTeam and winnerTeam ~= 0)
		local result = winnerTeam == 0 and "DRAW" or (won and "WIN" or "LOSS")

		table.insert(lines, string.format(
			"  %s (ID:%d) Team:%d %s | K/D: %d/%d | Dmg: %d | Heal: %d | MMR: %+d",
			playerName, p.id, p.team, result,
			p.kills or 0, p.deaths or 0,
			p.damage or p.damageDealt or 0,
			p.healing or p.healingDone or 0,
			p.mmrChange or 0))
	end

	writeLog(ArenaLog.LEVEL.INFO, "MATCH_RESULT", table.concat(lines, "\n"))
end

--- Log when a player joins the queue
---@param player Player
---@param mode number
---@param mmr number
function ArenaLog.logQueueJoin(player, mode, mmr)
	writeLog(ArenaLog.LEVEL.INFO, "QUEUE_JOIN",
		string.format("%s (ID:%d) joined %s queue | MMR: %d",
			player:getName(), player:getGuid(),
			ArenaConfig.getModeName(nil, mode) or tostring(mode), mmr))
end

--- Log when a player leaves the queue
---@param player Player
function ArenaLog.logQueueLeave(player)
	writeLog(ArenaLog.LEVEL.INFO, "QUEUE_LEAVE",
		string.format("%s (ID:%d) left queue",
			player:getName(), player:getGuid()))
end

--- Log when a player disconnects during a match
---@param playerId number
---@param matchId number
function ArenaLog.logDisconnect(playerId, matchId)
	local playerName = "?"
	local player = Player(playerId)
	if player then playerName = player:getName() end

	writeLog(ArenaLog.LEVEL.WARN, "DISCONNECT",
		string.format("%s (ID:%d) disconnected during Match #%d",
			playerName, playerId, matchId))
end

-- ============================================
-- Security logging
-- ============================================

--- Log security event (anti-cheat trigger)
---@param matchId number
---@param flagType string
---@param detail string
function ArenaLog.logSecurity(matchId, flagType, detail)
	writeLog(ArenaLog.LEVEL.SECURITY, "ANTICHEAT",
		string.format("Match #%d | Flag: %s | %s", matchId, flagType, detail))
end

--- Log blocked action (spell/item/party)
---@param player Player
---@param actionType string
---@param detail string
function ArenaLog.logBlockedAction(player, actionType, detail)
	writeLog(ArenaLog.LEVEL.WARN, "BLOCKED",
		string.format("%s (ID:%d) | Action: %s | %s",
			player:getName(), player:getGuid(), actionType, detail))
end

--- Log AFK detection
---@param player Player
---@param idleSeconds number
function ArenaLog.logAFK(player, idleSeconds)
	writeLog(ArenaLog.LEVEL.WARN, "AFK",
		string.format("%s (ID:%d) idle for %ds - force loss",
			player:getName(), player:getGuid(), idleSeconds))
end

-- ============================================
-- Metrics logging
-- ============================================

--- Log periodic arena metrics (queue sizes, active matches)
function ArenaLog.logMetrics()
	local modes = {
		Arena.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
		Arena.MODE_FFA, Arena.MODE_LMS, Arena.MODE_CTF,
		Arena.MODE_KOTH, Arena.MODE_TOURNAMENT,
	}

	local queueParts = {}
	local totalQueue = 0
	for _, mode in ipairs(modes) do
		local count = Arena.getQueueSize(mode)
		if count > 0 then
			totalQueue = totalQueue + count
			table.insert(queueParts,
				string.format("%s:%d", ArenaConfig.getModeName(nil, mode) or "?", count))
		end
	end

	local activeMatches = Arena.getActiveMatchCount()

	writeLog(ArenaLog.LEVEL.METRIC, "STATUS",
		string.format("Active: %d | Queue: %d [%s]",
			activeMatches, totalQueue,
			#queueParts > 0 and table.concat(queueParts, ", ") or "empty"))
end

-- Register periodic metrics logging (every 5 minutes)
local metricsLogger = GlobalEvent("ArenaMetricsLogger")

function metricsLogger.onThink(interval)
	ArenaLog.logMetrics()
	return true
end

metricsLogger:interval(300000) -- 5 minutes
metricsLogger:register()

-- ============================================
-- Admin logging
-- ============================================

--- Log GM admin action
---@param gm Player GM performing the action
---@param action string action name
---@param target string target player name
---@param detail string additional detail
function ArenaLog.logAdminAction(gm, action, target, detail)
	writeLog(ArenaLog.LEVEL.INFO, "ADMIN",
		string.format("GM %s | Action: %s | Target: %s | %s",
			gm:getName(), action, target, detail))
end

-- Export
_G.ArenaLog = ArenaLog
