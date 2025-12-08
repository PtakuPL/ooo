local internalNpcName = "Angelo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 145,
	lookHead = 96,
	lookBody = 114,
	lookLegs = 120,
	lookFeet = 101,
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	local player = Player(creature)

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "The Druid of Crunor? He told you that a new cave appeared here? That's right. I'm the head of a {project} that tries to find out more about this new {area}.")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 9 then
		npcHandler:setMessage(MESSAGE_GREET, "Just get out of my way! You killed this beautiful creature. I have nothing more to say. Damn druid of Crunor!")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) > 1 then
		npcHandler:setMessage(MESSAGE_GREET, "How is your {mission} going?")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) < 1 then
		npcHandler:setMessage(MESSAGE_GREET, "The Druid of Crunor? He told you that a new cave appeared here? That's right. I'm the head of a project that tries to find out more about this new area.")
	end

	return true
end
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 3 then
		if MsgContains(message, "mission") then
			npcHandler:sayLocalized("npc.angelo.the_scientists_are_1", npc, creature)
			npcHandler:setTopic(playerId, 15)
		elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 15 then
			npcHandler:sayLocalized("npc.angelo.very_good_hopefully_2", npc, creature)
			player:addItem(25305, 1)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission, 4)
		end
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 5 then
		if MsgContains(message, "mission") then
			npcHandler:sayLocalized("npc.angelo.do_you_have_3", npc, creature)
			npcHandler:setTopic(playerId, 16)
		elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 16 then
			npcHandler:sayLocalized("npc.angelo.thanks_a_lot_4", npc, creature)
			player:addItem(25304, 1)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission, 6)
		end
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 7 then
		if MsgContains(message, "mission") then
			npcHandler:sayLocalized("npc.angelo.what_has_happened_5", npc, creature)
			npcHandler:setTopic(playerId, 17)
		end
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 8 then
		npcHandler:sayLocalized("npc.angelo.just_get_out_6", npc, creature)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission, 9)
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 6 then
		if MsgContains(message, "magnifier") then
			npcHandler:sayLocalized("npc.angelo.gareth_told_you_7", npc, creature)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 7)
		end
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 10 then
		if MsgContains(message, "artefact") then
			npcHandler:sayLocalized("npc.angelo.so_you_found_8", npc, creature)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 11)
		end
	end

	if MsgContains(message, "project") then
		npcHandler:sayLocalized("npc.angelo.the_project_is_9", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "mota") then
		npcHandler:sayLocalized("npc.angelo.mota_is_short_10", npc, creature)
		npcHandler:setTopic(playerId, 3)
	elseif npcHandler:getTopic(playerId) == 3 and MsgContains(message, "results") then
		npcHandler:sayLocalized("npc.angelo.we_have_no_11", npc, creature)
		npcHandler:setTopic(playerId, 4)
	elseif npcHandler:getTopic(playerId) == 4 and MsgContains(message, "worried") then
		npcHandler:sayLocalized("npc.angelo.then_i_have_12", npc, creature)
		npcHandler:setTopic(playerId, 5)
	elseif npcHandler:getTopic(playerId) == 5 and MsgContains(message, "yes") then
		npcHandler:sayLocalized("npc.angelo.fantastic_go_there_13", npc, creature)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission, 2)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.AccessDoor, 1)
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "cave") then
		npcHandler:sayLocalized("npc.angelo.we_dont_know_14", npc, creature)
		npcHandler:setTopic(playerId, 11)
	elseif npcHandler:getTopic(playerId) == 11 and MsgContains(message, "dark pyramid") then
		npcHandler:sayLocalized("npc.angelo.we_dont_know_15", npc, creature)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
