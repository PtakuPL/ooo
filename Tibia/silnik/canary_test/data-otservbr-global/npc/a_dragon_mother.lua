local internalNpcName = "A Dragon Mother"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 39,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BabyDragon) < 1 then
		NPC_LIB.i18n.sayLocalized(player, "npc.a_dragon_mother.greet_need_help", nil, MESSAGE_NPC_FROM)
		npcHandler:setTopic(playerId, 1)
		return true
	elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessMachine) == 1 then
		NPC_LIB.i18n.sayLocalized(player, "npc.a_dragon_mother.greet_grrr", nil, MESSAGE_NPC_FROM)
		return true
	elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.HorrorKilled) >= 1 then
		NPC_LIB.i18n.sayLocalized(player, "npc.a_dragon_mother.greet_done", nil, MESSAGE_NPC_FROM)
		player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessMachine, 1)
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "help") then
		NPC_LIB.i18n.sayLocalized(player, "npc.a_dragon_mother.help", nil, MESSAGE_NPC_FROM)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "assistance") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				"npc.a_dragon_mother.assistance_1",
				"npc.a_dragon_mother.assistance_2",
			}, 100)
			npcHandler:setTopic(playerId, 3)
		end
	end

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				"npc.a_dragon_mother.yes_1",
				"npc.a_dragon_mother.yes_2",
			}, 100)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BabyDragon, 1)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.sayLocalized(player, "npc.a_dragon_mother.greet_grrr", nil, MESSAGE_NPC_FROM)
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "egg") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				"npc.a_dragon_mother.egg_1",
				"npc.a_dragon_mother.egg_2",
			}, 100)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BabyDragon, 1)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
