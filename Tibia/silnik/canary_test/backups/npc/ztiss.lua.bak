local internalNpcName = "Ztiss"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 340,
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "guezt") then
		if player:getStorageValue(TheNewFrontier.Questline) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_8")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "offer") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "work") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_7")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_4")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ztiss.multi_2")
			player:setStorageValue(TheNewFrontier.Questline, 24)
			player:setStorageValue(TheNewFrontier.Mission08, 2) --Questlog, The New Frontier Quest "Mission 08: An Offer You Can't Refuse"
			player:setStorageValue(TheNewFrontier.Mission09[1], 1) --Questlog, The New Frontier Quest "Mission 08: An Offer You Can't Refuse"
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ztiss.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
