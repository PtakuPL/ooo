local internalNpcName = "Rock Steady"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 13424,
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

	if MsgContains(message, "addon") or MsgContains(message, "help") then
		if player:getStorageValue(72326) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_1")
			player:setStorageValue(72326, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "collect") then
		if player:getStorageValue(72326) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_6")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(72326) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(72326) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(72326) == 4 and player:removeItem(14021, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.multi_3")
			player:addOutfitAddon(464, 1)
			player:addOutfitAddon(463, 1)
			player:setStorageValue(72326, 5)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_4")
			player:setStorageValue(72326, 2)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 and player:removeItem(14022, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_5")
			player:setStorageValue(72326, 3)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 and player:removeItem(14023, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_6")
			player:setStorageValue(72326, 4)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rock_steady.say_7")
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
