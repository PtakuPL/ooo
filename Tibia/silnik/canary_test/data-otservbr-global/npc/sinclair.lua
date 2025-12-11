local internalNpcName = "Sinclair"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 133,
	lookHead = 21,
	lookBody = 38,
	lookLegs = 19,
	lookFeet = 95,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.sinclair.voice_1" },
	{ i18nKey = "npc.sinclair.voice_2" },
	{ i18nKey = "npc.sinclair.voice_3" },
	{ i18nKey = "npc.sinclair.voice_4" },
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

	if MsgContains(message, "mission") then
		local qStorage = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01)
		if qStorage == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_1")
			npcHandler:setTopic(playerId, 3)
		elseif qStorage == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif qStorage > 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif qStorage < 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_15")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_5")
			player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 3)
			player:addItem(4050, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.CharmUse) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_9")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_11")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_12")
				player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 4)
				player:addExperience(500, true)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_6")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_7")
			player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_7")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			local nightstalkers, souleaters, ghost = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.NightstalkerUse), player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.SouleaterUse), player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.GhostUse)
			if nightstalkers >= 4 and souleaters >= 4 and ghost >= 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_8")
				player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 6)
				player:addExperience(10000, true)
				player:addItem(3035, 60)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_9")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "research") then
		local qStorage = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01)
		if qStorage == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.multi_2")
			npcHandler:setTopic(playerId, 4)
		elseif qStorage == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sinclair.say_10")
			npcHandler:setTopic(playerId, 5)
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings |PLAYERNAME|. I have - very - little time, please make it as short as possible. I may be able to help you if you are here to help us with any of our tasks or missions.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Goodbye and good luck |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Goodbye and good luck |PLAYERNAME|.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcType:register(npcConfig)
