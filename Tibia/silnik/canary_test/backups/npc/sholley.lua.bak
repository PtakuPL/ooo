local internalNpcName = "Sholley"
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
	lookHead = 79,
	lookBody = 86,
	lookLegs = 12,
	lookFeet = 92,
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

	if MsgContains(message, "friend") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission12) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission13) < 1 and player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints) >= 50 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sholley.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sholley.multi_4")
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission13, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "quandon") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission14) == 2 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission15) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sholley.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sholley.multi_2")
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission15, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sholley.say_1")
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.sholley.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
