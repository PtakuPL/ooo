local internalNpcName = "The Empress"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1188,
	lookHead = 79,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 3,
	lookAddons = 3,
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

	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Sixth.Favor) == 10 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.the_empress.greet_msg_2",
			"npc.the_empress.greet_msg_3",
		}, 1000)
		player:addItem(31573, 1)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Sixth.Favor, 11)
		return false
	elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fifth.Memories) == 5 then
		player:addItem(31414, 1)
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.the_empress.greet_msg_4",
			"npc.the_empress.greet_msg_5",
			"npc.the_empress.greet_msg_6",
			"npc.the_empress.greet_msg_7",
			"npc.the_empress.greet_msg_8",
		}, 1000)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Sixth.Favor, 1)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Sixth.FourMasks, 0)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Sixth.BlessedStatues, 0)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fifth.Memories, 6)
		return false
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.the_empress.greet_msg_1")
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.the_empress.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
