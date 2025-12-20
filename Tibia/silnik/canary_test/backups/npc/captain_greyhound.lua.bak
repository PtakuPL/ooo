local internalNpcName = "Captain Greyhound"
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
	lookHead = 96,
	lookBody = 113,
	lookLegs = 95,
	lookFeet = 115,
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
local function addTravelKeyword(keyword, cost, destination, condition)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_2" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_3", reset = true })
end

addTravelKeyword("thais", 110, Position(32310, 32210, 6))
addTravelKeyword("ab'dendriel", 80, Position(32734, 31668, 6))
addTravelKeyword("edron", 110, Position(33175, 31764, 6))
addTravelKeyword("venore", 130, Position(32954, 32022, 6))
addTravelKeyword("svargrond", 110, Position(32341, 31108, 6))
addTravelKeyword("yalahar", 185, Position(32816, 31272, 6), function(player)
	return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Carlin) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
end)

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(32384, 31815, 6), Position(32387, 31815, 6), Position(32390, 31815, 6) } })

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_5" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_6" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_7" })
keywordHandler:addKeyword({ "line" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_8" })
keywordHandler:addKeyword({ "company" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_9" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_10" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_11" })
keywordHandler:addKeyword({ "good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_12" })
keywordHandler:addKeyword({ "passenger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_13" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_14" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_15" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_16" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_17" })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_18" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_19" })
keywordHandler:addKeyword({ "ice" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_20" })
keywordHandler:addKeyword({ "senja" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_21" })
keywordHandler:addKeyword({ "folda" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_22" })
keywordHandler:addKeyword({ "vega" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_23" })
keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_24" })
keywordHandler:addKeyword({ "darama" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_25" })
keywordHandler:addKeyword({ "ghost" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_26" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_greyhound.stdmod_27" })

npcHandler:setMessage(MESSAGE_GREET, "Welcome on board, |PLAYERNAME|. Where can I {sail} you today?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye. Recommend us if you were satisfied with our service.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
