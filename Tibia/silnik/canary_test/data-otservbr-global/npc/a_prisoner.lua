local internalNpcName = "A Prisoner"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 81,
	lookBody = 21,
	lookLegs = 54,
	lookFeet = 94,
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

	-- Mad mage room quest
	if MsgContains(message, "riddle") then
		if player:getStorageValue(Storage.Quest.U7_24.MadMageRoom.APrisoner) ~= 1 then
			npcHandler:say(
				"Great riddle, isn't it? If you can tell me the correct answer, \z
				I will give you something. Hehehe!",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "PD-D-KS-P-PD") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.a_prisoner.hurray_for_that_1", npc, creature)
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(3585, 7) then
				npcHandler:sayLocalized("npc.a_prisoner.mnjam_excellent_apples_2", npc, creature)
				npcHandler:setTopic(playerId, 3)
			else
				npcHandler:sayLocalized("npc.a_prisoner.get_some_more_3", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:sayLocalized("npc.a_prisoner.really_really_4", npc, creature)
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.a_prisoner.really_really_really_5", npc, creature)
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U7_24.MadMageRoom.APrisoner, 1)
			npcHandler:sayLocalized("npc.a_prisoner.then_take_it_6", npc, creature)
			local key = player:addItem(2969, 1)
			if key then
				key:setActionId(Storage.Quest.Key.ID3666)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		npcHandler:sayLocalized("npc.a_prisoner.then_go_away_7", npc, creature)
	end
	-- The paradox tower quest
	if MsgContains(message, "math") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics) < 1 then
			npcHandler:say(
				"My surreal numbers are based on astonishing facts. \z
				Are you interested in learning the secret of mathemagics?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 6)
		else
			npcHandler:sayLocalized("npc.a_prisoner.you_already_know_8", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		npcHandler:sayLocalized("npc.a_prisoner.but_first_tell_9", npc, creature)
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "green") and npcHandler:getTopic(playerId) == 7 then
		npcHandler:sayLocalized("npc.a_prisoner.very_interesting_so_10", npc, creature)
		npcHandler:setTopic(playerId, 8)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 8 then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics) < 1 then
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.Mathemagics, 1)
			player:addAchievement("Mathemagician")
			npcHandler:sayLocalized("npc.a_prisoner.so_know_that_11", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			npcHandler:sayLocalized("npc.a_prisoner.i_think_you_12", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "Wait! Don't leave! I want to tell you about my surreal numbers.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye! Don't forget about the secrets of mathemagics.")
npcHandler:setMessage(MESSAGE_GREET, "Huh? What? I can see! Wow! A non-mino. Did they {capture} you as well?")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
