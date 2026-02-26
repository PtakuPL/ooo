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
		npcHandler:setMessage(MESSAGE_GREET, "This place is... haunted... heed my warning... there are... ghooooooosts here...! Why are you giving me that... look? I am certain, there aaaaaaare ghosts here - I've seen them! Do you believe me?")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Gree... tings.")
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
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_4")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_5")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, playerName) then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.stricken_soul.say_6", { playerName } }, "npc.stricken_soul.say_7", "npc.stricken_soul.say_8", "npc.stricken_soul.say_9", "npc.stricken_soul.say_10", "npc.stricken_soul.say_11", "npc.stricken_soul.say_12", { "npc.stricken_soul.say_13", { playerName } } })
			player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.HauntedHouse.Questline, 1)
			npcHandler:setTopic(playerId, 0)
		end
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.stricken_soul.say_14")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
