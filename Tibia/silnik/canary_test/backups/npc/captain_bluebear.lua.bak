local internalNpcName = "Captain Bluebear"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 19,
	lookBody = 69,
	lookLegs = 125,
	lookFeet = 50,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Passages to Carlin, Ab'Dendriel, Edron, Venore, Port Hope, Liberty Bay, Yalahar, Roshamuul, Krailos, Oramond and Svargrond." },
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
local function addTravelKeyword(keyword, cost, destination, action, condition)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_2" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination }, nil, action)
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_3", reset = true })
end

addTravelKeyword("carlin", 110, Position(32387, 31820, 6), function(player)
	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 1 then
		player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 2)
	end
end)

addTravelKeyword("ab'dendriel", 130, Position(32734, 31668, 6))
addTravelKeyword("edron", 160, Position(33175, 31764, 6))
addTravelKeyword("venore", 170, Position(32954, 32022, 6))
addTravelKeyword("port hope", 160, Position(32527, 32784, 6))
addTravelKeyword("roshamuul", 210, Position(33494, 32567, 7))
addTravelKeyword("svargrond", 180, Position(32341, 31108, 6))
addTravelKeyword("liberty bay", 180, Position(32285, 32892, 6))
addTravelKeyword("yalahar", 200, Position(32816, 31272, 6), nil, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Thais) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
end)
addTravelKeyword("oramond", 150, Position(33479, 31985, 7))
addTravelKeyword("krailos", 230, Position(33492, 31712, 6))

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(32320, 32219, 6), Position(32321, 32210, 6) } })

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_5" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_6" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_7" })
keywordHandler:addKeyword({ "line" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_8" })
keywordHandler:addKeyword({ "company" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_9" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_10" })
keywordHandler:addKeyword({ "good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_11" })
keywordHandler:addKeyword({ "passenger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_12" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_13" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_14" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_15" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_16" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_17" })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_18" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_19" })
keywordHandler:addKeyword({ "ice" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_20" })
keywordHandler:addKeyword({ "senja" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_21" })
keywordHandler:addKeyword({ "folda" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_22" })
keywordHandler:addKeyword({ "vega" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_23" })
keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_24" })
keywordHandler:addKeyword({ "darama" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_25" })
keywordHandler:addKeyword({ "ghost" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_26" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_bluebear.stdmod_27" })

npcHandler:setMessage(MESSAGE_GREET, "Welcome on board, |PLAYERNAME|. Where can I {sail} you today?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye. Recommend us if you were satisfied with our service.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
