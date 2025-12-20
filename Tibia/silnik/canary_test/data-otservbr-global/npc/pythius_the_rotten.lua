local internalNpcName = "Pythius The Rotten"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 231,
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

local treasureKeyword = keywordHandler:addKeyword({ "treasure" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_1" })
treasureKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_2", reset = true })
treasureKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_3" })

local offerKeyword = keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_4" }, function(player)
	return player:getLevel() > 99
end)
local mugKeyword = offerKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_5" })
mugKeyword:addChildKeyword({ "golden mug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_6", reset = true }, function(player)
	return player:getItemCount(2903) > 0
end, function(player)
	player:removeItem(2903, 1)
	player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.PythiusTheRotten, os.time() + 180)
end)
mugKeyword:addChildKeyword({ "golden mug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_7", reset = true })
mugKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_8", reset = true })
offerKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_9", reset = true })
keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_10" })

-- Basic keywords
keywordHandler:addKeyword({ "awaited" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_11" })
keywordHandler:addKeyword({ "exchange" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_12" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_13" })
keywordHandler:addKeyword({ "undead" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pythius_the_rotten.stdmod_14" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.pythius_the_rotten.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.pythius_the_rotten.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.pythius_the_rotten.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
