local internalNpcName = "Gelidrazah'S Thirst"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 100000
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookTypeEx = 10031,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
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

	if MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.multi_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.say_1")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "Tahmehe") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.say_2")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "Ishara") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.say_3")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "Svir") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.say_4")
		npcHandler:setTopic(playerId, 0)
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.GelidrazahAccess, 1)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gelidrazahs_thirst.say_5")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gelidrazahs_thirst.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.gelidrazahs_thirst.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gelidrazahs_thirst.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
