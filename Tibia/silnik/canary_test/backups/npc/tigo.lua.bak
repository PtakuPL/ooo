local internalNpcName = "Tigo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 159,
	lookHead = 78,
	lookBody = 6,
	lookLegs = 121,
	lookFeet = 120,
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

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission) < 2 then
		npcHandler:setMessage(MESSAGE_GREET, "There, there initiate. You will now become one of us, as so many before you. One of the {Barkless}. Walk with us and you will walk tall my friend.")
		npcHandler:setTopic(playerId, 1)
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "barkless") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "purest") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "trial") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tigo.multi_6")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.TrialAccessDoor, 1)
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
