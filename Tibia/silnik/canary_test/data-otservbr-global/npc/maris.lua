local internalNpcName = "Maris"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 78,
	lookBody = 51,
	lookLegs = 85,
	lookFeet = 126,
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

local BloodBrothers = Storage.Quest.U8_4.BloodBrothers
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	if message == "cookie" then
		if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 1 and player:getItemCount(8199) > 0 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maris.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maris.say_2")
		end
	elseif message == "yes" then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(8199, 1) then -- garlic cookie
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maris.say_3")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
end
-- Travel
local function addTravelKeyword(keyword, cost, destination)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.maris.stdmod_1", i18nArgs = { keyword:titleCase() }, cost = cost })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.maris.stdmod_2", reset = true })
end

addTravelKeyword("fenrock", 100, Position(32563, 31313, 7))
addTravelKeyword("mistrock", 100, Position(32640, 31439, 7))

-- Basic
keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.maris.stdmod_3" })
keywordHandler:addAliasKeyword({ "passage" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.maris.stdmod_4" })
keywordHandler:addAliasKeyword({ "captain" })
keywordHandler:addKeyword({ "alori mort" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.maris.stdmod_5" }, function(player)
	return player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 1
end)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.maris.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.maris.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.maris.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
