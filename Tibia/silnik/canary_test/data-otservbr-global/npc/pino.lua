local internalNpcName = "Pino"
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
	lookHead = 115,
	lookBody = 0,
	lookLegs = 67,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.pino.voice_1" },
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
local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function addTravelKeyword(keyword, text, cost, destination, condition, action)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pino.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pino.stdmod_3", i18nArgs = { text }, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, i18nKey = "npc.pino.keyword_1", cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pino.stdmod_3", reset = true })
end

addTravelKeyword("farmine", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("zao", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("darashia", "Darashia on Darama", 40, Position(33270, 32441, 6))
addTravelKeyword("darama", "Darashia on Darama", 40, Position(33270, 32441, 6))
addTravelKeyword("kazordoon", "Kazordoon", 70, Position(32588, 31941, 0))
addTravelKeyword("kazor", "Kazordoon", 70, Position(32588, 31941, 0))
addTravelKeyword("femor hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("svargrond", "Svargrond", 60, Position(32253, 31097, 4))
addTravelKeyword("issavi", "Issavi", 100, Position(33957, 31515, 0))
addTravelKeyword("marapur", "Marapur", 70, Position(33805, 32767, 2))

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.pino.greet_msg_1")
keywordHandler:addKeyword({ "fly" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pino.stdmod_4" })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.pino.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.pino.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
