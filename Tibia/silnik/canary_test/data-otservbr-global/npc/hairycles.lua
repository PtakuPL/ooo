local internalNpcName = "Hairycles"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 117,
	lookHead = 10,
	lookBody = 20,
	lookLegs = 30,
	lookFeet = 40,
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	if Player(creature):getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline) < 12 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.hairycles.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.hairycles.greet_msg_2")
	end
	return true
end

local function releasePlayer(npc, creature)
	if not Player(creature) then
		return
	end

	npcHandler:removeInteraction(npc, creature)
	npcHandler:resetNpc(creature)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local questProgress = player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline)
	if MsgContains(message, "mission") then
		if questProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif questProgress == 1 then
			if player:getStorageValue(Storage.Quest.U7_6.WhisperMoss) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_2")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_3")
			end
		elseif questProgress == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_41")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_42")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 3)
		elseif questProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif questProgress == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif questProgress == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_6")
			npcHandler:setTopic(playerId, 7)
		elseif questProgress == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_40")
			npcHandler:setTopic(playerId, 8)
		elseif questProgress == 7 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.ParchmentDecyphering) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_7")
				npcHandler:setTopic(playerId, 9)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_8")
			end
		elseif questProgress == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_35")
			npcHandler:setTopic(playerId, 10)
		elseif questProgress == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_9")
			npcHandler:setTopic(playerId, 11)
		elseif questProgress == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_32")
			npcHandler:setTopic(playerId, 12)
		elseif questProgress == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_10")
			npcHandler:setTopic(playerId, 13)
		elseif questProgress == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_30")
			npcHandler:setTopic(playerId, 14)
		elseif questProgress == 13 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Casks) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_11")
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 14)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_12")
			end
		elseif questProgress == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_27")
			npcHandler:setTopic(playerId, 15)
		elseif questProgress == 15 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.HolyApeHair) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_13")
				npcHandler:setTopic(playerId, 16)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_14")
			end
		elseif questProgress == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_20")
			npcHandler:setTopic(playerId, 17)
		elseif questProgress == 17 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.SnakeDestroyer) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_15")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_16")
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 18)
				player:addAchievement("Friend of the Apes")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_15")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_16")
		end
	elseif MsgContains(message, "background") then
		if questProgress == 1 and player:getStorageValue(Storage.Quest.U7_6.WhisperMoss) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_13")
		end
	elseif MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Hairycles) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_17")
			npcHandler:setTopic(playerId, 19)
		end
	elseif MsgContains(message, "outfit") or MsgContains(message, "shamanic") then
		if questProgress == 18 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.ShamanOutfit) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_18")
				npcHandler:setTopic(playerId, 18)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_19")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_20")
		end
	elseif MsgContains(message, "heal") then
		if questProgress > 11 then
			if player:getHealth() < 50 then
				player:addHealth(50 - player:getHealth())
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			elseif player:getCondition(CONDITION_FIRE) then
				player:removeCondition(CONDITION_FIRE)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			elseif player:getCondition(CONDITION_POISON) then
				player:removeCondition(CONDITION_POISON)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_21")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_22")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_23")
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_24")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_8")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Started, 1)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 1)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.DworcDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_25")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4827, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_26")
				player:setStorageValue(Storage.Quest.U7_6.WhisperMoss, -1)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_27")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_28")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 4 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4828, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_29")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_30")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 4)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_31")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.multi_3")
			npcHandler:setTopic(playerId, 6)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_32")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_33")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 5)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.ChorDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_34")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4831, 1) then
				if player:getStorageValue(Storage.Quest.U7_6.OldParchment) == 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_35")
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_36")
				end
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_37")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 6)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_38")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_39")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 7)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_40")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 9 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_41")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 8)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_42")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 10 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_43")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 9)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_44")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 11 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4839, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_45")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_46")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 10)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_47")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 12 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_48")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 11)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.FibulaDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_49")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 13 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4829, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_50")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_51")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 12)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.FibulaDoor, -1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_52")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 14 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_53")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 13)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.CasksDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_54")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_55")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 15)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_56")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4832, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_57")
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.HolyApeHair, -1)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_58")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 16)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_59")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 17 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_60")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 17)
			player:addItem(4835, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_61")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_62")
			player:addOutfit(154)
			player:addOutfit(158)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.ShamanOutfit, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_63")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if MsgContains(message, "yes") then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_64")
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Hairycles, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end

			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_65")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_66")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "busy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_1" })
keywordHandler:addKeyword({ "wizard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_2" })
keywordHandler:addKeyword({ "things" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_3" })
keywordHandler:addKeyword({ "ape people" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_4" })
keywordHandler:addKeyword({ "kongra" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_5" })
keywordHandler:addKeyword({ "sibang" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_6" })
keywordHandler:addKeyword({ "merlkin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_7" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_8" })
keywordHandler:addKeyword({ "jungle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hairycles.stdmod_9" })

local function onTradeRequest(npc, creature)
	if Player(creature):getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline) < 18 then
		return false
	end

	return true
end

npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "banana", clientId = 3587, buy = 2 },
	{ itemName = "monkey statue 'hear' kit", clientId = 5055, buy = 65 },
	{ itemName = "monkey statue 'see' kit", clientId = 5046, buy = 65 },
	{ itemName = "monkey statue 'speak' kit", clientId = 5056, buy = 65 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
