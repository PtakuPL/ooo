local internalNpcName = "Skjaar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 9,
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

	if MsgContains(message, "key") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		if player:removeMoneyBank(1000) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_3")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "redips") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_5")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "7") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_6")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "black") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_7")
		npcHandler:setTopic(playerId, 6)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.skjaar.say_8")
		local key = player:addItem(2970, 1)
		if key then
			key:setActionId(3142)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Another creature who believes thinks physical strength is more important than wisdom! Why are you disturbing me?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Run away, unworthy |PLAYERNAME|!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
