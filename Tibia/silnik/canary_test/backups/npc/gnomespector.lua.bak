local internalNpcName = "Gnomespector"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 59,
	lookBody = 59,
	lookLegs = 59,
	lookFeet = 58,
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

	if not player then
		return false
	end

	if MsgContains(message, "recruit") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomespector.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomespector.multi_2")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 8)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "apparatus") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomespector.say_1")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomespector.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
