-- Arena PvP - Main Arena Logic
-- Manages arena flow from Lua side: pre-match checks, post-match rewards,
-- announcements, and integration with C++ ArenaSystem

ArenaPvP = {}

-- ============================================
-- Pre-match validation (called before C++ creates match)
-- ============================================

--- Validate all players in a match group before starting
---@param players table Array of player objects
---@param mode number ArenaMode enum
---@return boolean, string?
function ArenaPvP.validateMatchGroup(players, mode)
	for _, player in ipairs(players) do
		local canJoin, reason = ArenaConfig.canPlayerJoin(player)
		if not canJoin then
			return false, player:getName() .. ": " .. reason
		end
	end
	return true
end

-- ============================================
-- Post-match processing
-- ============================================

--- Process rewards after a match ends
--- Called from C++ via Lua callback or directly
---@param matchData table {matchId, mode, winnerTeam, players: [{id, team, kills, deaths, damage, healing}]}
function ArenaPvP.processMatchRewards(matchData)
	if not matchData or not matchData.players then
		return
	end

	local maxKills = 0
	local maxDamage = 0
	local mvpId = nil

	-- Find MVP (most kills, tiebreak by damage)
	for _, pData in ipairs(matchData.players) do
		if pData.kills > maxKills or (pData.kills == maxKills and pData.damage > maxDamage) then
			maxKills = pData.kills
			maxDamage = pData.damage
			mvpId = pData.id
		end
	end

	-- Award bonus points
	for _, pData in ipairs(matchData.players) do
		local player = Player(pData.id)
		if player then
			local bonusPoints = 0
			local bonusMsg = ""

			-- MVP bonus
			if pData.id == mvpId and #matchData.players > 2 then
				bonusPoints = bonusPoints + ArenaConfig.rewards.mvp
				bonusMsg = bonusMsg .. "MVP +" .. ArenaConfig.rewards.mvp .. " "
			end

			-- Killing spree bonus (3+ kills)
			if pData.kills >= 3 then
				local spreeBonus = (pData.kills - 2) * ArenaConfig.rewards.killingSpree
				bonusPoints = bonusPoints + spreeBonus
				bonusMsg = bonusMsg .. "Spree +" .. spreeBonus .. " "
			end

			-- Apply bonus points
			if bonusPoints > 0 then
				db.query(string.format(
					"UPDATE `arena_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
					bonusPoints, pData.id
				))
				player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
					"[Arena] Bonus rewards: " .. bonusMsg .. "(" .. bonusPoints .. " Arena Points)")
			end

			-- Update stored timestamp
			player:setStorageValue(ArenaConfig.storage.lastArenaMatch, os.time())
		end
	end
end

-- ============================================
-- Announcements
-- ============================================

--- Broadcast an arena event to all online players
---@param message string
function ArenaPvP.broadcast(message)
	for _, player in ipairs(Game.getPlayers()) do
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	end
end

--- Announce match result
---@param mode number
---@param winnerNames table
---@param loserNames table
function ArenaPvP.announceResult(mode, winnerNames, loserNames)
	local modeName = ArenaConfig.getModeName(mode)
	local msg = string.format("[Arena %s] %s defeated %s!",
		modeName,
		table.concat(winnerNames, ", "),
		table.concat(loserNames, ", ")
	)
	ArenaPvP.broadcast(msg)
end

--- Announce when a player achieves a new title
---@param player Player
---@param oldMMR number
---@param newMMR number
function ArenaPvP.checkTitlePromotion(player, oldMMR, newMMR)
	local oldTitle = ArenaConfig.getTitleForMMR(oldMMR)
	local newTitle = ArenaConfig.getTitleForMMR(newMMR)

	if oldTitle ~= newTitle then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			string.format("[Arena] Congratulations! You earned the title: %s!", newTitle))

		-- Store title
		local titleIndex = 0
		for i, t in ipairs(ArenaConfig.titles) do
			if t.name == newTitle then
				titleIndex = i
				break
			end
		end
		player:setStorageValue(ArenaConfig.storage.arenaTitle, titleIndex)

		-- Broadcast promotion for high titles
		if newMMR >= 1800 then
			ArenaPvP.broadcast(string.format("[Arena] %s has achieved the rank of %s! (MMR: %d)",
				player:getName(), newTitle, newMMR))
		end
	end
end

-- ============================================
-- Utility
-- ============================================

--- Get arena queue summary for display
---@return string
function ArenaPvP.getQueueSummary()
	local modes = {
		Arena.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
		Arena.MODE_FFA, Arena.MODE_LMS,
	}

	local lines = {}
	local totalQueue = 0
	for _, mode in ipairs(modes) do
		local count = Arena.getQueueSize(mode)
		totalQueue = totalQueue + count
		if count > 0 then
			table.insert(lines, string.format("  %s: %d", ArenaConfig.getModeName(mode), count))
		end
	end

	local activeMatches = Arena.getActiveMatchCount()
	local msg = string.format("[Arena] Queue: %d | Active Matches: %d\n", totalQueue, activeMatches)
	if #lines > 0 then
		msg = msg .. table.concat(lines, "\n")
	else
		msg = msg .. "  No players in queue."
	end

	return msg
end
