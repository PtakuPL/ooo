local internalNpcName = "Shoddy Beggar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 20,
	lookBody = 39,
	lookLegs = 39,
	lookFeet = 116,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.shoddy_beggar.voice_1" },
	{ i18nKey = "npc.shoddy_beggar.voice_2" },
	{ i18nKey = "npc.shoddy_beggar.voice_3" },
	{ i18nKey = "npc.shoddy_beggar.voice_4" },
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

	if MsgContains(message, "spare") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "device") then
		if player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_2")
		end
	elseif MsgContains(message, "scientist") then
		if player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_3")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if not player:removeMoneyBank(1) then
				npcHandler:say(player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) ~= 1 and "Is that all you have? That would be less than I have... *mumbles*" or "Mh, it seems you don't have any coins.", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end

			npcHandler:say(
				player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) ~= 1 and "Very kind indeed. Maybe you are not such a bad guy after all. Maybe I can even give it back to you one day... you know I was not always like that *mumbles*." or "Thank you very much... plans you say? I don't know what you are talking about. Plans for a magic... device? And the people call ME crazy.",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if not player:removeMoneyBank(1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_4")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_5")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_6")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_7")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_8")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_9")
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_10")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_11")
			npcHandler:setTopic(playerId, 9)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_12")
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_13")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			player:addItem(9696, 1)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 2)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission1, 2)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_14")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_15")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_16")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_17")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_18")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_19")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_20")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_21")
			npcHandler:setTopic(playerId, 8)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_22")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_23")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shoddy_beggar.say_24")
			npcHandler:setTopic(playerId, 11)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.shoddy_beggar.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.shoddy_beggar.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.shoddy_beggar.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
