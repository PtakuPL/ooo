local internalNpcName = "Pydar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 95,
	lookBody = 94,
	lookLegs = 132,
	lookFeet = 118,
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

-- Spark of the Phoenix
local blessKeyword = keywordHandler:addKeyword({ "spark of the phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_1" })
blessKeyword:addChildKeyword({ "yes" }, StdModule.bless, { npcHandler = npcHandler, i18nKey = "npc.pydar.keyword_1", cost = "|BLESSCOST|", bless = 3 })
blessKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_2", reset = true })
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addAliasKeyword({ "phoenix" })

-- Basic
keywordHandler:addKeyword({ "gods" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_3" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_4" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_5" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_6" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_7" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_8" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_9" })
keywordHandler:addKeyword({ "life" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_10" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_11" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_12" })
keywordHandler:addKeyword({ "kazordoon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_13" })
keywordHandler:addKeyword({ "the big old one" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_14" })
keywordHandler:addKeyword({ "bezil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_15" })
keywordHandler:addKeyword({ "nezil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_16" })
keywordHandler:addKeyword({ "duria" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_17" })
keywordHandler:addKeyword({ "etzel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_18" })
keywordHandler:addKeyword({ "jimbin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_19" })
keywordHandler:addKeyword({ "kroox" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_20" })
keywordHandler:addKeyword({ "maryza" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_21" })
keywordHandler:addKeyword({ "uzgod" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_22" })
keywordHandler:addKeyword({ "durin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_23" })
keywordHandler:addKeyword({ "fire" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_24" })
keywordHandler:addKeyword({ "keeper" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_25" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_26" })
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_27" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_28" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_29" })
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
	return player:getCondition(CONDITION_FIRE) ~= nil
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_30" })
keywordHandler:addKeyword({ "pilgrimage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_31" })
keywordHandler:addKeyword({ "blessing" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_32" })
keywordHandler:addKeyword({ "pyromancer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pydar.stdmod_33" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.pydar.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.pydar.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.pydar.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
