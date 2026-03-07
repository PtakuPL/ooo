local internalNpcName = "Sister Of Jack"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 77,
	lookBody = 128,
	lookLegs = 110,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.sister_of_jack.voice_1" },
	{ i18nKey = "npc.sister_of_jack.voice_2" },
	{ i18nKey = "npc.sister_of_jack.voice_3" },
	{ i18nKey = "npc.sister_of_jack.voice_4" },
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

	if MsgContains(message, "jack") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 5 then
			if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.Mother == 1) and (player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.Sister)) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.say_1")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "spectulus") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.say_2")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.multi_4")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sister_of_jack.multi_2")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.Sister, 1)
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 6)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.sister_of_jack.greet_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
