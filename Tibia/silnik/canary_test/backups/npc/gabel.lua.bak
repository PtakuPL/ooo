local internalNpcName = "Gabel"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 80,
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

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not MsgContains(message, "djanni'hah") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_24")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_2")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03)
	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission02) ~= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_22")
		elseif missionProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_19")
			npcHandler:setTopic(playerId, 1)
		elseif missionProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_3")
			npcHandler:setTopic(playerId, 1)
		elseif missionProgress == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_4")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_5")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_15")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_6")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_9")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03, 3)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.DoorToEfreetTerritory, 1)
			player:addAchievement("Marid Ally")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_7")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "task") and player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03) == 3 then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask) < 0 or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_6")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GreenDjinnCount) >= 500 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_4")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.MerikhCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_8")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.multi_2")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask, 3)
			player:addExperience(10000, true)
			player:addMoney(5000)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gabel.say_9")
		player:setStorageValue(JOIN_STOR, 1)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GreenDjinnCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GreenDjinnCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.EfreetCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GreenDjinnTask, 0)
	end
	return true
end

-- Greeting
keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, stranger. May Uman open your minds and your hearts to Daraman's wisdom!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Farewell, stranger. May Uman open your minds and your hearts to Daraman's wisdom!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
