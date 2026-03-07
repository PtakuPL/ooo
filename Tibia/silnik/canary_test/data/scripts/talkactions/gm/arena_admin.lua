-- Arena PvP - GM Commands
-- Usage: !arena-admin <subcommand> [args]
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

local arenaAdmin = TalkAction("!arena-admin")

function arenaAdmin.onSay(player, words, param)
	if not player then
		return false
	end

	if player:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "help"

	if action == "info" then
		local activeMatches = Arena.getActiveMatchCount()
		local msg = player:getTranslation("arena.admin.info.header") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.info.active_matches", {tostring(activeMatches)}) .. "\n"

		local modes = {
			Arena.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
			Arena.MODE_FFA, Arena.MODE_LMS
		}
		msg = msg .. player:getTranslation("arena.admin.info.queue") .. "\n"
		local modeI18nKeys = {
			[Arena.MODE_1V1] = "arena.mode.1v1",
			[Arena.MODE_2V2] = "arena.mode.2v2",
			[Arena.MODE_3V3] = "arena.mode.3v3",
			[Arena.MODE_FFA] = "arena.mode.ffa",
			[Arena.MODE_LMS] = "arena.mode.lms",
		}
		for _, mode in ipairs(modes) do
			local count = Arena.getQueueSize(mode)
			local modeName = player:getTranslation(modeI18nKeys[mode])
			msg = msg .. "  " .. modeName .. ": " .. count .. "\n"
		end

		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "stats" then
		local targetName = args[2]
		if not targetName then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.usage")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.not_found", {targetName})
			return true
		end

		local stats = target:arenaGetStats()
		if not stats then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.stats.no_profile", {targetName})
			return true
		end

		local titleName = ArenaConfig.getTitleForMMR(stats.mmr)
		local titleKey = ArenaConfig.getTitleI18nKey(titleName)
		local translatedTitle = player:getTranslation(titleKey)

		local msg = player:getTranslation("arena.admin.stats.header", {target:getName()}) .. "\n"
		msg = msg .. player:getTranslation("arena.admin.stats.mmr_line", {tostring(stats.mmr), translatedTitle}) .. "\n"
		msg = msg .. player:getTranslation("arena.record.format", {tostring(stats.wins), tostring(stats.losses), tostring(stats.draws), tostring(ArenaConfig.getWinRate(stats))}) .. "\n"
		msg = msg .. player:getTranslation("arena.admin.stats.kd_line", {tostring(stats.totalKills), tostring(stats.totalDeaths), ArenaConfig.formatKDR(stats.totalKills, stats.totalDeaths)}) .. "\n"
		msg = msg .. player:getTranslation("arena.admin.stats.points", {tostring(stats.arenaPoints)}) .. "\n"
		msg = msg .. player:getTranslation("arena.admin.stats.streak", {tostring(stats.winStreak), tostring(stats.bestStreak)})
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "setmmr" then
		local targetName = args[2]
		local newMMR = tonumber(args[3])
		if not targetName or not newMMR then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.setmmr.usage")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `mmr` = %d WHERE `player_id` = %d",
			newMMR, target:getGuid()
		))
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.admin.setmmr.success", {target:getName(), tostring(newMMR)})
		ArenaLog.logAdminAction(player, "setmmr", target:getName(), "Set MMR to " .. newMMR)

	elseif action == "addpoints" then
		local targetName = args[2]
		local points = tonumber(args[3])
		if not targetName or not points then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.addpoints.usage")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
			points, target:getGuid()
		))
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.admin.addpoints.success", {tostring(points), target:getName()})
		ArenaLog.logAdminAction(player, "addpoints", target:getName(), "Added " .. points .. " points")

	elseif action == "reset" then
		local targetName = args[2]
		if not targetName then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.reset.usage")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.admin.player_not_online")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `mmr` = 1000, `wins` = 0, `losses` = 0, `draws` = 0, " ..
			"`win_streak` = 0, `best_streak` = 0, `total_damage` = 0, `total_healing` = 0, " ..
			"`total_kills` = 0, `total_deaths` = 0, `arena_points` = 0 WHERE `player_id` = %d",
			target:getGuid()
		))
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
			"arena.admin.reset.success", {target:getName()})
		ArenaLog.logAdminAction(player, "reset", target:getName(), "Full stats reset")

	elseif action == "broadcast" then
		local message = param:sub(#"broadcast " + 1)
		if message and message ~= "" then
			ArenaPvP.broadcast("[Arena] " .. message)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.admin.broadcast.sent")
			ArenaLog.logAdminAction(player, "broadcast", "-", message)
		end

	else
		local msg = player:getTranslation("arena.admin.help.header") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.info") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.stats") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.setmmr") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.addpoints") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.reset") .. "\n"
		msg = msg .. player:getTranslation("arena.admin.help.broadcast")
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
	end

	return true
end

arenaAdmin:groupType("gamemaster")
arenaAdmin:register()
