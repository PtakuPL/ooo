local internalNpcName = "Jack Fate"
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
	lookLegs = 107,
	lookFeet = 50,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.jack_fate.voice_1" },
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
local function addTravelKeyword(keyword, cost, destination, text, condition)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_1" }, condition)
	end

	if keyword == "goroma" then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_2" }, function(player)
			return player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToGoroma) ~= 1
		end)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, text = (text or "Do you seek a passage to ") .. keyword:titleCase() .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_3", reset = true })
end

addTravelKeyword("edron", 170, Position(33173, 31764, 6))
addTravelKeyword("venore", 180, Position(32954, 32022, 6))
addTravelKeyword("port hope", 50, Position(32527, 32784, 6))
addTravelKeyword("darashia", 200, Position(33289, 32480, 6))
addTravelKeyword("ankrahmun", 90, Position(33092, 32883, 6))
addTravelKeyword("goroma", 0, Position(32161, 32558, 6), "Ugh. You really want to go back to Goroma? I'll surely have to repair my ship afterwards, so I won't charge. Okay?")
addTravelKeyword("yalahar", 275, Position(32816, 31272, 6), nil, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.LibertyBay) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5
end)

-- Thais
local travelKeyword = keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_4", cost = 180, discount = "postman" })
local childTravelKeyword = travelKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_5" })
childTravelKeyword:addChildKeyword({ "yes" }, StdModule.travel, {
	npcHandler = npcHandler,
	premium = false,
	cost = 180,
	discount = "postman",
	destination = function(player)
		return math.random(8) == 1 and Position(32161, 32558, 6) or Position(32310, 32210, 6)
	end,
})
childTravelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, reset = true, i18nKey = "npc.jack_fate.stdmod_6" })
travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, reset = true, i18nKey = "npc.jack_fate.stdmod_7" })

-- Basic
keywordHandler:addKeyword({ "sail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_8" })
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_9" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_10" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_11" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_12" })
keywordHandler:addKeyword({ "liberty bay" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate.stdmod_13" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_fate.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.jack_fate.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.jack_fate.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
