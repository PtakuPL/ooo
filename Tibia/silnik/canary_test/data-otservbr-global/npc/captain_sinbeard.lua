local internalNpcName = "Captain Sinbeard"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 134,
	lookHead = 95,
	lookBody = 10,
	lookLegs = 56,
	lookFeet = 77,
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
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_2" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_3", reset = true })
end

addTravelKeyword("edron", 160, Position(33175, 31764, 6))
addTravelKeyword("venore", 150, Position(32954, 32022, 6))
addTravelKeyword("port hope", 80, Position(32527, 32784, 6))
addTravelKeyword("liberty bay", 90, Position(32285, 32892, 6))
addTravelKeyword("darashia", 100, Position(33289, 32480, 6))
addTravelKeyword("yalahar", 230, Position(32816, 31272, 6), function(player)
	return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Ankrahmun) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
end)

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33082, 32879, 6), Position(33085, 32879, 6), Position(33085, 32881, 6) } })

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_5" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_6" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_7" })
keywordHandler:addKeyword({ "line" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_8" })
keywordHandler:addKeyword({ "company" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_9" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_10" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_11" })
keywordHandler:addKeyword({ "passanger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_12" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_13" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_14" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_15" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_16" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_17" })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_18" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_19" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_20" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_21" })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_22" })
keywordHandler:addKeyword({ "ankrahmun" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_sinbeard.stdmod_23" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_sinbeard.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_sinbeard.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_sinbeard.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
