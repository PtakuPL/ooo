local internalNpcName = "Kazzan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 95,
	lookBody = 13,
	lookLegs = 14,
	lookFeet = 76,
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

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 35 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.ScaredKazzan) ~= 1 and player:getOutfit().lookType == 65 then
		player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.ScaredKazzan, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.say_2")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) < 1 then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.MaridDoor) < 1 and player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.EfreetDoor) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.say_3")
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 1 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.multi_4")
		npcHandler:setTopic(playerId, 2)
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.multi_2")
		if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart) <= 0 then
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
		end
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest, 1)
		-- Entregando
	elseif player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kazzan.say_4")
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest, player:getStorageValue(Storage.Quest.U8_1.TibiaTales.ToAppeaseTheMightyQuest) + 1)
		player:addItem(3035, 20)
	end

	return true
end

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
