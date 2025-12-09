local internalNpcName = "Elliott"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 574,
	lookHead = 114,
	lookBody = 114,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "abandoned sewers") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission05) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_1")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission) < 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_7")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_5")
			if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission04) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission04, 1)
			end
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission, -1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission) < 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_3")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_4")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission, 1)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Door) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Door, 1)
			end
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "ok") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_5")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.TheAncientSewers.Mission, 22)
			local currentVotingPoints = player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints)
			if currentVotingPoints == -1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, 1)
			else
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, currentVotingPoints + 1)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission05) == 1 then
			if npcHandler:getTopic(playerId) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.multi_2")
				player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission06, 1) -- Start mission 6
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elliott.say_6")
			end
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "<nods>")
npcHandler:setMessage(MESSAGE_FAREWELL, "<nods> Yeah.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
