local internalNpcName = "Melian"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 146,
	lookHead = 97,
	lookBody = 22,
	lookLegs = 45,
	lookFeet = 57,
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

-- Travel
local function addTravelKeyword(keyword, text, cost, destination)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_1", i18nArgs = { text }, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_2", reset = true })
end

addTravelKeyword("darashia", "Darashia on Darama", 60, Position(33270, 32441, 6))
addTravelKeyword("darama", "Darashia on Darama", 60, Position(33270, 32441, 6))
addTravelKeyword("svargrond", "Svargrond", 60, Position(32253, 31097, 4))
addTravelKeyword("femor hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("edron", "Edron", 60, Position(33193, 31784, 3))
addTravelKeyword("kazordoon", "Kazordoon", 70, Position(32588, 31941, 0))
addTravelKeyword("kazor", "Kazordoon", 70, Position(32588, 31941, 0))
addTravelKeyword("issavi", "Issavi", 100, Position(33957, 31515, 0))
addTravelKeyword("marapur", "Marapur", 70, Position(33805, 32767, 2))

-- Basic
keywordHandler:addKeyword({ "lizard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_3" })
keywordHandler:addKeyword({ "zao" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_4" })
keywordHandler:addKeyword({ "fly" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_5" })
keywordHandler:addKeyword({ "service" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_6" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_8" })
keywordHandler:addKeyword({ "mountain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_9" })
keywordHandler:addKeyword({ "carpet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_10" })
keywordHandler:addKeyword({ "orc" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_11" })
keywordHandler:addKeyword({ "dwarf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_12" })
keywordHandler:addKeyword({ "steamboat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_13" })
keywordHandler:addKeyword({ "farmine" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_14" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_15" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_16" })
keywordHandler:addKeyword({ "ride" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_17" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_18" })
keywordHandler:addKeyword({ "transport" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_19" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_20" })
keywordHandler:addKeyword({ "continent" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_21" })
keywordHandler:addKeyword({ "femur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_22" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.melian.stdmod_23" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.melian.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.melian.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.melian.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
