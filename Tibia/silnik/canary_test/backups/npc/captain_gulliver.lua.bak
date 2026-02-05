local internalNpcName = "Captain Gulliver"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 472,
	lookHead = 0,
	lookBody = 57,
	lookLegs = 20,
	lookFeet = 39,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.captain_gulliver.voice_1" },
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
local function addTravelKeyword(keyword, cost, destination, action)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_1" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination }, nil, action)
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_2", reset = true })
end

addTravelKeyword("thais", 150, Position(32311, 32210, 6))
addTravelKeyword("krailos", 180, Position(33493, 31712, 6))
addTravelKeyword("issavi", 130, Position(33902, 31462, 6))

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33487, 31986, 7), Position(33486, 31984, 7) } })

-- Basic
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_3" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_4" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_5" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_6" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_7" })
keywordHandler:addKeyword({ "good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_8" })
keywordHandler:addKeyword({ "passenger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_9" })

keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_10" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_11" })
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_12" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_13" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_14" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_15" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_16" })

keywordHandler:addKeyword({ "oramond" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_gulliver.stdmod_17" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_gulliver.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_gulliver.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
