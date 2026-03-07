-- Arena PvP TalkAction
-- Commands: !arena [join|leave|stats|ranking|help] [mode]
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arena = TalkAction("!arena")

local modeMap = {
	["1v1"] = Arena.MODE_1V1,
	["2v2"] = Arena.MODE_2V2,
	["3v3"] = Arena.MODE_3V3,
	["ffa"] = Arena.MODE_FFA,
	["ctf"] = Arena.MODE_CTF,
	["koth"] = Arena.MODE_KOTH,
	["lms"] = Arena.MODE_LMS,
	["tournament"] = Arena.MODE_TOURNAMENT,
}

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

local function getModeName(player, modeId)
	local key = modeI18nKeys[modeId]
	if key then
		return player:getTranslation(key)
	end
	return "?"
end

local function showHelp(player)
	local msg = player:getTranslation("arena.cmd.help.header") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.join") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.leave") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.stats") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.ranking") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.history") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.modes") .. "\n"
	msg = msg .. player:getTranslation("arena.cmd.help.status")
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

function arena.onSay(player, words, param)
	if not player then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "help"

	if action == "join" then
		local modeName = args[2] or "1v1"
		local mode = modeMap[modeName]
		if not mode then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.invalid_mode")
			return true
		end

		local canJoin, reason = ArenaConfig.canPlayerJoin(player)
		if not canJoin then
			player:sendTextMessage(MESSAGE_FAILURE, reason)
			return true
		end

		local success = player:arenaJoinQueue(mode)
		if success then
			local translatedMode = getModeName(player, mode)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
				"arena.cmd.join.success", {translatedMode})
			ArenaLog.logQueueJoin(player, mode, player:arenaGetMMR())
		else
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.join.failed")
		end

	elseif action == "leave" then
		if not player:arenaIsInQueue() then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.leave.not_in_queue")
			return true
		end
		player:arenaLeaveQueue()
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.cmd.leave.success")
		ArenaLog.logQueueLeave(player)

	elseif action == "stats" then
		local targetName = args[2]
		local target = targetName and Player(targetName) or player
		if not target then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.stats.not_found")
			return true
		end
		local stats = target:arenaGetStats()
		if not stats then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.stats.no_profile")
			return true
		end
		local titleName = ArenaConfig.getTitleForMMR(stats.mmr)
		local titleKey = ArenaConfig.getTitleI18nKey(titleName)
		local translatedTitle = player:getTranslation(titleKey)
		local msg = player:getTranslation("arena.cmd.stats.header", {target:getName()}) .. "\n"
		msg = msg .. player:getTranslation("arena.cmd.stats.mmr_line", {tostring(stats.mmr), translatedTitle}) .. "\n"
		msg = msg .. ArenaConfig.formatRecord(player, stats) .. "\n"
		msg = msg .. player:getTranslation("arena.cmd.stats.kd_line",
			{tostring(stats.totalKills), tostring(stats.totalDeaths),
			 ArenaConfig.formatKDR(stats.totalKills, stats.totalDeaths)}) .. "\n"
		msg = msg .. player:getTranslation("arena.cmd.stats.points", {tostring(stats.arenaPoints)}) .. "\n"
		msg = msg .. player:getTranslation("arena.cmd.stats.streak",
			{tostring(stats.winStreak), tostring(stats.bestStreak)})
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "ranking" then
		local ranking = Arena.getTopRanking(10)
		if not ranking or #ranking == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.ranking.empty")
			return true
		end
		local msg = player:getTranslation("arena.cmd.ranking.header") .. "\n"
		for i, entry in ipairs(ranking) do
			local titleKey = ArenaConfig.getTitleI18nKey(ArenaConfig.getTitleForMMR(entry.mmr))
			local title = player:getTranslation(titleKey)
			msg = msg .. player:getTranslation("arena.cmd.ranking.entry",
				{tostring(i), entry.playerName, tostring(entry.mmr), title,
				 tostring(entry.wins), tostring(entry.losses)}) .. "\n"
		end
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "history" then
		local history = Arena.getPlayerHistory(player:getGuid(), 10)
		if not history or #history == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.cmd.history.empty")
			return true
		end
		local msg = player:getTranslation("arena.cmd.history.header") .. "\n"
		for _, match in ipairs(history) do
			local modeKey = modeI18nKeys[match.mode] or "arena.mode.1v1"
			local modeName = player:getTranslation(modeKey)
			local result = "?"
			if match.winnerTeam == 0 then
				result = player:getTranslation("arena.result.draw")
			elseif match.playerTeam == match.winnerTeam then
				result = player:getTranslation("arena.result.victory")
			else
				result = player:getTranslation("arena.result.defeat")
			end
			msg = msg .. player:getTranslation("arena.cmd.history.entry",
				{modeName, result, tostring(match.mmrChange),
				 tostring(match.kills), tostring(match.deaths),
				 tostring(match.duration)}) .. "\n"
		end
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "modes" then
		local msg = player:getTranslation("arena.cmd.modes.header") .. "\n"
		for modeId, nameKey in pairs(modeI18nKeys) do
			local descKey = ArenaConfig.modeDescI18nKeys[modeId]
			local name = player:getTranslation(nameKey)
			local desc = descKey and player:getTranslation(descKey) or ""
			local queueSize = Arena.getQueueSize(modeId)
			msg = msg .. player:getTranslation("arena.cmd.modes.entry",
				{name, desc, tostring(queueSize)}) .. "\n"
		end
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "status" then
		local state = player:arenaGetState()
		if state == Arena.STATE_IN_QUEUE then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.cmd.status.in_queue")
		elseif state == Arena.STATE_IN_MATCH then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.cmd.status.in_match")
		else
			local summary = ArenaPvP.getQueueSummary(player)
			player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, summary)
		end

	else
		showHelp(player)
	end

	return true
end

arena:separator(" ")
arena:groupType("normal")
arena:register()
