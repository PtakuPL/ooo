local internalNpcName = "Umar"
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_15")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting) == -1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_13")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor) ~= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_11")
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_2")
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

	-- To Appease the Mighty Quest
	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_8")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "kazzan") and npcHandler:getTopic(playerId) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_6")
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest, player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) + 1)
	end

	if MsgContains(message, "passage") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_4")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_3")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.EfreetDoor) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_4")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_5")
				npcHandler:setTopic(playerId, 0)
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.multi_2")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.umar.say_7")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Greeting
keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.umar.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.umar.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
