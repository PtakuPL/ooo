local internalNpcName = "Captain Waverider"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 96,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

	if MsgContains(message, "peg leg") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToMeriana) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "passage") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_3")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_4")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeMoneyBank(50) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_5")
				player:teleportTo(Position(32346, 32625, 7))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_6")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeMoneyBank(200) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_7")
				player:teleportTo(Position(32131, 32913, 7))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_waverider.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_waverider.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.captain_waverider.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_waverider.walkaway_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
