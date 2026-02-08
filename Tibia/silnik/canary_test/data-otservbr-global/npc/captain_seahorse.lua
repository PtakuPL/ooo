local internalNpcName = "Captain Seahorse"
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
local function addTravelKeyword(keyword, cost, destination, action)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_1", i18nArgs = { keyword:titleCase() }, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination }, nil, action)
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_2", reset = true })
end

addTravelKeyword("venore", 40, Position(32954, 32022, 6), function(player)
	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 3 then
		player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 4)
	end
end)
addTravelKeyword("thais", 160, Position(32310, 32210, 6))
addTravelKeyword("carlin", 110, Position(32387, 31820, 6))
addTravelKeyword("krailos", 185, Position(33493, 31712, 6))
addTravelKeyword("ab'dendriel", 70, Position(32734, 31668, 6))
addTravelKeyword("gray island", 190, Position(33196, 31984, 7))
addTravelKeyword("port hope", 150, Position(32527, 32784, 6))
addTravelKeyword("liberty bay", 170, Position(32285, 32892, 6))
addTravelKeyword("ankrahmun", 160, Position(33092, 32883, 6))
addTravelKeyword("cormaya", 20, Position(33288, 31956, 6))
addTravelKeyword("oramond", 200, Position(33479, 31985, 7))

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33174, 31773, 6), Position(33175, 31771, 6), Position(33177, 31772, 6) } })

-- Basic
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_3" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_4" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_5" })
keywordHandler:addKeyword({ "edron" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_6" })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_seahorse.stdmod_7" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_seahorse.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_seahorse.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_seahorse.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
