-- Arena PvP - Main Arena Logic
-- Manages arena flow from Lua side: pre-match checks, post-match rewards,
-- announcements, and integration with C++ ArenaSystem
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

ArenaPvP = {}

-- ============================================
-- Pre-match validation (called before C++ creates match)
-- ============================================

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

function ArenaPvP.processMatchRewards(matchData)
	if not matchData or not matchData.players then
		return
	end

	-- Anti-cheat validation
	if ArenaAntiCheat then
		local valid, reason = ArenaAntiCheat.validateMatchResult(matchData)
		if not valid then
			for _, pData in ipairs(matchData.players) do
				local player = Player(pData.id)
				if player then
					player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, reason)
				end
			end
			ArenaLog.logMatchResult(matchData.matchId, matchData.mode, 0, matchData.duration or 0, matchData.players)
			return
		end
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
			local bonusParts = {}

			-- MVP bonus
			if pData.id == mvpId and #matchData.players > 2 then
				bonusPoints = bonusPoints + ArenaConfig.rewards.mvp
				table.insert(bonusParts, player:getTranslation("arena.reward.mvp", {tostring(ArenaConfig.rewards.mvp)}))
			end

			-- Killing spree bonus (3+ kills)
			if pData.kills >= 3 then
				local spreeBonus = (pData.kills - 2) * ArenaConfig.rewards.killingSpree
				bonusPoints = bonusPoints + spreeBonus
				table.insert(bonusParts, player:getTranslation("arena.reward.spree", {tostring(spreeBonus)}))
			end

			-- Apply bonus points
			if bonusPoints > 0 then
				db.query(string.format(
					"UPDATE \`arena_players\` SET \`arena_points\` = \`arena_points\` + %d WHERE \`player_id\` = %d",
					bonusPoints, pData.id
				))
				local bonusMsg = table.concat(bonusParts, " ")
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
					"arena.reward.bonus", {bonusMsg, tostring(bonusPoints)})
			end

			player:setStorageValue(ArenaConfig.storage.lastArenaMatch, os.time())
		end
	end

	-- Log match result
	ArenaLog.logMatchResult(matchData.matchId, matchData.mode, matchData.winnerTeam,
		matchData.duration or 0, matchData.players)
end

-- ============================================
-- Announcements
-- ============================================

function ArenaPvP.broadcast(message)
	for _, player in ipairs(Game.getPlayers()) do
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	end
end

function ArenaPvP.broadcastLocalized(key, args)
	for _, player in ipairs(Game.getPlayers()) do
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, key, args)
	end
end

function ArenaPvP.announceResult(mode, winnerNames, loserNames)
	local modeI18nKeys = {
		[Arena.MODE_1V1] = "arena.mode.1v1",
		[Arena.MODE_2V2] = "arena.mode.2v2",
		[Arena.MODE_3V3] = "arena.mode.3v3",
		[Arena.MODE_FFA] = "arena.mode.ffa",
		[Arena.MODE_CTF] = "arena.mode.ctf",
		[Arena.MODE_KOTH] = "arena.mode.koth",
		[Arena.MODE_LMS] = "arena.mode.lms",
		[Arena.MODE_TOURNAMENT] = "arena.mode.tournament",
	}

	local modeKey = modeI18nKeys[mode] or "arena.mode.1v1"
	local winners = table.concat(winnerNames, ", ")
	local losers = table.concat(loserNames, ", ")

	for _, player in ipairs(Game.getPlayers()) do
		local modeName = player:getTranslation(modeKey)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.result.announcement", {modeName, winners, losers})
	end
end

function ArenaPvP.checkTitlePromotion(player, oldMMR, newMMR)
	local oldTitle = ArenaConfig.getTitleForMMR(oldMMR)
	local newTitle = ArenaConfig.getTitleForMMR(newMMR)

	if oldTitle ~= newTitle then
		local titleKey = ArenaConfig.getTitleI18nKey(newTitle)
		local translatedTitle = player:getTranslation(titleKey)

		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.title.promotion", {translatedTitle})

		local titleIndex = 0
		for i, t in ipairs(ArenaConfig.titles) do
			if t.name == newTitle then
				titleIndex = i
			end
		end
		player:setStorageValue(ArenaConfig.storage.arenaTitle, titleIndex)

		-- Broadcast for high titles
		if newMMR >= 1800 then
			for _, p in ipairs(Game.getPlayers()) do
				local tTitle = p:getTranslation(titleKey)
				p:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
					"arena.title.broadcast", {player:getName(), tTitle, tostring(newMMR)})
			end
		end
	end
end

-- ============================================
-- Utility
-- ============================================

function ArenaPvP.getQueueSummary(player)
	local modes = {
		Arena.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
		Arena.MODE_FFA, Arena.MODE_LMS,
	}

	local modeI18nKeys = {
		[Arena.MODE_1V1] = "arena.mode.1v1",
		[Arena.MODE_2V2] = "arena.mode.2v2",
		[Arena.MODE_3V3] = "arena.mode.3v3",
		[Arena.MODE_FFA] = "arena.mode.ffa",
		[Arena.MODE_LMS] = "arena.mode.lms",
	}

	local lines = {}
	local totalQueue = 0
	for _, mode in ipairs(modes) do
		local count = Arena.getQueueSize(mode)
		totalQueue = totalQueue + count
		if count > 0 then
			local modeName = player:getTranslation(modeI18nKeys[mode])
			table.insert(lines, string.format("  %s: %d", modeName, count))
		end
	end

	local activeMatches = Arena.getActiveMatchCount()
	local msg = player:getTranslation("arena.queue.summary", {tostring(totalQueue), tostring(activeMatches)}) .. "\n"
	if #lines > 0 then
		msg = msg .. table.concat(lines, "\n")
	else
		msg = msg .. player:getTranslation("arena.queue.empty")
	end

	return msg
end
