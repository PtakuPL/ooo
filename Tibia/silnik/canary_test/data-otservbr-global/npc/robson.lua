local internalNpcName = "Robson"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 66,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.robson.voice_1" },
	{ i18nKey = "npc.robson.voice_2" },
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

	if MsgContains(message, "parcel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "label") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		local player = Player(creature)
		if npcHandler:getTopic(playerId) == 1 then
			if not player:removeMoneyBank(15) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:addItem(3503, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_4")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if not player:removeMoneyBank(1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_5")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:addItem(3507, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if table.contains({ 1, 2 }, npcHandler:getTopic(playerId)) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.robson.say_7")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.robson.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.robson.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.robson.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
