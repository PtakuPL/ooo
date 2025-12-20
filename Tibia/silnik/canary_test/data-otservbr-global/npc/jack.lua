local internalNpcName = "Jack"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 115,
	lookBody = 96,
	lookLegs = 115,
	lookFeet = 114,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.jack.voice_1" },
	{ i18nKey = "npc.jack.voice_2" },
	{ i18nKey = "npc.jack.voice_3" },
	{ i18nKey = "npc.jack.voice_4" },
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

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 7 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack.greet_msg_1")
	elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 8 then
		npcHandler:setMessage(MESSAGE_GREET, {
			"What did you do to my SCULPTURE? You simply DESTROYED it? Why? You... you ruined everything... my house, my hobby, my life. My family even refuses to talk to me anymore. ...",
			"Alright, alright you win. I am done for. You... you must be right, yes. Yes, I was working as an intern... in the academy in Edron... yes... Just... tell this Spectulus guy I want to see him. I have nothing left. I am ready.",
		})
		player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 9)
	elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 10 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack.greet_msg_2")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack.greet_msg_3")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "spectulus") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 3 then
			if npcHandler:getTopic(playerId) == 3 then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.jack.say_1", "npc.jack.say_2"}, 1000)
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 4)
			end
		end
	elseif MsgContains(message, "furniture") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "no") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 10 then
			if npcHandler:getTopic(playerId) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_3")
				npcHandler:setTopic(playerId, 5)
			elseif npcHandler:getTopic(playerId) == 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_9")
				player:addAchievement("Truth Be Told")
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 11)
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.LastMissionState, 1)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_7")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_5")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 2)
		end

		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 10 then
			if npcHandler:getTopic(playerId) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_4")
				npcHandler:setTopic(playerId, 6)
			elseif npcHandler:getTopic(playerId) == 6 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_5")
				player:addAchievement("You Don't Know Jack")
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 11)
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.LastMissionState, 2)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "hobbies") or MsgContains(message, "hobby") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 7 then
			if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.Statue) < 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.multi_3")
				player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.Statue, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
