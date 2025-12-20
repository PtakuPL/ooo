local internalNpcName = "Stricken Soul"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 48,
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

	if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline) < 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.stricken_soul.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.stricken_soul.greet_msg_2")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local playerName = player:getName()

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_1")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, playerName) then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.multi_9")
			player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline, 1)
			npcHandler:setTopic(playerId, 0)
		end
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_3")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
