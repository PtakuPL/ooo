local internalNpcName = "Chavis"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 96,
	lookBody = 43,
	lookLegs = 20,
	lookFeet = 76,
	lookAddons = 2,
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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- START TASK
	if MsgContains(message, "food") then
		if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.chavis.say_1", "npc.chavis.say_2", "npc.chavis.say_3"}, 10)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission) == 1 then
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) < 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_1")
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) >= 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_2")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(21291, 5) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_3")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count, player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Count) - 5)
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Mission, -1)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Door) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Door, 1)
			end
			local currentVotingPoints = player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints)
			if currentVotingPoints == -1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, 1)
			else
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, currentVotingPoints + 1)
			end
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "root") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_5")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "magistrate") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chavis.say_6")
	elseif MsgContains(message, "rathleton") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.chavis.say_4", "npc.chavis.say_5"}, 10)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.chavis.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.chavis.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
