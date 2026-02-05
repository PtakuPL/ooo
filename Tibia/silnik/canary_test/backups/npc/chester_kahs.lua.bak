local internalNpcName = "Chester Kahs"
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
	lookHead = 9,
	lookBody = 28,
	lookLegs = 47,
	lookFeet = 95,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.chester_kahs.voice_1" },
	{ i18nKey = "npc.chester_kahs.voice_2" },
	{ i18nKey = "npc.chester_kahs.voice_3" },
	{ i18nKey = "npc.chester_kahs.voice_4" },
	{ i18nKey = "npc.chester_kahs.voice_5" },
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

local fire = Condition(CONDITION_FIRE)
fire:setParameter(CONDITION_PARAM_DELAYED, true)
fire:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
fire:addDamage(25, 9000, -10)

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "gamel") or MsgContains(message, "rebel") or MsgContains(message, "gamel rebel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(3061, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_3")
				player:addItem(3052, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_4")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(3052, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_5")
				player:addHealth(player:getMaxHealth())
				npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_6")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_7")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_8")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(5956, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(5952, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03, 3)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 7)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_11")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_12")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(348, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 9)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_13")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_14")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 10 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 11)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_15")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 13)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_16")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:removeMoneyBank(1000) then
				player:addItem(397, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_17")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_18")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeItem(396, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 15)
				player:addItem(897, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_19")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_20")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_21")
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_22")
			player:addCondition(fire)
			player:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
			npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			player:removeItem(3061, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_23")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "magic") and MsgContains(message, "crystal") and MsgContains(message, "lugri") and MsgContains(message, "deathcurse") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_24")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_25")
		end
	elseif MsgContains(message, "heal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_26")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_32")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01) < 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) < 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 2)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_29")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_27")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 3 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_23")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_28")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 6)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_16")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_29")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 7 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 8)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_13")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_30")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 9 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 10)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05, 1)
			player:addItem(349, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_9")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_31")
			npcHandler:setTopic(playerId, 10)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 12)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06, 1)
			player:addItem(397, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_6")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_32")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 13 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 14)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.multi_3")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Mission07) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_33")
			npcHandler:setTopic(playerId, 13)
		end
	elseif MsgContains(message, "disguise") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_34")
			npcHandler:setTopic(playerId, 12)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.chester_kahs.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.chester_kahs.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.chester_kahs.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
