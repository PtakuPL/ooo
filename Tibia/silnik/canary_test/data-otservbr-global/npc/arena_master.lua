local internalNpcName = "Arena Master"
local npcType = Game.createNpcType("Arena Master")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 160,
	lookHead = 114,
	lookBody = 119,
	lookLegs = 114,
	lookFeet = 114,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

-- Arena mode info table
local modeInfo = {
	{ name = "1v1", id = Arena.MODE_1V1, label = "1v1 Duel", desc = "A duel between two warriors. 5 minute time limit." },
	{ name = "2v2", id = Arena.MODE_2V2, label = "2v2 Team", desc = "Two teams of two. 7 minute time limit." },
	{ name = "3v3", id = Arena.MODE_3V3, label = "3v3 Team", desc = "Two teams of three. 10 minute time limit." },
	{ name = "ffa", id = Arena.MODE_FFA, label = "Free For All", desc = "Every player for themselves! 5 minute limit." },
	{ name = "lms", id = Arena.MODE_LMS, label = "Last Man Standing", desc = "No respawns. Last one alive wins. 15 minutes." },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Greeting response
	if MsgContains(message, "arena") or MsgContains(message, "fight") then
		local msg = "Welcome to the {Arena}! I can help you {join} a match, check your {stats}, view the {ranking}, or see available {modes}. What would you like?"
		npcHandler:say(msg, npc, creature)
		npcHandler:setTopic(playerId, 1)
		return true
	end

	-- Show available modes
	if MsgContains(message, "modes") or MsgContains(message, "list") then
		local msg = "Available arena modes:\n"
		for _, mode in ipairs(modeInfo) do
			local qSize = Arena.getQueueSize(mode.id)
			msg = msg .. "- {" .. mode.name .. "}: " .. mode.label .. " (" .. qSize .. " in queue)\n"
		end
		msg = msg .. "Say 'join <mode>' to queue up!"
		npcHandler:say(msg, npc, creature)
		return true
	end

	-- Join queue
	if MsgContains(message, "join") then
		local modeName = nil
		for _, mode in ipairs(modeInfo) do
			if MsgContains(message, mode.name) then
				modeName = mode
				break
			end
		end

		if not modeName then
			npcHandler:say("Which mode would you like to join? Say 'join' followed by: 1v1, 2v2, 3v3, ffa, or lms.", npc, creature)
			return true
		end

		if player:arenaIsInArena() then
			npcHandler:say("You are already fighting in the arena! Finish your current match first.", npc, creature)
			return true
		end

		if player:arenaIsInQueue() then
			npcHandler:say("You are already in a queue! Say 'leave' to exit the queue first.", npc, creature)
			return true
		end

		if player:getLevel() < 50 then
			npcHandler:say("You need at least level 50 to enter the arena. Come back when you are stronger!", npc, creature)
			return true
		end

		local success = player:arenaJoinQueue(modeName.id)
		if success then
			npcHandler:say("You have joined the " .. modeName.label .. " queue! I will notify you when a match is found. Good luck, warrior!", npc, creature)
		else
			npcHandler:say("Something went wrong. Please try again later.", npc, creature)
		end
		return true
	end

	-- Leave queue
	if MsgContains(message, "leave") or MsgContains(message, "quit") then
		if not player:arenaIsInQueue() then
			npcHandler:say("You are not in any queue right now.", npc, creature)
			return true
		end

		local success = player:arenaLeaveQueue()
		if success then
			npcHandler:say("You have left the arena queue.", npc, creature)
		else
			npcHandler:say("Failed to leave the queue. Please try again.", npc, creature)
		end
		return true
	end

	-- Show stats
	if MsgContains(message, "stats") or MsgContains(message, "score") then
		local stats = player:arenaGetStats()
		if not stats then
			npcHandler:say("You haven't participated in any arena matches yet. Join a match to start building your record!", npc, creature)
			return true
		end

		local wr = (stats.wins + stats.losses > 0) and math.floor(stats.wins / (stats.wins + stats.losses) * 100) or 0
		local msg = "Your Arena Stats:\n"
		msg = msg .. "MMR: " .. stats.mmr .. " | Arena Points: " .. stats.arenaPoints .. "\n"
		msg = msg .. "Record: " .. stats.wins .. "W / " .. stats.losses .. "L / " .. stats.draws .. "D (" .. wr .. "%%)\n"
		msg = msg .. "Win Streak: " .. stats.winStreak .. " (Best: " .. stats.bestStreak .. ")\n"
		msg = msg .. "Total K/D: " .. stats.totalKills .. "/" .. stats.totalDeaths
		npcHandler:say(msg, npc, creature)
		return true
	end

	-- Show ranking
	if MsgContains(message, "ranking") or MsgContains(message, "rank") or MsgContains(message, "top") then
		local entries = Arena.getTopRanking(10, 0)
		if not entries or #entries == 0 then
			npcHandler:say("The arena ranking is empty. Be the first to claim glory!", npc, creature)
			return true
		end

		local msg = "Top 10 Arena Warriors:\n"
		for i, entry in ipairs(entries) do
			msg = msg .. i .. ". " .. entry.name .. " - MMR: " .. entry.mmr .. " (" .. entry.wins .. "W/" .. entry.losses .. "L)\n"
		end
		npcHandler:say(msg, npc, creature)
		return true
	end

	-- Show status
	if MsgContains(message, "status") then
		local state = player:arenaGetState()
		local stateStr = "Idle"
		if state == Arena.STATE_IN_QUEUE then
			stateStr = "In Queue"
		elseif state == Arena.STATE_IN_MATCH then
			stateStr = "In Match"
		end

		local activeMatches = Arena.getActiveMatchCount()
		local msg = "Your status: " .. stateStr .. "\n"
		msg = msg .. "Active matches on server: " .. activeMatches
		npcHandler:say(msg, npc, creature)
		return true
	end

	-- Job/info
	if MsgContains(message, "job") or MsgContains(message, "help") then
		npcHandler:say("I am the Arena Master! I manage the PvP arena where warriors can test their skills against each other. Say {arena} to get started!", npc, creature)
		return true
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, warrior! Are you here for the {arena}? I can help you find worthy opponents!")
npcHandler:setMessage(MESSAGE_FAREWELL, "May your blade stay sharp! Come back anytime for more battles!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Leaving so soon? The arena awaits!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcType:register(npcConfig)
