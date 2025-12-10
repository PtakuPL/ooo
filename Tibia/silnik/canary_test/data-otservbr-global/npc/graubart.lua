local internalNpcName = "Graubart"
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
	lookHead = 25,
	lookBody = 107,
	lookLegs = 57,
	lookFeet = 114,
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

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_1" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_2" })
keywordHandler:addKeyword({ "seahawk" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_3" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_4" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_5" })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_6" })
keywordHandler:addKeyword({ "races" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_7" })
keywordHandler:addKeyword({ "water" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_8" })
keywordHandler:addKeyword({ "marlene" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_9" })
keywordHandler:addKeyword({ "bruno" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.graubart.stdmod_10" })

npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye and don't forget me!")
npcHandler:setMessage(MESSAGE_GREET, "Ahoi, young man |PLAYERNAME|. Looking for work on my ship?")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
