local internalNpcName = "Brodrosch"
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
	{ i18nKey = "npc.brodrosch.voice_1" },
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "ticket") then
		if Player(creature):getStorageValue(Storage.WagonTicket) >= os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.brodrosch.say_1")
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.brodrosch.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) > 0 then
		local player = Player(creature)
		if npcHandler:getTopic(playerId) == 1 then
			if not player:removeMoneyBank(250) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.brodrosch.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.WagonTicket, os.time() + 7 * 24 * 60 * 60)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.brodrosch.say_4")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.brodrosch.say_5")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Travel
local function addTravelKeyword(keyword, text, cost, discount, destination, condition, action)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, {
			npcHandler = npcHandler,
			i18nKey = "npc.brodrosch.stdmod_3",
		}, condition, action)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = text[1], cost = cost, discount = discount })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, i18nKey = text[2], cost = cost, discount = discount, destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = text[3], reset = true })
end

addTravelKeyword("farmine", { "npc.brodrosch.stdmod_4", "npc.brodrosch.stdmod_5", "npc.brodrosch.stdmod_6" }, 210, { "postman", "new frontier" }, function(player)
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

addTravelKeyword("cormaya", { "npc.brodrosch.stdmod_7", "npc.brodrosch.stdmod_8", "npc.brodrosch.stdmod_9" }, 160, { "postman" }, Position(33311, 31989, 15), function(player)
	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 4 then
		player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 5)
	end
end)

addTravelKeyword("gnomprona", { "npc.brodrosch.stdmod_10", "npc.brodrosch.stdmod_11", "npc.brodrosch.stdmod_12" }, 200, "postman", Position(33516, 32856, 14))
keywordHandler:addKeyword({ "passage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brodrosch.stdmod_1" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.brodrosch.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.brodrosch.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.brodrosch.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
