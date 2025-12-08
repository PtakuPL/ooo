local internalNpcName = "A Strange Fellow"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 95,
	lookBody = 118,
	lookLegs = 57,
	lookFeet = 95,
	lookAddons = 2,
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

	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) ~= 1 then
		return true
	end
	if MsgContains(message, "bill") then
		if npcHandler:getTopic(playerId) == 6 then
			npcHandler:sayLocalized("npc.a_strange_fellow.a_bill_oh_1", npc, creature)
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "yes") then
		if player:removeItem(3216, 1) and npcHandler:getTopic(playerId) == 7 then
			npcHandler:sayLocalized("npc.a_strange_fellow.ok_ok_ill_2", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "hat") then
		if npcHandler:getTopic(playerId) < 1 then
			npcHandler:sayLocalized("npc.a_strange_fellow.uh_what_do_3", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.a_strange_fellow.what_my_hat_4", npc, creature)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:sayLocalized("npc.a_strange_fellow.stop_bugging_me_5", npc, creature)
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.a_strange_fellow.hey_dont_touch_6", npc, creature)
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			for i = 1, 5 do
				Game.createMonster("Rabbit", npc:getPosition())
			end
			npcHandler:sayLocalized("npc.a_strange_fellow.noooooo_argh_ok_7", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
