local internalNpcName = "Jack Drone"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 93,
	lookHead = 19,
	lookBody = 69,
	lookLegs = 125,
	lookFeet = 50,
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

local travelNode = keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_drone.stdmod_1" })
travelNode:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, level = 0, cost = 0, destination = Position(32310, 32218, 5) })
travelNode:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, reset = true, i18nKey = "npc.jack_drone.stdmod_2" })

keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_drone.stdmod_3" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_drone.stdmod_4" })
keywordHandler:addKeyword({ "travel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_drone.stdmod_5" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_drone.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.jack_drone.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.jack_drone.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
