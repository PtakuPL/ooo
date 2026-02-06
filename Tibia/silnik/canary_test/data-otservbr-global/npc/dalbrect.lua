local internalNpcName = "Dalbrect"
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
	lookHead = 76,
	lookBody = 97,
	lookLegs = 67,
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

	if MsgContains(message, "brooch") then
		if player:getStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Passage) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_1")
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getItemCount(3205) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			npcHandler:say(
				"Can it be? I recognise my family's arms! You have found a treasure indeed! \z
					I am poor and all I can offer you is my friendship, but ... please ... give that brooch to me?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:setTopic(playerId, 0)
			if not player:removeItem(3205, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_4")
				return true
			end

			npcHandler:say(
				"Thank you! I shall consider you my friend from now on! \z
					Just let me know if you {need} something!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.QuestLog, 1) -- Quest log
			player:setStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Passage, 1)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_5")
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dalbrect.say_6")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "passage" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_1",
}, function(player)
	return player:getStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Passage) ~= 1
end)

local travelNode = keywordHandler:addKeyword({ "passage" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_2",
})
travelNode:addChildKeyword({ "yes" }, StdModule.travel, {
	npcHandler = npcHandler,
	premium = false,
	i18nKey = "npc.dalbrect.stdmod_3",
	cost = 10,
	destination = Position(32190, 31957, 6),
})
travelNode:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	reset = true,
	i18nKey = "npc.dalbrect.stdmod_3",
})

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_4",
})
keywordHandler:addKeyword({ "hut" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_5",
})
keywordHandler:addKeyword({ "legacy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_6",
})
keywordHandler:addKeyword({ "poverty" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_7",
})
keywordHandler:addKeyword({ "fate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_8",
})
keywordHandler:addKeyword({ "ghostlands" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_9",
})
keywordHandler:addKeyword({ "project" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_10",
})
keywordHandler:addKeyword({ "carlin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_11",
})
keywordHandler:addKeyword({ "need" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_12",
})
keywordHandler:addKeyword({ "ship" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.dalbrect.stdmod_13",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.dalbrect.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.dalbrect.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dalbrect.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
