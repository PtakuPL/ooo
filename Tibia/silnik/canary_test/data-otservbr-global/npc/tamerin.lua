local internalNpcName = "Tamerin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 58,
	lookBody = 119,
	lookLegs = 120,
	lookFeet = 121,
	lookAddons = 3,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 30 then
		npcHandler:setMessage(MESSAGE_GREET, "Have you the {animal cure}?")
	elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 31 then
		npcHandler:setMessage(MESSAGE_GREET, "Have you killed {morik}?")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Hello, what brings you here?")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.multi_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "animal cure") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 30 and player:removeItem(8819, 1) then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 31)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MorikSummon, 0)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 4) -- StorageValue for Questlog "Mission 05: Food or Fight"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_2")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_3")
		end
	elseif MsgContains(message, "cattle") then
		if npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 6) -- StorageValue for Questlog "Mission 05: Food or Fight"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "warbeast") then
		if npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus, 2)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 7) -- StorageValue for Questlog "Mission 05: Food or Fight"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "morik") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 31 and player:removeItem(8820, 1) then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 32)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 5) -- StorageValue for Questlog "Mission 05: Food or Fight"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_6")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_7")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 30)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 3) -- StorageValue for Questlog "Mission 05: Food or Fight"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamerin.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
