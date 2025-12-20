local internalNpcName = "The Beggar King"
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
	lookHead = 0,
	lookBody = 114,
	lookLegs = 94,
	lookFeet = 78,
	lookAddons = 3,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01) == 2 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission02) == 1 and player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ToTakeRoots.Door) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.multi_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "something") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.say_3")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "traces") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_beggar_king.say_4")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "abandoned sewers") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.the_beggar_king.say_1", "npc.the_beggar_king.say_2", "npc.the_beggar_king.say_3", "npc.the_beggar_king.say_4", "npc.the_beggar_king.say_5"}, 10)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission02, 2)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.the_beggar_king.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.the_beggar_king.farewell_msg_1") -- Need revision

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
