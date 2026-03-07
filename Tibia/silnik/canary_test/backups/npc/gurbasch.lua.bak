local internalNpcName = "Gurbasch"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 66,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.gurbasch.voice_1" },
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
local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function addTravelKeyword(keyword, text, cost, discount, destination, condition, action)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, {
			npcHandler = npcHandler,
			i18nKey = "npc.gurbasch.stdmod_3",
		}, condition, action)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = text[1], cost = cost, discount = discount })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, i18nKey = text[2], cost = cost, discount = discount, destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = text[3], reset = true })
end

addTravelKeyword("farmine", { "npc.gurbasch.stdmod_4", "npc.gurbasch.stdmod_5", "npc.gurbasch.stdmod_6" }, 110, { "postman", "new frontier" }, function(player)
	local destination = Position(33025, 31553, 14)
	if player:getStorageValue(TheNewFrontier.Mission05[1]) == 2 then --if The New Frontier Quest 'Mission 05: Getting Things Busy' complete then Stage 3
		destination.z = 10
	elseif player:getStorageValue(TheNewFrontier.Mission03) >= 2 then --if The New Frontier Quest 'Mission 03: Strangers in the Night' complete then Stage 2
		destination.z = 12
	end
	return destination
end, function(player)
	return player:getStorageValue(TheNewFrontier.FarmineFirstTravel) < 1
end, function(player)
	if player:getStorageValue(TheNewFrontier.FarmineFirstTravel) < 1 then
		player:setStorageValue(TheNewFrontier.FarmineFirstTravel, 1)
	end
end)

addTravelKeyword("kazordoon", { "npc.gurbasch.stdmod_7", "npc.gurbasch.stdmod_8", "npc.gurbasch.stdmod_9" }, 160, "postman", Position(32660, 31957, 15))
addTravelKeyword("gnomprona", { "npc.gurbasch.stdmod_10", "npc.gurbasch.stdmod_11", "npc.gurbasch.stdmod_12" }, 200, "postman", Position(33516, 32856, 14))
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gurbasch.stdmod_1" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gurbasch.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.gurbasch.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gurbasch.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
