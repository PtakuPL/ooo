local internalNpcName = "A Bearded Woman"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 60,
	lookBody = 22,
	lookLegs = 24,
	lookFeet = 32,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.a_bearded_woman.voice_1" },
	{ i18nKey = "npc.a_bearded_woman.voice_2" },
	{ i18nKey = "npc.a_bearded_woman.voice_3" },
	{ i18nKey = "npc.a_bearded_woman.voice_4" },
	{ i18nKey = "npc.a_bearded_woman.voice_5" },
	{ i18nKey = "npc.a_bearded_woman.voice_6" },
	{ i18nKey = "npc.a_bearded_woman.voice_7" },
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

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_1" })
keywordHandler:addKeyword({ "actor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_2" })
keywordHandler:addKeyword({ "stage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_3" })
keywordHandler:addKeyword({ "kid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_4" })
keywordHandler:addKeyword({ "princess" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_5" })
keywordHandler:addKeyword({ "cell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_7" })
keywordHandler:addKeyword({ "rot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_8" })
keywordHandler:addKeyword({ "pirate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_1",
})
keywordHandler:addKeyword({ "ship" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_2",
})
keywordHandler:addKeyword({ "captain" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_3",
})
keywordHandler:addKeyword({ "plan" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_4",
})
keywordHandler:addKeyword({ "kidnap" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_5",
})
keywordHandler:addKeyword({ "scams" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_6",
})
keywordHandler:addKeyword({ "key" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_7",
})
keywordHandler:addKeyword({ "plundering" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.a_bearded_woman.stdmod_8",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_bearded_woman.greet_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
