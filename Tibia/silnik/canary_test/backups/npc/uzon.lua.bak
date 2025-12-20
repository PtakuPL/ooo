local internalNpcName = "Uzon"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 95,
	lookBody = 4,
	lookLegs = 17,
	lookFeet = 95,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Feel the wind in your hair during one of my carpet rides!" },
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
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, text = text, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, text = "Hold on!", cost = cost, discount = "postman", destination = destination }, nil, action)
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_2", reset = true })
end

addTravelKeyword("eclipse", "Oh no, so the time has come? Do you really want me to fly you to this unholy place?", 110, Position(32659, 31915, 0), function(player)
	return player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) ~= 4 and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) ~= 5
end)
addTravelKeyword("farmine", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("zao", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("edron", "Do you seek a ride to Edron for |TRAVELCOST|?", 60, Position(33193, 31783, 3), nil, function(player)
	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 2 then
		player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 3)
	end
end)
addTravelKeyword("darashia", "Do you seek a ride to Darashia on Darama for |TRAVELCOST|?", 60, Position(33270, 32441, 6))
addTravelKeyword("darama", "Do you seek a ride to Darashia on Darama for |TRAVELCOST|?", 60, Position(33270, 32441, 6))
addTravelKeyword("svargrond", "Do you seek a ride to Svargrond for |TRAVELCOST|?", 60, Position(32253, 31097, 4))
addTravelKeyword("kazordoon", "Do you seek a ride to Kazordoon for |TRAVELCOST|?", 70, Position(32588, 31942, 0))
addTravelKeyword("kazor", "Do you seek a ride to Kazordoon for |TRAVELCOST|?", 70, Position(32588, 31942, 0))
addTravelKeyword("issavi", "Do you seek a ride to Issavi for |TRAVELCOST|?", 100, Position(33957, 31515, 0))

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_3" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_4" })
keywordHandler:addKeyword({ "caliph" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_5" })
keywordHandler:addKeyword({ "kazzan" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_6" })
keywordHandler:addKeyword({ "daraman" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_7" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_8" })
keywordHandler:addKeyword({ "drefia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_9" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_10" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_11" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_12" })
keywordHandler:addKeyword({ "continent" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_13" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_14" })
keywordHandler:addKeyword({ "flying" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_15" })
keywordHandler:addKeyword({ "fly" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_16" })
keywordHandler:addKeyword({ "new" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_17" })
keywordHandler:addKeyword({ "rumors" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_18" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_19" })
keywordHandler:addKeyword({ "transport" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_20" })
keywordHandler:addKeyword({ "ride" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_21" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_22" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.uzon.stdmod_23" })

npcHandler:setMessage(MESSAGE_GREET, "Daraman's blessings, traveller |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Daraman's blessings")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Daraman's blessings")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
