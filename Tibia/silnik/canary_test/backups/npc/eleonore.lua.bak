local internalNpcName = "Eleonore"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 114,
	lookBody = 66,
	lookLegs = 34,
	lookFeet = 53,
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

	if MsgContains(message, "ring") or MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_10")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter) == 3 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "errand") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_3")
			player:addMoney(5)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "peg leg") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_4")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "raymond striker") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToLagunaIsland) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mermaid") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToLagunaIsland) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(6093, 1) then
				player:addMoney(150)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_7")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter, 3)
				npcHandler:setTopic(playerId, 2)
			else
				player:addMoney(150)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_7")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_8")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheGovernorDaughter, 3)
				npcHandler:setTopic(playerId, 2)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_8")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			player:addMoney(200)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_9")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.multi_6")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand, 4)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToMeriana, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eleonore.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.eleonore.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.eleonore.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.eleonore.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
