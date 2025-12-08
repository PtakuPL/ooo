local internalNpcName = "Nokmir"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 57,
	lookBody = 87,
	lookLegs = 59,
	lookFeet = 114,
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
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nokmir.mission_intro")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 5 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 6)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DoorNorthMine, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nokmir.mission_complete")
		end
	elseif MsgContains(message, "ring") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				"npc.nokmir.ring_story_1",
				"npc.nokmir.ring_story_2",
			}, 2000)
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "grombur") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nokmir.grombur_info")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "rerun") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nokmir.rerun_info")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "rehal") then
		if npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nokmir.rehal_info")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "See you my friend.")
npcHandler:setMessage(MESSAGE_FAREWELL, "See you my friend.")
npcHandler:setMessage(MESSAGE_GREET, "You are....kind of tall! Hello.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
