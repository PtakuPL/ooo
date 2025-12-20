local internalNpcName = "Altar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookTypeEx = 43845,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	message = message:lower()
	if MsgContains(message, "kneel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "offer") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:setTopic(playerId, 0)
		if player:getItemCount(43855) < 5 or player:getItemCount(43854) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_3")
			return true
		end

		if not player:removeMoneyBank(50000000) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_4")
			return true
		end

		if player:removeItem(43855, 5) and player:removeItem(43854, 5) then
			player:addItem(BAG_YOU_COVET, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_5")
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:setTopic(playerId, 0)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.altar.say_6")
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Kneel before the all-devouring power of blooded decay.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
