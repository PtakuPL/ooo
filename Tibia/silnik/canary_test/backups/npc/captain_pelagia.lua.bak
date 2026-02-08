local internalNpcName = "Captain Pelagia"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 155,
	lookHead = 94,
	lookBody = 0,
	lookLegs = 114,
	lookFeet = 85,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.captain_pelagia.voice_1" },
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
local function addTravelKeyword(keyword, cost, destination)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_1" .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_2", reset = true })
end

addTravelKeyword("venore", 120, Position(32954, 32022, 6)) -- {x = 32954, y = 32022, z = 6}
addTravelKeyword("edron", 110, Position(33176, 31765, 6)) -- {x = 33176, y = 31765, z = 6}
addTravelKeyword("oramond", 70, Position(33479, 31985, 7)) -- {x = 33479, y = 31985, z = 7}
addTravelKeyword("darashia", 120, Position(33289, 32481, 6)) -- {x = 33289, y = 32481, z = 6}
addTravelKeyword("thais", 130, Position(32310, 32210, 6)) --
addTravelKeyword("issavi", 130, Position(33902, 31464, 6))

-- Darashia
local travelNode = keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_3", cost = 0, discount = "postman" })
local childTravelNode = travelNode:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_4" })
childTravelNode:addChildKeyword({ "yes" }, StdModule.travel, {
	npcHandler = npcHandler,
	premium = false,
	cost = 0,
	discount = "postman",
	destination = function(player)
		return math.random(10) == 1 and Position(33324, 32173, 6) or Position(33289, 32481, 6)
	end,
})
childTravelNode:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, reset = true, i18nKey = "npc.captain_pelagia.stdmod_5" })
travelNode:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, reset = true, i18nKey = "npc.captain_pelagia.stdmod_6" })

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33498, 31711, 6) } })

-- Basic
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_7" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_8" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_9" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_10" })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_11" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_pelagia.stdmod_12" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_pelagia.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_pelagia.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_pelagia.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
