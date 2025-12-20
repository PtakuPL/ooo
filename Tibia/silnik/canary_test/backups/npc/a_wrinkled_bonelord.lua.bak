local internalNpcName = "A Wrinkled Bonelord"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 17,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "485611800364197." },
	{ text = "78572611857643646724." },
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

keywordHandler:addKeyword({ "death" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_1" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_3" })
keywordHandler:addKeyword({ "library" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_4" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_5" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_6" })
keywordHandler:addKeyword({ "cyclops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_7" })
keywordHandler:addKeyword({ "elves" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_8" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_9" })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_10" })
keywordHandler:addKeyword({ "numbers" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_11" })
keywordHandler:addKeyword({ "books" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_12" })
keywordHandler:addKeyword({ "0" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_13" })
keywordHandler:addKeyword({ "469" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_14" })
keywordHandler:addKeyword({ "orcs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_15" })
keywordHandler:addKeyword({ "minotaurs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_16" })
keywordHandler:addKeyword({ "humans" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_17" })
keywordHandler:addKeyword({ "eyes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_18" })
keywordHandler:addKeyword({ "bonelord" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_wrinkled_bonelord.stdmod_19" })
keywordHandler:addKeyword(
	{ "language" },
	StdModule.say,
	{ npcHandler = npcHandler, text = "Our language is beyond comprehension by your lesser beings. It heavily relies on mathemagic. Your brain is not suited for the mathemagical processing necessary to understand our language.To decipher even our most basic texts, it would need a genius that can calculate numbers within seconds in his brain. " }
)

npcHandler:setMessage(MESSAGE_GREET, "What is this? An optically challenged entity called |PLAYERNAME|. How fascinating!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Wait right there. I will eat you after writing down what I found out.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Wait right there. I will eat you after writing down what I found out.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
