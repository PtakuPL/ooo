local internalNpcName = "An Old Dragonlord"
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
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.an_old_dragon_lord.voice_1" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	if not (MsgContains(message, "hi") or MsgContains(message, "hello")) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.an_old_dragon_lord.say_1")
	end
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Dragonfetish) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.an_old_dragon_lord.say_2")
		return false
	end

	if not player:removeItem(3723, 1) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.an_old_dragon_lord.say_3")
		return false
	end

	player:setStorageValue(Storage.Dragonfetish, 1)
	player:addItem(3206, 1)
	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.an_old_dragon_lord.say_4")
	return false
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
