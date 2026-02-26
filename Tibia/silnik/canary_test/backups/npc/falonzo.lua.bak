local internalNpcName = "Falonzo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 39,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_1",
})

keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_2",
})

keywordHandler:addKeyword({ "place" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_7",
})

keywordHandler:addKeyword({ "anomaly" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_8",
})

keywordHandler:addKeyword({ "plane" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_3",
})

keywordHandler:addKeyword({ "intruders" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_4",
})

keywordHandler:addKeyword({ "dragged" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_9",
})

keywordHandler:addKeyword({ "sinister" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_10",
})
keywordHandler:addAliasKeyword({ "changed" })

keywordHandler:addKeyword({ "lost" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_5",
})

keywordHandler:addKeyword({ "boundaries" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_11",
})

keywordHandler:addKeyword({ "attention" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_6",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.falonzo.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.falonzo.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.falonzo.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
