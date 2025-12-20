local internalNpcName = "Lazaran"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 143,
	lookHead = 57,
	lookBody = 57,
	lookLegs = 57,
	lookFeet = 57,
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

	local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
	local UnnaturalSelection = Storage.Quest.U8_54.UnnaturalSelection

	if MsgContains(message, "mission") then
		if npcHandler:getTopic(playerId) == 0 and player:getStorageValue(TheNewFrontier.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_1")
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:getStorageValue(TheNewFrontier.Mission03) == 3 and player:getStorageValue(UnnaturalSelection.Questline) < 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_7")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_8")
				npcHandler:setTopic(playerId, 1)
			end
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_6")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_3")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_4")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.multi_3")
			player:setStorageValue(UnnaturalSelection.Questline, 14)
			player:setStorageValue(UnnaturalSelection.Mission06, 2) -- Questlog, Unnatural Selection Quest "Mission 6: Firewater Burn"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(UnnaturalSelection.Questline) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_5")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "peace") then
		if npcHandler:getTopic(playerId) == 10 and player:getStorageValue(TheNewFrontier.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_6")
			player:setStorageValue(TheNewFrontier.Questline, 9)
			player:setStorageValue(TheNewFrontier.Mission03, 2) -- Questlog, The New Frontier Quest "Mission 03: Strangers in the Night"
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_7")
		npcHandler:setTopic(playerId, 11)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_8")
			player:setStorageValue(UnnaturalSelection.Questline, 1)
			player:setStorageValue(UnnaturalSelection.Mission01, 1) -- Questlog, Unnatural Selection Quest "Mission 1: Skulled"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(10159, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_9")
				player:setStorageValue(UnnaturalSelection.Questline, 2)
				player:setStorageValue(UnnaturalSelection.Mission01, 3) -- Questlog, Unnatural Selection Quest "Mission 1: Skulled"
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_11")
			player:addItem(10159, 1)
			player:setStorageValue(UnnaturalSelection.Questline, 3)
			player:setStorageValue(UnnaturalSelection.Mission02, 1) -- Questlog, Unnatural Selection Quest "Mission 2: All Around the World"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(UnnaturalSelection.Mission02) == 12 and player:getItemCount(10159) >= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_12")
				player:removeItem(10159, 1)
				player:setStorageValue(UnnaturalSelection.Questline, 4)
				player:setStorageValue(UnnaturalSelection.Mission02, 13) -- Questlog, Unnatural Selection Quest "Mission 2: All Around the World"
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_13")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_14")
			player:setStorageValue(UnnaturalSelection.Questline, 5)
			player:setStorageValue(UnnaturalSelection.Mission03, 1) -- Questlog, Unnatural Selection Quest "Mission 3: Dance Dance Evolution"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(3465, 1, 3) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_15")
				player:addItem(10198, 1)
				player:setStorageValue(UnnaturalSelection.Questline, 15)
				player:setStorageValue(UnnaturalSelection.Mission06, 3) -- Questlog, Unnatural Selection Quest "Mission 6: Firewater Burn"
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_16")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_17")
			npcHandler:setTopic(playerId, 12)
		end
	elseif MsgContains(message, "war") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_18")
	elseif MsgContains(message, "little men") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lazaran.say_19")
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lazaran.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
