local internalNpcName = "Phillip"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 116,
	lookBody = 54,
	lookLegs = 68,
	lookFeet = 76,
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

keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_1" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_3" })
keywordHandler:addKeyword({ "teacher" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_4" })
keywordHandler:addKeyword({ "loremaster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_5" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_6" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_7" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_8" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_9" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_10" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_11" })
keywordHandler:addKeyword({ "thank you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_12" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_13" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_14" })
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_15" })
keywordHandler:addKeyword({ "rumour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_16" })
keywordHandler:addKeyword({ "gossip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_17" })
keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_18" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_19" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_20" })
keywordHandler:addKeyword({ "rebellion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_21" })
keywordHandler:addKeyword({ "in tod we trust" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_22" })
keywordHandler:addKeyword({ "lugri" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_23" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_24" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.phillip.stdmod_25" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.phillip.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.phillip.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.phillip.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
