local internalNpcName = "Frafnar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 58,
	lookBody = 119,
	lookLegs = 81,
	lookFeet = 114,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DefaultStart, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.multi_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.frafnar.say_4")
		player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake, 3)
		player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DoorWestMine, 1)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.frafnar.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.frafnar.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.frafnar.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
