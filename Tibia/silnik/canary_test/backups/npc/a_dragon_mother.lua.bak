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
		npcHandler:setMessage(MESSAGE_GREET, "Greetings humans! Consider yourselfs lucky, I'm in need of {help}.")
		npcHandler:setTopic(playerId, 1)
		return true
	elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessMachine) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Grrr.")
		return true
	elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.HorrorKilled) >= 1 then
		npcHandler:setMessage(MESSAGE_GREET, "You have done me a favour and the knowledge you are seeking shall be yours. I melted the ice for you, you can pass now.")
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.say_1")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "assistance") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_7")
			npcHandler:setTopic(playerId, 3)
		end
	end

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_5")
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BabyDragon, 1)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_3")
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "egg") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_dragon_mother.multi_2")
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
