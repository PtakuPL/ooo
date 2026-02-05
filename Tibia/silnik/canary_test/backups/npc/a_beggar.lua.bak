local internalNpcName = "A Beggar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 39,
	lookBody = 39,
	lookLegs = 39,
	lookFeet = 76,
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
	if MsgContains(message, "want") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01) == 1 then
			npcHandler:setTopic(playerId, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_beggar.say_1")
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.a_beggar.say_1", "npc.a_beggar.say_2", "npc.a_beggar.say_3", "npc.a_beggar.say_4", "npc.a_beggar.say_5"}, 100)
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01, 2) -- Mission 1 end
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission02, 1) -- Mission 2 start
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_beggar.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
