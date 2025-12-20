local internalNpcName = "Kawill"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 66,
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

-- Kawill Blessing
local blessKeyword = keywordHandler:addKeyword({ "spark of the phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_1" }, function(player)
	return player:getStorageValue(Storage.KawillBlessing) ~= 1
end)
blessKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_2", reset = true }, nil, function(player)
	player:setStorageValue(Storage.KawillBlessing, 1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
blessKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_3", reset = true })
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addAliasKeyword({ "phoenix" })

-- Basic
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_5" })
keywordHandler:addKeyword({ "geomancer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_6" })
keywordHandler:addKeyword({ "life" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_8" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_9" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_10" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_11" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_12" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_13" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_14" })
keywordHandler:addKeyword({ "kazordoon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_15" })
keywordHandler:addKeyword({ "bezil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_16" })
keywordHandler:addKeyword({ "nezil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_17" })
keywordHandler:addKeyword({ "duria" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_18" })
keywordHandler:addKeyword({ "etzel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_19" })
keywordHandler:addKeyword({ "jimbin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_20" })
keywordHandler:addKeyword({ "kroox" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_21" })
keywordHandler:addKeyword({ "maryza" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_22" })
keywordHandler:addKeyword({ "uzgod" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_23" })
keywordHandler:addKeyword({ "kruzak" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_24" })
keywordHandler:addKeyword({ "emperor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_25" })
keywordHandler:addKeyword({ "durin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_26" })
keywordHandler:addKeyword({ "fire" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_27" })
keywordHandler:addKeyword({ "earth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_28" })
keywordHandler:addKeyword({ "the big old one" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.kawill.stdmod_29" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.kawill.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.kawill.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.kawill.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
