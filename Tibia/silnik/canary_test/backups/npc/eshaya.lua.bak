local internalNpcName = "Eshaya"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1200,
	lookHead = 95,
	lookBody = 86,
	lookLegs = 79,
	lookFeet = 0,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Praised be Suon and Bastesh." },
	{ text = "I should talk to Kallimae soon." },
	{ text = "Issavi's safety is my first concern." },
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Third.Recovering) == 3 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_1")
			npcHandler:setTopic(playerId, 2)
		elseif player:getItemById(31263, true) and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Third.Recovering) < 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_2")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Third.Recovering, 2)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Title) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_3")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_7")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 6)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fifth.Memories) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_4")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fifth.Memories, 5)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.multi_5")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Title, 1)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Second.Investigating, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "theft") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_6")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "ring of secret thoughts back") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_7")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "ring") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_8")
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourth.Moe, 5)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "empress") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eshaya.say_9")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Suon's and Bastesh's blessing, dear guest!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
