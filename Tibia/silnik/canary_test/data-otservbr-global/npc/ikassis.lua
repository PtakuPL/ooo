local internalNpcName = "Ikassis"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 28,
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

local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.multi_5")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.say_1")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 11)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.multi_2")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 5)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ikassis.say_3")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Nature's blessing, traveler!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
