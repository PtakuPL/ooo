local internalNpcName = "A Frog"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 224,
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

keywordHandler:addKeyword({ "prince" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_1" })
keywordHandler:addKeyword({ "princess" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_2" })
keywordHandler:addKeyword({ "kiss" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_3" })
keywordHandler:addKeyword({ "talk" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_4" })
keywordHandler:addKeyword({ "frog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_5" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_6" })
keywordHandler:addKeyword({ "pyrale" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_7" })
keywordHandler:addKeyword({ "ribbit" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_frog.stdmod_8" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_frog.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.a_frog.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.a_frog.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
