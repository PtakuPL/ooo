local internalNpcName = "A Swan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 25445,
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
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_8")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission01[1]) == 14 then
			if player:getItemCount(25244) >= 5 then
				player:removeItem(25244, 5)
				player:setStorageValue(ThreatenedDreams.Mission01[1], 15)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_4")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.say_1")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_swan.multi_2")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 12)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "I salute you, mortal being.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
