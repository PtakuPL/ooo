-- Arena PvP TalkAction
-- Commands: !arena [join|leave|stats|ranking|help] [mode]
-- Modes: 1v1, 2v2, 3v3, ffa, ctf, koth, lms, tournament

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

local modeNames = {
	[Arena.MODE_1V1] = "1v1 Duel",
	[Arena.MODE_2V2] = "2v2 Team",
	[Arena.MODE_3V3] = "3v3 Team",
	[Arena.MODE_FFA] = "Free For All",
	[Arena.MODE_CTF] = "Capture The Flag",
	[Arena.MODE_KOTH] = "King of the Hill",
	[Arena.MODE_LMS] = "Last Man Standing",
	[Arena.MODE_TOURNAMENT] = "Tournament",
}

local function showHelp(player)
	local msg = "[Arena PvP] Available commands:\n"
	msg = msg .. "!arena join <mode>  - Join matchmaking queue\n"
	msg = msg .. "!arena leave        - Leave the queue\n"
	msg = msg .. "!arena stats        - View your arena stats\n"
	msg = msg .. "!arena ranking      - View top 20 players\n"
	msg = msg .. "!arena history      - View your match history\n"
	msg = msg .. "!arena modes        - List available modes\n"
	msg = msg .. "!arena status       - Show queue/match info\n"
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showModes(player)
	local msg = "[Arena PvP] Available modes:\n"
	for name, id in pairs(modeMap) do
		local qSize = Arena.getQueueSize(id)
		msg = msg .. "  " .. name .. " (" .. (modeNames[id] or "?") .. ") - " .. qSize .. " in queue\n"
	end
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showStats(player)
	local stats = player:arenaGetStats()
	if not stats then
		player:sendTextMessage(MESSAGE_FAILURE, "[Arena] No arena profile found yet. Join a match to create one!")
		return
	end

	local wr = (stats.wins + stats.losses > 0) and math.floor(stats.wins / (stats.wins + stats.losses) * 100) or 0
	local kdr = (stats.totalDeaths > 0) and string.format("%.2f", stats.totalKills / stats.totalDeaths) or tostring(stats.totalKills)

	local msg = "[Arena PvP] Your Stats:\n"
	msg = msg .. "MMR: " .. stats.mmr .. " | Points: " .. stats.arenaPoints .. "\n"
	msg = msg .. "Record: " .. stats.wins .. "W / " .. stats.losses .. "L / " .. stats.draws .. "D (" .. wr .. "% WR)\n"
	msg = msg .. "Streak: " .. stats.winStreak .. " (Best: " .. stats.bestStreak .. ")\n"
	msg = msg .. "K/D: " .. stats.totalKills .. "/" .. stats.totalDeaths .. " (" .. kdr .. " KDR)\n"
	msg = msg .. "Total Damage: " .. stats.totalDamage .. " | Total Healing: " .. stats.totalHealing
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showRanking(player)
	local entries = Arena.getTopRanking(20, 0)
	if not entries or #entries == 0 then
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, "[Arena] No ranking data available yet.")
		return
	end

	local msg = "[Arena PvP] Top 20 Ranking:\n"
	msg = msg .. string.format("%-4s %-20s %-6s %-5s %-5s %-6s\n", "#", "Name", "MMR", "W", "L", "Streak")
	for i, entry in ipairs(entries) do
		msg = msg .. string.format("%-4d %-20s %-6d %-5d %-5d %-6d\n",
			i, entry.name, entry.mmr, entry.wins, entry.losses, entry.bestStreak)
	end
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

local function showHistory(player)
	local history = Arena.getPlayerHistory(player:getGuid(), 10)
	if not history or #history == 0 then
		player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, "[Arena] No match history yet.")
		return
	end

	local msg = "[Arena PvP] Last 10 Matches:\n"
	for _, match in ipairs(history) do
		local result = (match.winnerTeam == match.playerTeam) and "WIN" or "LOSS"
		local sign = (match.mmrChange >= 0) and "+" or ""
		msg = msg .. string.format("[%s] %s | K/D: %d/%d | MMR: %s%d | %s\n",
			match.modeName, result, match.kills, match.deaths, sign, match.mmrChange,
			os.date("%m/%d %H:%M", match.startedAt))
	end
	player:sendTextMessage(MESSAGE_HOTKEY_PRESSED, msg)
end

function arena.onSay(player, words, param)
	if not player then
		return false
	end

	local args = param:lower():split(" ")
	local action = args[1] or "help"

	if action == "join" then
		local modeName = args[2]
		if not modeName then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] Usage: !arena join <mode>. Type '!arena modes' for available modes.")
			return true
		end

		local modeId = modeMap[modeName]
		if not modeId then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] Unknown mode '" .. modeName .. "'. Type '!arena modes' for available modes.")
			return true
		end

		if player:arenaIsInArena() then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] You are already in a match!")
			return true
		end

		if player:arenaIsInQueue() then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] You are already in the queue! Use '!arena leave' first.")
			return true
		end

		if player:getLevel() < 50 then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] You need at least level 50 to join the arena.")
			return true
		end

		local success = player:arenaJoinQueue(modeId)
		if success then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Arena] You joined the " .. (modeNames[modeId] or modeName) .. " queue! Searching for opponents...")
		else
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] Failed to join queue. Try again later.")
		end

	elseif action == "leave" then
		if not player:arenaIsInQueue() then
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] You are not in any queue.")
			return true
		end

		local success = player:arenaLeaveQueue()
		if success then
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Arena] You left the queue.")
		else
			player:sendTextMessage(MESSAGE_FAILURE, "[Arena] Failed to leave queue.")
		end

	elseif action == "stats" then
		showStats(player)

	elseif action == "ranking" or action == "rank" or action == "top" then
		showRanking(player)

	elseif action == "history" then
		showHistory(player)

	elseif action == "modes" then
		showModes(player)

	elseif action == "status" then
		player:arenaSendStatus()

	else
		showHelp(player)
	end

	return true
end

arena:groupType("normal")
arena:register()
