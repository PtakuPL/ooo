local internalNpcName = "Elyen Ravenlock"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 58,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.elyen_ravenlock.voice_1" },
	{ i18nKey = "npc.elyen_ravenlock.voice_2" },
	{ i18nKey = "npc.elyen_ravenlock.voice_3" },
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

	if (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission60) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission61) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission60) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.say_2")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission45, 1)
		npcHandler:setTopic(playerId, 2)
	elseif (MsgContains(message, "artefact") or MsgContains(message, "yes")) and npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission60) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission61) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_9")
		npcHandler:setTopic(playerId, 3)
	elseif (MsgContains(message, "agreed") or MsgContains(message, "yes")) and npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission60) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission61) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_6")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission61, 1)
		player:addItem(18932, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission66) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission67) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.say_3")
		npcHandler:setTopic(playerId, 4)
	elseif (MsgContains(message, "yes")) and npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission66) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission67) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.multi_2")
		player:removeItem(18932, 1)
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission67, 1)
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elyen_ravenlock.say_4")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.elyen_ravenlock.greet_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
