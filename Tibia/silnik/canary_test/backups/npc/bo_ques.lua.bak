local internalNpcName = "Bo'Ques"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 80,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.bo_ques.voice_1" },
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

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not MsgContains(message, "djanni'hah") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_13")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting) == -1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_11")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_2")
	else
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission01)
	if MsgContains(message, "recipe") or MsgContains(message, "mission") then
		if missionProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_9")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_3")
		end
	elseif MsgContains(message, "cookbook") then
		if missionProgress == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_7")
		elseif missionProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_4")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_5")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_5")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Start, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission01, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_6")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if not player:removeItem(3234, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_7")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.multi_3")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission01, 2)
			player:addItem(3029, 3)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bo_ques.say_8")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Greeting
keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye. I am sure you will come back for more. They all do.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Goodbye. I am sure you will come back for more. They all do.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
