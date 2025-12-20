local internalNpcName = "Moe"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 118,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.moe.voice_1" },
	{ i18nKey = "npc.moe.voice_2" },
	{ i18nKey = "npc.moe.voice_3" },
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

	if MsgContains(message, "help") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_1")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 2)
		end
	elseif MsgContains(message, "feathers") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) == 2 then
			if player:getItemById(31437, 10) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_2")
				player:removeItem(31437, 10)
				player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 3)
				player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.MoeTimer, os.time() + 60 * 60)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_3")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_4")
		end
	elseif MsgContains(message, "ring") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) == 3 then
			local timeLeft = player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.MoeTimer) - os.time()
			if timeLeft <= 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_5")
				player:addItem(31306, 1)
				player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 4)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_6")
			end
		elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_7")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_8")
		end
	elseif MsgContains(message, "lyre") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_9")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.moe.say_10")
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.moe.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.moe.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
