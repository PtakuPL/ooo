local internalNpcName = "Charlotta"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 157,
	lookHead = 38,
	lookBody = 97,
	lookLegs = 115,
	lookFeet = 95,
	lookAddons = 1,
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

	if MsgContains(message, "errand") or MsgContains(message, "gold") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charlotta.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeMoneyBank(200) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charlotta.say_2")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheErrand, 2)
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charlotta.say_3")
			end
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.charlotta.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.charlotta.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.charlotta.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.charlotta.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
