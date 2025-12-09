local internalNpcName = "Fa'Hradin"
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_16")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_17")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.say_2")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission02)
	if MsgContains(message, "spy report") or MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission01) ~= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.say_3")
		elseif missionProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_15")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission02, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.DoorToEfreetTerritory, 1)
		elseif missionProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.say_4")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.say_5")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.RataMari) ~= 2 or not player:removeItem(3232, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_5")
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission02, 2)
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.fa_hradin.multi_2")
		end
	end
	return true
end

-- Greeting
keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, human. I will always remember you. Unless I forget you, of course.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Farewell, human. I will always remember you. Unless I forget you, of course.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
