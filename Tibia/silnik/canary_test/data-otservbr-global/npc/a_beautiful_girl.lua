local internalNpcName = "A Beautiful Girl"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 77,
	lookBody = 81,
	lookLegs = 79,
	lookFeet = 95,
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

-- Localized greet callback
local npcI18n = NPC_LIB and NPC_LIB.i18n

local function greetCallback(npc, creature)
	local player = Player(creature)
	if not player then
		return false
	end

	if npcI18n then
		npcI18n.sayLocalized(player, "npc.a_beautiful_girl.greet", { player:getName() }, MESSAGE_NPC_FROM)
	else
		player:sendTextMessage(MESSAGE_NPC_FROM, string.format("So you have come, %s. I hoped you would not...", player:getName()))
	end
	npcHandler:setMessage(MESSAGE_GREET, "")
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
