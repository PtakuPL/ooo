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

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Hm." },
	{ text = "Yes. I listen, master." },
	{ text = "I understand." },
	{ text = "Not yet, my brothers. Wait." },
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_7")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission45, 1)
		npcHandler:setTopic(playerId, 0)
	elseif (MsgContains(message, "scroll") or MsgContains(message, "mission")) and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif (MsgContains(message, "yes")) and npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.say_3")
		npcHandler:setTopic(playerId, 3)
	elseif (MsgContains(message, "bronze")) and npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.say_4")
		npcHandler:setTopic(playerId, 4)
	elseif (MsgContains(message, "floating")) and npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.say_5")
		npcHandler:setTopic(playerId, 5)
	elseif (MsgContains(message, "Takesha Antishu")) and npcHandler:getTopic(playerId) == 5 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission48) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oblivion.multi_3")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission49, 1)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "A shadow preceded you. You wish?")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
