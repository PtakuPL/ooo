local internalNpcName = "Peter"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 58,
	lookBody = 43,
	lookLegs = 38,
	lookFeet = 76,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 7 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.peter.say_1")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) + 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission02, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission02) + 1) -- StorageValue for Questlog "Mission 02: Watching the Watchmen"
			npcHandler:setTopic(playerId, 0)
		end
	elseif table.contains({ "pass", "gate" }, message:lower()) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.peter.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "factory") then
		if npcHandler:getTopic(playerId) == 1 then
			local destination = Position(32859, 31302, 7)
			player:teleportTo(destination)
			destination:sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:setTopic(playerId, 0)
		end
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.peter.say_3")
	end
	return true
end

-- Travel without the need to say "pass", remove or comment this two lines if you want to keep the rpg
keywordHandler:addKeyword({ "factory" }, StdModule.travel, { npcHandler = npcHandler, destination = Position(32859, 31302, 7) })
keywordHandler:addKeyword({ "trade" }, StdModule.travel, { npcHandler = npcHandler, destination = Position(32854, 31302, 7) })

local function onTradeRequest(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()
	if npcHandler:getTopic(playerId) == 1 then
		local destination = Position(32854, 31302, 7)
		player:teleportTo(destination)
		destination:sendMagicEffect(CONST_ME_TELEPORT)
		npcHandler:setTopic(playerId, 0)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.peter.say_4")
	end
	return true
end
--Basic
keywordHandler:addKeyword({ "alchemist quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_1" })
keywordHandler:addKeyword({ "arena quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_2" })
keywordHandler:addKeyword({ "augur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_3" })
keywordHandler:addKeyword({ "cemetery quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_4" })
keywordHandler:addKeyword({ "factory quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_5" })
keywordHandler:addKeyword({ "foreign quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_6" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_7" })
keywordHandler:addAliasKeyword({ "official" })
keywordHandler:addKeyword({ "magician quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_8" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_9" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_10" })
keywordHandler:addKeyword({ "sunken quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_11" })
keywordHandler:addKeyword({ "trade quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_12" })
keywordHandler:addKeyword({ "quarter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_13" })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.peter.stdmod_14" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.peter.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.peter.greet_msg_1")
npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, false)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
