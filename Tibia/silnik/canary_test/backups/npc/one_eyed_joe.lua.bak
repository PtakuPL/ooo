local internalNpcName = "One-Eyed Joe"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 155,
	lookHead = 94,
	lookBody = 114,
	lookLegs = 105,
	lookFeet = 97,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.one_eyed_joe.voice_1" },
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
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local playerId = player:getId()
	local currentTime = os.time()

	if player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) == 3 and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Questline) == 3 then
		player:addAchievement("Wail of the Banshee")
		player:addItem(16119, 1)
		player:addItem(16120, 1)
		player:addItem(16121, 1)

		local chanceToPirate = math.random(1, 4)
		local pirateItems = { [1] = 5926, [2] = 6098, [3] = 6097, [4] = 6126 }
		player:addItem(pirateItems[chanceToPirate], 1)

		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe, 4)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Questline, 4)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Time, currentTime + 20 * 60 * 60)
		npcHandler:setMessage(MESSAGE_GREET, "Well done! But know this: The cursed crystal seems to regenerate over time. It could be necessary to come back and repeat whatever you have done down there.")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Hello there. I'm sorry, I hardly noticed you. I'm a bit nervous. The spooky {sounds} down there, you know")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local playerId = player:getId()
	local currentTime = os.time()
	local questTime = player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Time)

	if questTime > 0 and currentTime >= questTime then
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe, -1)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Questline, -1)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.MedusaOil, -1)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.SheetOfPaper, -1)
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.SmallCrystalBell, -1)
	end

	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) < 0 and npcHandler:getTopic(playerId) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_10")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) > 0 and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) < 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_1")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) > 0 and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) < 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "protect ears") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_3")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_8")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
		if player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Questline) < 0 then
			player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Questline, 0)
		end
		player:setStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe, 0)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_4")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "crystals") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_6")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "cursed") and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) < 0 and npcHandler:getTopic(playerId) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_4")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "sounds") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.multi_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "job") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_5")
	elseif MsgContains(message, "name") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_6")
	elseif MsgContains(message, "bye") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_7")
		npcHandler:setTopic(playerId, 0)
	elseif player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) >= 0 and player:getStorageValue(Storage.Quest.U10_70.TheCursedCrystal.Oneeyedjoe) < 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.one_eyed_joe.say_8")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
