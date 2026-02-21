-- Arena PvP - GM Commands
-- Admin/GM commands for arena management
-- Usage: !arena-admin <subcommand> [args]

local arenaAdmin = TalkAction("!arena-admin")

function arenaAdmin.onSay(player, words, param)
	if not player then
		return false
	end

	-- GM only
	if player:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "help"

	if action == "info" then
		-- Show arena system status
		local activeMatches = Arena.getActiveMatchCount()
		local msg = "[Arena Admin] System Status:\n"
		msg = msg .. "Active Matches: " .. activeMatches .. "\n"

		local modes = {
			Arena.MODE_1V1, Arena.MODE_2V2, Arena.MODE_3V3,
			Arena.MODE_FFA, Arena.MODE_LMS
		}
		msg = msg .. "Queue:\n"
		for _, mode in ipairs(modes) do
			local count = Arena.getQueueSize(mode)
			msg = msg .. "  " .. ArenaConfig.getModeName(mode) .. ": " .. count .. "\n"
		end

		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "stats" then
		-- Show specific player stats
		local targetName = args[2]
		if not targetName then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Usage: !arena-admin stats <playername>")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Player '" .. targetName .. "' not found (must be online).")
			return true
		end

		local stats = target:arenaGetStats()
		if not stats then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] No arena profile for " .. targetName)
			return true
		end

		local msg = "[Arena Admin] Stats for " .. target:getName() .. ":\n"
		msg = msg .. "MMR: " .. stats.mmr .. " | Title: " .. ArenaConfig.getTitleForMMR(stats.mmr) .. "\n"
		msg = msg .. "Record: " .. ArenaConfig.formatRecord(stats) .. "\n"
		msg = msg .. "K/D: " .. stats.totalKills .. "/" .. stats.totalDeaths
		msg = msg .. " (" .. ArenaConfig.formatKDR(stats.totalKills, stats.totalDeaths) .. ")\n"
		msg = msg .. "Arena Points: " .. stats.arenaPoints .. "\n"
		msg = msg .. "Streak: " .. stats.winStreak .. " (Best: " .. stats.bestStreak .. ")"
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)

	elseif action == "setmmr" then
		-- Set a player's MMR (for testing)
		local targetName = args[2]
		local newMMR = tonumber(args[3])
		if not targetName or not newMMR then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Usage: !arena-admin setmmr <player> <mmr>")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Player not online.")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `mmr` = %d WHERE `player_id` = %d",
			newMMR, target:getGuid()
		))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			"[Arena Admin] Set " .. target:getName() .. "'s MMR to " .. newMMR)

	elseif action == "addpoints" then
		-- Give arena points
		local targetName = args[2]
		local points = tonumber(args[3])
		if not targetName or not points then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Usage: !arena-admin addpoints <player> <points>")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Player not online.")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `arena_points` = `arena_points` + %d WHERE `player_id` = %d",
			points, target:getGuid()
		))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			"[Arena Admin] Added " .. points .. " Arena Points to " .. target:getName())

	elseif action == "reset" then
		-- Reset a player's arena stats
		local targetName = args[2]
		if not targetName then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Usage: !arena-admin reset <player>")
			return true
		end

		local target = Player(targetName)
		if not target then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena Admin] Player not online.")
			return true
		end

		db.query(string.format(
			"UPDATE `arena_players` SET `mmr` = 1000, `wins` = 0, `losses` = 0, `draws` = 0, " ..
			"`win_streak` = 0, `best_streak` = 0, `total_damage` = 0, `total_healing` = 0, " ..
			"`total_kills` = 0, `total_deaths` = 0, `arena_points` = 0 WHERE `player_id` = %d",
			target:getGuid()
		))
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			"[Arena Admin] Reset all arena stats for " .. target:getName())

	elseif action == "broadcast" then
		-- Send arena announcement
		local message = param:sub(11)  -- remove "broadcast "
		if message and message ~= "" then
			ArenaPvP.broadcast("[Arena] " .. message)
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Arena Admin] Broadcast sent.")
		end

	else
		local msg = "[Arena Admin] Commands:\n"
		msg = msg .. "!arena-admin info              - System status\n"
		msg = msg .. "!arena-admin stats <player>    - Player stats\n"
		msg = msg .. "!arena-admin setmmr <p> <mmr>  - Set MMR\n"
		msg = msg .. "!arena-admin addpoints <p> <n> - Add points\n"
		msg = msg .. "!arena-admin reset <player>    - Reset stats\n"
		msg = msg .. "!arena-admin broadcast <msg>   - Broadcast"
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
	end

	return true
end

arenaAdmin:groupType("gamemaster")
arenaAdmin:register()
