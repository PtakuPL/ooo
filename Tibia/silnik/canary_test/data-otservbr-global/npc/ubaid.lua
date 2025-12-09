local internalNpcName = "Ubaid"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 51,
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_16")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_17")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting) == -1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_15")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.EfreetDoor) ~= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_2")
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_3")
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
	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_13")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "kazzan") and npcHandler:getTopic(playerId) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_12")
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest, player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) + 1)
	end

	if MsgContains(message, "passage") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.EfreetDoor) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_10")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_4")
		end
	elseif MsgContains(message, "here") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_8")
		npcHandler:setTopic(playerId, 1)
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_6")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_6")
				npcHandler:setTopic(playerId, 2)
			end
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_7")
			npcHandler:setTopic(playerId, 3)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.multi_3")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.EfreetDoor, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ubaid.say_9")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell human!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Farewell human!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
