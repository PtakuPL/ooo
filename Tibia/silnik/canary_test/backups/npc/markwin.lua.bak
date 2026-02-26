local internalNpcName = "Markwin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 23,
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

local condition = Condition(CONDITION_FIRE)
condition:setParameter(CONDITION_PARAM_TICKS, 30 * 1000)
condition:setParameter(CONDITION_PARAM_MINVALUE, 30)
condition:setParameter(CONDITION_PARAM_TICKINTERVAL, 4000)

local guards = { "Minotaur Guard", "Minotaur Archer", "Minotaur Mage" }
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.MarkwinGreeting) < 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.markwin.greet_msg_1")
		player:setStorageValue(Storage.MarkwinGreeting, 1)
		local position
		for x = -1, 1 do
			for y = -1, 1 do
				position = Position(32418 + x, 32147 + y, 15)
				Game.createMonster(guards[math.random(3)], position)
				position:sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_1")
		return false
	elseif player:getStorageValue(Storage.MarkwinGreeting) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.markwin.greet_msg_1")
		player:setStorageValue(Storage.MarkwinGreeting, 2)
	elseif player:getStorageValue(Storage.MarkwinGreeting) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.markwin.greet_msg_2")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "letter") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 1 then
			if player:getItemCount(3220) > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_2")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Markwin) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_3")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_4")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10, 2)
			player:removeItem(3220, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_5")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Markwin, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end

			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_6")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "bye") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.markwin.say_7")
		player:addCondition(condition)
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
