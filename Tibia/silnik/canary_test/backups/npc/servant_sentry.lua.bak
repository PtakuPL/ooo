local internalNpcName = "Servant Sentry"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 396,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.servant_sentry.voice_1" },
	{ i18nKey = "npc.servant_sentry.voice_2" },
	{ i18nKey = "npc.servant_sentry.voice_3" },
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

keywordHandler:addKeyword({ "master" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.servant_sentry.stdmod_1" })
keywordHandler:addKeyword({ "sentry" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.servant_sentry.stdmod_2" })
keywordHandler:addKeyword({ "slime" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.servant_sentry.stdmod_3" }, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheirMastersVoiceWorldChange.SlimeGobblerReceived) == 1
end)

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U9_1.TheirMastersVoiceWorldChange.SlimeGobblerReceived) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.servant_sentry.say_4")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "slime") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.servant_sentry.say_5")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U9_1.TheirMastersVoiceWorldChange.SlimeGobblerReceived, 1)
			player:addItem(12077, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.servant_sentry.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.servant_sentry.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.servant_sentry.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.servant_sentry.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
