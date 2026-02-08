local internalNpcName = "Gewen"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 139,
	lookHead = 132,
	lookBody = 0,
	lookLegs = 86,
	lookFeet = 95,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.gewen.voice_1" },
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "ticket") then
		if player:getStorageValue(Storage.WagonTicket) >= os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gewen.say_1")
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gewen.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if not player:removeMoneyBank(250) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gewen.say_3")
				return true
			end

			player:setStorageValue(Storage.WagonTicket, os.time() + 7 * 24 * 60 * 60)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gewen.say_4")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gewen.say_5")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Travel
local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function addTravelKeyword(keyword, text, cost, destination, condition, action)
	if condition then
		keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gewen.stdmod_1" }, condition)
	end

	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gewen.stdmod_2" .. text .. " for |TRAVELCOST|?", cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, i18nKey = "npc.gewen.keyword_1", cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gewen.stdmod_3", reset = true })
end

addTravelKeyword("farmine", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("zao", "Do you seek a ride to Farmine for |TRAVELCOST|?", 60, Position(32983, 31539, 1), function(player)
	return player:getStorageValue(TheNewFrontier.Mission10[1]) ~= 2
end)
addTravelKeyword("darashia", "Darashia on Darama", 40, Position(33270, 32441, 6))
addTravelKeyword("svargrond", "Svargrond", 60, Position(32253, 31097, 4))
addTravelKeyword("femor hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("edron", "Edron", 40, Position(33193, 31784, 3))
addTravelKeyword("hills", "the Femor Hills", 60, Position(32536, 31837, 4))
addTravelKeyword("issavi", "Issavi", 100, Position(33957, 31515, 0))
addTravelKeyword("marapur", "Marapur", 70, Position(33805, 32767, 2))

keywordHandler:addKeyword({ "fly" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gewen.stdmod_4" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gewen.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.gewen.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gewen.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
