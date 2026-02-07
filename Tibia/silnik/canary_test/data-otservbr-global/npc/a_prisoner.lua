local internalNpcName = "A Prisoner"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 81,
	lookBody = 21,
	lookLegs = 54,
	lookFeet = 94,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Mad mage room quest
	if MsgContains(message, "riddle") then
		if player:getStorageValue(Storage.Quest.U7_24.MadMageRoom.APrisoner) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_10")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "PD-D-KS-P-PD") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(3585, 7) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_2")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_3")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U7_24.MadMageRoom.APrisoner, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_6")
			local key = player:addItem(2969, 1)
			if key then
				key:setActionId(Storage.Quest.Key.ID3666)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_7")
	end
	-- The paradox tower quest
	if MsgContains(message, "math") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_11")
			npcHandler:setTopic(playerId, 6)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_9")
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "green") and npcHandler:getTopic(playerId) == 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_10")
		npcHandler:setTopic(playerId, 8)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 8 then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics) < 1 then
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics, 1)
			player:addAchievement("Mathemagician")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_11")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_prisoner.say_12")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.a_prisoner.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.a_prisoner.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_prisoner.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
