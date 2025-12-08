local internalNpcName = "Grombur"
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
	lookHead = 114,
	lookBody = 77,
	lookLegs = 79,
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

	if MsgContains(message, "nokmir") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 2 then
			npcHandler:sayLocalized("npc.grombur.oh_well_i_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "rerun") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 3)
			npcHandler:sayLocalized("npc.grombur.yeah_hes_the_2", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.TheGoodGuard) < 1 then
			npcHandler:sayLocalized("npc.grombur.got_any_dwarven_3", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.TheGoodGuard) == 1 and player:removeItem(8774, 1) then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.TheGoodGuard, 2)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DoorSouthMine, 1)
			npcHandler:sayLocalized("npc.grombur.howwhereahhhh_i_dont_4", npc, creature)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.TheGoodGuard, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DefaultStart, 1)
			npcHandler:sayLocalized("npc.grombur.haha_fine_dont_5", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "See you my friend.")
npcHandler:setMessage(MESSAGE_FAREWELL, "See you my friend.")
npcHandler:setMessage(MESSAGE_GREET, "STOP RIGHT THERE!..... Oh, just a human. What's up big guy?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
