local internalNpcName = "Avar Tar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 73,
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

	if npcHandler:getTopic(playerId) == 0 then
		if MsgContains(message, "outfit") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.multi_5")
			npcHandler:setTopic(playerId, 1)
		elseif MsgContains(message, "cookie") then
			if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.AvarTar) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_1")
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 3 then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.AvarTar, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end

			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_4")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "base") then
			if player:getStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward) == 1 then
				player:addOutfit(541)
				player:addOutfit(542)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_6")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_7")
				npcHandler:setTopic(playerId, 2)
			end
		elseif MsgContains(message, "shield") then
			if player:getStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward) == 2 and player:getStorageValue(Storage.Quest.U6_4.DemonHelmet.Rewards.DemonHelmet) == 1 then
				player:addOutfitAddon(541, 1)
				player:addOutfitAddon(542, 1)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U6_4.DemonHelmet.Rewards.DemonHelmet, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_8")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_9")
				npcHandler:setTopic(playerId, 2)
			end
		elseif MsgContains(message, "helmet") then
			if player:getStorageValue(Storage.Quest.U7_24.TheAnnihilator.Reward) == 2 and player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) == 3 then
				player:addOutfitAddon(541, 2)
				player:addOutfitAddon(542, 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Done, 4)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_10")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.avar_tar.say_11")
				npcHandler:setTopic(playerId, 2)
			end
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.avar_tar.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.avar_tar.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.avar_tar.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
