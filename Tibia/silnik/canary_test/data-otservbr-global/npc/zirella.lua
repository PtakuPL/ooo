local internalNpcName = "Zirella"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 157,
	lookHead = 57,
	lookBody = 111,
	lookLegs = 67,
	lookFeet = 95,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "I wish someone could spare a minute and help me..." },
	{ text = "This is too hard for an old woman like me." },
	{ text = "Hello, young adventurer, you look strong enough to help me!" },
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

local storeTalkCid = {}
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) < 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh, heaven must have sent you! Could you please help me with a {quest}?")
		storeTalkCid[playerId] = 0
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, darling... so about that firewood, could you please {help} me?")
		storeTalkCid[playerId] = 2
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 2 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, darling... so about the {dead trees}, let me explain that a little more, {yes}?")
		storeTalkCid[playerId] = 3
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 3 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, darling... so about the {branches}, let me explain that a little more, {yes}?")
		storeTalkCid[playerId] = 4
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 4 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, darling... so about the {pushing}, let me explain that a little more, {yes}?")
		storeTalkCid[playerId] = 5
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 5 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, darling... so about the {cart}, let me explain that a little more, {yes}?")
		storeTalkCid[playerId] = 6
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 6 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh, sweetheart, is there a problem with the quest? Should I {explain} it again?")
		storeTalkCid[playerId] = 7
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 7 then
		npcHandler:setMessage(MESSAGE_GREET, "Right, thank you sweetheart! This will be enough to heat my oven. Oh, and you are probably waiting for your reward, {yes}?")
		storeTalkCid[playerId] = 8
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage) == 8 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh, welcome back, dear Isleth Eagonst! Are you here for a little chat? Just use the highlighted {keywords} again to choose a {topic}.")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "yes", "quest", "ok" }, message) then
		if storeTalkCid[playerId] == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_1")
			storeTalkCid[playerId] = 1
		elseif storeTalkCid[playerId] == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_2")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 1)
			storeTalkCid[playerId] = 2
		elseif storeTalkCid[playerId] == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_3")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 2)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 2)
			storeTalkCid[playerId] = 3
		elseif storeTalkCid[playerId] == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_4")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 3)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 3)
			storeTalkCid[playerId] = 4
		elseif storeTalkCid[playerId] == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_5")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 4)
			storeTalkCid[playerId] = 5
		elseif storeTalkCid[playerId] == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_6")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 5)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 5)
			storeTalkCid[playerId] = 6
		elseif storeTalkCid[playerId] == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_7")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 6)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 6)
			Position(32064, 32273, 7):sendMagicEffect(CONST_ME_TUTORIALARROW)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif storeTalkCid[playerId] == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.multi_3")
			storeTalkCid[playerId] = nil
		elseif storeTalkCid[playerId] == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_7")
			player:addExperience(50, true)
			Position(32058, 32266, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaQuestLog, 8)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.ZirellaNpcGreetStorage, 8)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "no") then
		if storeTalkCid[playerId] == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zirella.say_8")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	storeTalkCid[playerId] = nil
end

npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye |PLAYERNAME|, may Uman bless you!.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye traveller, take care.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
