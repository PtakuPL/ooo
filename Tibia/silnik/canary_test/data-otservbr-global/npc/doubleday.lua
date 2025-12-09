local internalNpcName = "Doubleday"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 20,
	lookBody = 57,
	lookLegs = 39,
	lookFeet = 20,
	lookAddons = 0,
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

	if MsgContains(message, "experiment") then
		if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_12")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_9")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_1")
			player:addItem(21192, 1)
			player:addItem(21208, 1)
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission, 1)
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.MonoDetector, os.time() + 30 * 60)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_2")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_3")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission, -1)
			local currentVotingPoints = player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints)
			if currentVotingPoints == -1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, 1)
			else
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, currentVotingPoints + 1)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_4")
			player:addItem(21192, 1)
			player:addItem(21208, 1)
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.MonoDetector, os.time() + 30 * 60)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "probe") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_7")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_4")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission, 3)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.OramondTaskProbing, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "exchange") then
		if npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_5")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.Mission) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_6")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "2") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_7")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "1") then
		if npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_8")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "mono detector") then
		if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.Probing.MonoDetector) <= os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.multi_2")
			npcHandler:setTopic(playerId, 9)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.doubleday.say_9")
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello there, hmm just... just wait right there, I'll be with you in a second. Just getting this {experiment} done...")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
