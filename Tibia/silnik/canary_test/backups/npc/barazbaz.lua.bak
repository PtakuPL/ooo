local internalNpcName = "Barazbaz"
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
	lookHead = 76,
	lookBody = 55,
	lookLegs = 49,
	lookFeet = 95,
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

	if MsgContains(message, "ritual") and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission06) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission07) < 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.barazbaz.say_1", "npc.barazbaz.say_2", "npc.barazbaz.say_3", "npc.barazbaz.say_4", "npc.barazbaz.say_5"}, 10)
		player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission07, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "abandoned sewers") and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission08) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission09) < 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.barazbaz.say_6", "npc.barazbaz.say_7", "npc.barazbaz.say_8", "npc.barazbaz.say_9", "npc.barazbaz.say_10", "npc.barazbaz.say_11"}, 10)
		player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission09, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "notebook") and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission11) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission12) < 1 and player:getItemCount(11450) >= 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.barazbaz.say_12", "npc.barazbaz.say_13"}, 10)
		player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission12, 1)
		doPlayerRemoveItem(creature, 11450, 1)
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barazbaz.say_1")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.barazbaz.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
