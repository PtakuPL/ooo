local internalNpcName = "Captain Harava"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1200,
	lookHead = 77,
	lookBody = 101,
	lookLegs = 3,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.captain_harava.voice_1" },
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
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_2" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination }, nil, action)
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_3", reset = true })
end

addTravelKeyword("darashia", 80, Position(33289, 32481, 6))
addTravelKeyword("venore", 80, Position(32954, 32022, 6))
addTravelKeyword("oramond", 100, Position(33479, 31985, 7))
addTravelKeyword("krailos", 80, Position(33492, 31712, 6))

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33897, 31471, 6), Position(33901, 31471, 6) } })

-- Basic
keywordHandler:addKeyword({ "trip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_4" })
keywordHandler:addKeyword({ "route" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_5" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_6" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_7" })
keywordHandler:addKeyword({ "destination" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_8" })
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_9" })
keywordHandler:addKeyword({ "go" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_harava.stdmod_10" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_harava.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_harava.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_harava.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
