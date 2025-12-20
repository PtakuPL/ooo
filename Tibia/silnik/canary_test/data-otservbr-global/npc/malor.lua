local internalNpcName = "Malor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 103,
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

local function releasePlayer(npc, creature)
	if not Player(creature) then
		return
	end

	npcHandler:removeInteraction(npc, creature)
	npcHandler:resetNpc(creature)
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_22")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_23")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_2")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03)
	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02) == 3 then
			if missionProgress < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_19")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_20")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_21")
				npcHandler:setTopic(playerId, 1)
			elseif missionProgress == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_3")
				npcHandler:setTopic(playerId, 1)
			elseif missionProgress == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_4")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_5")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_18")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_16")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_11")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03, 3)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.DoorToMaridTerritory, 1)
			player:addAchievement("Efreet Ally")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_7")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "task") and player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03) == 3 then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask) < 0 or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_8")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.BlueDjinnCount) >= 500 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_5")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.FahimCount, 0)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_9")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.multi_2")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask, 3)
			player:addExperience(10000, true)
			player:addMoney(5000)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.malor.say_10")
		player:setStorageValue(JOIN_STOR, 1)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.BlueDjinnCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.BlueDjinnCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MaridCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BlueDjinnTask, 0)
	end
	return true
end

keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.malor.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.malor.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
