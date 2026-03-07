local internalNpcName = "Captain Seagull"
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
	lookHead = 60,
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
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_2", i18nArgs = { keyword:titleCase() }, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_3", reset = true })
end

addTravelKeyword("thais", 130, Position(32310, 32210, 6))
addTravelKeyword("carlin", 80, Position(32387, 31820, 6))
addTravelKeyword("gray island", 150, Position(33196, 31984, 7))
addTravelKeyword("edron", 70, Position(33175, 31764, 6))
addTravelKeyword("venore", 90, Position(32954, 32022, 6))
addTravelKeyword("yalahar", 160, Position(32816, 31272, 6), function(player)
	return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.AbDendriel) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
end)

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(32724, 31669, 6), Position(32726, 31665, 6) } })

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_5" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_6" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_7" })
keywordHandler:addKeyword({ "line" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_8" })
keywordHandler:addKeyword({ "company" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_9" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_10" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_11" })
keywordHandler:addKeyword({ "good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_12" })
keywordHandler:addKeyword({ "passanger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_13" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_14" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_15" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_16" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_17" })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_18" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_19" })
keywordHandler:addKeyword({ "ice" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_20" })
keywordHandler:addKeyword({ "senja" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_21" })
keywordHandler:addKeyword({ "folda" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_22" })
keywordHandler:addKeyword({ "vega" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_23" })
keywordHandler:addKeyword({ "ankrahmun" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_24" })
keywordHandler:addKeyword({ "tiquanda" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_25" })
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_26" })
keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_27" })
keywordHandler:addKeyword({ "darama" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_28" })
keywordHandler:addKeyword({ "ghost" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_29" })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seagull.stdmod_30" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_seagull.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_seagull.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_seagull.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
