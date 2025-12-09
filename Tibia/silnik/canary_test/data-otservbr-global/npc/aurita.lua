local internalNpcName = "Aurita"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 5811,
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
		if player:getStorageValue(ThreatenedDreams.Mission03[1]) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_11")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission03[1]) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_8")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(ThreatenedDreams.Mission03[1]) >= 2 and player:getStorageValue(ThreatenedDreams.Mission03[1]) <= 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_7")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "starlight vial") or MsgContains(message, "empty starlight vial") then
		if player:getStorageValue(ThreatenedDreams.Mission03[1]) == 4 then
			if player:getStorageValue(ThreatenedDreams.Mission03.EmptyStarlightVial) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_5")
				player:addItem(25731, 1)
				player:setStorageValue(ThreatenedDreams.Mission03.EmptyStarlightVial, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_3")
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.multi_2")
			player:setStorageValue(ThreatenedDreams.Mission03[1], 1)
			player:setStorageValue(ThreatenedDreams.Mission03.UnlikelyCouple, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aurita.say_1")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, traveller!")
npcHandler:setMessage(MESSAGE_FAREWELL, "May your path always be even.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "May your path always be even.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
