local internalNpcName = "Uncle"
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
	lookHead = 38,
	lookBody = 19,
	lookLegs = 20,
	lookFeet = 95,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local fire = Condition(CONDITION_FIRE)
fire:setParameter(CONDITION_PARAM_DELAYED, true)
fire:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
fire:addDamage(25, 9000, -10)
npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 1)
			player:addAchievement("Secret Agent")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_2")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(403, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission02, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_3")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_4")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission03, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 7)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission04, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 9)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_6")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(406, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission05, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 11)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_8")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission06, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 13)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_9")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(396, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 15)
				player:addAchievement("Top AVIN Agent")
				player:addItem(899, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_23")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_24")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_11")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_22")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) < 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) < 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 2)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01, 1)
			player:addItem(402, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_12")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_13")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01) == 4 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 3 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission02, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_18")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission02) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_14")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission02) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 6)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission03, 1)
			player:addItem(404, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_15")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission03) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_15")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission03) == 4 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 7 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 8)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission04, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_13")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission04) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_16")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission04) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 9 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 10)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission05, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_17")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission05) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_18")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission05) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 12)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.AVINMission06, 1)
			player:addItem(405, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_7")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission06) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_19")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 13 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 14)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.multi_3")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Mission07) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.uncle.say_20")
			npcHandler:setTopic(playerId, 8)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
