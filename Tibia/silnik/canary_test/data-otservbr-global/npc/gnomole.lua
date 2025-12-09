local internalNpcName = "Gnomole"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 95,
	lookBody = 57,
	lookLegs = 57,
	lookFeet = 114,
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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "tactical") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomole.multi_9")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hi there! I'm ready to brief you with {tactical} advice.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye and take care!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
