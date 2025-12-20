local internalNpcName = "Noozer"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 430,
	lookHead = 39,
	lookBody = 39,
	lookLegs = 39,
	lookFeet = 19,
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

	if MsgContains(message, "pass") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.multi_5")
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission) < 2 then
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission, 2)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Misguided.AccessDoor, 1)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "cave") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.say_1")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "job") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.say_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.noozer.say_3")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.noozer.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.noozer.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
