local internalNpcName = "Baa'Leal"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 51,
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

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local condition = Condition(CONDITION_FIRE)
condition:setParameter(CONDITION_PARAM_DELAYED, 1)
condition:addDamage(150, 2000, -10)

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not MsgContains(message, "djanni'hah") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_14")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_2")
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_3")
	end

	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01)
	if MsgContains(message, "mission") then
		if missionProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_12")
			npcHandler:setTopic(playerId, 1)
		elseif table.contains({ 1, 2 }, missionProgress) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_4")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_5")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_9")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_6")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_7")
			npcHandler:setTopic(playerId, 3)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "partos") then
			if missionProgress ~= 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.multi_3")
				player:addMoney(600)
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01, 3)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.baa_leal.say_10")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

npcHandler:setMessage(MESSAGE_FAREWELL, "Stand down, soldier!")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
