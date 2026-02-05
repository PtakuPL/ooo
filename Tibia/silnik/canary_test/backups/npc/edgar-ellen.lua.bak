local internalNpcName = "Edgar-Ellen"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 0,
	lookBody = 39,
	lookLegs = 99,
	lookFeet = 116,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.edgar_ellen.voice_1" },
	{ i18nKey = "npc.edgar_ellen.voice_2" },
	{ i18nKey = "npc.edgar_ellen.voice_3" },
	{ i18nKey = "npc.edgar_ellen.voice_4" },
	{ i18nKey = "npc.edgar_ellen.voice_5" },
	{ i18nKey = "npc.edgar_ellen.voice_6" },
	{ i18nKey = "npc.edgar_ellen.voice_7" },
	{ i18nKey = "npc.edgar_ellen.voice_8" },
	{ i18nKey = "npc.edgar_ellen.voice_9" },
	{ i18nKey = "npc.edgar_ellen.voice_10" },
	{ i18nKey = "npc.edgar_ellen.voice_11" },
	{ i18nKey = "npc.edgar_ellen.voice_12" },
	{ i18nKey = "npc.edgar_ellen.voice_13" },
	{ i18nKey = "npc.edgar_ellen.voice_14" },
	{ i18nKey = "npc.edgar_ellen.voice_15" },
	{ i18nKey = "npc.edgar_ellen.voice_16" },
	{ i18nKey = "npc.edgar_ellen.voice_17" },
	{ i18nKey = "npc.edgar_ellen.voice_18" },
	{ i18nKey = "npc.edgar_ellen.voice_19" },
	{ i18nKey = "npc.edgar_ellen.voice_20" },
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

keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.edgar_ellen.stdmod_1" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.edgar_ellen.stdmod_2" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.edgar_ellen.stdmod_3" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.edgar_ellen.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.edgar_ellen.stdmod_5" }) -- Need to add the rest in a second delayed message --It is my duty to see to it that the words of mighty poets all over Tibia are spread and carried with the heart and prowess they deserve.

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.edgar_ellen.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.edgar_ellen.farewell_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
