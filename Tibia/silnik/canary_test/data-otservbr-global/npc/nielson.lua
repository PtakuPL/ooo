local internalNpcName = "Nielson"
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
	lookHead = 114,
	lookBody = 113,
	lookLegs = 68,
	lookFeet = 67,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.nielson.voice_1" },
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
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, {
		npcHandler = npcHandler,
		i18nKey = "npc.nielson.stdmod_1" .. keyword:titleCase() .. " for |TRAVELCOST|?",
		cost = cost,
		discount = "postman",
	})
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, {
		npcHandler = npcHandler,
		text = "Have a nice trip!",
		premium = false,
		cost = cost,
		discount = "postman",
		destination = destination,
	})
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, {
		npcHandler = npcHandler,
		i18nKey = "npc.nielson.stdmod_2",
		reset = true,
	})
end

addTravelKeyword("vega", 20, { x = 32020, y = 31692, z = 7 })
addTravelKeyword("senja", 20, { x = 32128, y = 31664, z = 7 })
addTravelKeyword("folda", 20, { x = 32046, y = 31578, z = 7 })

-- Basic
keywordHandler:addKeyword({ "passage" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.nielson.stdmod_3",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.nielson.stdmod_4",
})
keywordHandler:addKeyword({ "captain" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.nielson.stdmod_5",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.nielson.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.nielson.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
