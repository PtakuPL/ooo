local internalNpcName = "Oblivion"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 552,
}

npcConfig.flags = {
	floorchange = false,
}

-- Load NPC helper library
dofile(CORE_DIRECTORY .. "/libs/npc/i18n.lua")

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = NPC_LIB.i18n.get("npc.oblivion.voice_hm") },
	{ text = NPC_LIB.i18n.get("npc.oblivion.voice_listen") },
	{ text = NPC_LIB.i18n.get("npc.oblivion.voice_understand") },
	{ text = NPC_LIB.i18n.get("npc.oblivion.voice_wait") },
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

	if (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission45) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.quest_ask")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) == 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.oblivion.quest_start_1",
			"npc.oblivion.quest_start_2",
			"npc.oblivion.quest_start_3",
			"npc.oblivion.quest_start_4",
		})
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission45, 1)
		npcHandler:setTopic(playerId, 0)
	elseif (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.found_ask")
		npcHandler:setTopic(playerId, 2)
	elseif (MsgContains(message, "yes")) and npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.tell_colour")
		npcHandler:setTopic(playerId, 3)
	elseif (MsgContains(message, "bronze")) and npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.bronze_correct")
		npcHandler:setTopic(playerId, 4)
	elseif (MsgContains(message, "floating")) and npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.floating_correct")
		npcHandler:setTopic(playerId, 5)
	elseif (MsgContains(message, "Takesha Antishu")) and npcHandler:getTopic(playerId) == 5 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.oblivion.takesha_correct_1",
			"npc.oblivion.takesha_correct_2",
			"npc.oblivion.takesha_correct_3",
		})
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49, 1)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, NPC_LIB.i18n.get("npc.oblivion.greet"))
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
