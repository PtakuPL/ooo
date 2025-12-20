local internalNpcName = "Tomruk The Ruddy"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 553,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.tomruk_the_ruddy.voice_1" },
	{ i18nKey = "npc.tomruk_the_ruddy.voice_2" },
	{ i18nKey = "npc.tomruk_the_ruddy.voice_3" },
	{ i18nKey = "npc.tomruk_the_ruddy.voice_4" },
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

	if (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission35) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission36) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_15")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission35) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_11")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission36, 1)
		player:addItem(19100, 2)
		npcHandler:setTopic(playerId, 0)
	elseif (MsgContains(message, "scroll") or MsgContains(message, "mission") or MsgContains(message, "blood")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission37) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission38) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.say_1")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission37) == 1 then
		if player:getItemCount(19102) >= 1 and player:getItemCount(19101) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_7")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission38, 1)
			player:removeItem(19101, 1)
			player:removeItem(19102, 1)
			player:addItem(19133, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission40) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission41) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.say_3")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission40) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.multi_4")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission41, 1)
		npcHandler:setTopic(playerId, 0)
	elseif (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission41) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission42) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.say_4")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission41) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tomruk_the_ruddy.say_5")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission42, 1)
		player:addItem(18933, 1)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello hello! Always good to see fresh blood! What brings you here?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
