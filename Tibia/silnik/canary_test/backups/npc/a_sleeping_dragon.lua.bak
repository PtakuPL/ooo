local internalNpcName = "A Sleeping Dragon"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 168,
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
	if Player(creature):getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 27 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_sleeping_dragon.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_sleeping_dragon.greet_msg_1")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 27 then
		if (message == "SOLOSARASATIQUARIUM") and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.InterdimensionalPotion) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_33")
			npcHandler:setTopic(playerId, 1)
		elseif message:lower() == "help" and npcHandler:getTopic(playerId) > 0 and npcHandler:getTopic(playerId) < 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_1")
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif message:lower() == "take attachment" and npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif message:lower() == "take stand" and npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_6")
			npcHandler:setTopic(playerId, 6)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_7")
			npcHandler:setTopic(playerId, 7)
		elseif message:lower() == "take model" and npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_8")
			npcHandler:setTopic(playerId, 8)
		elseif message:lower() == "take emeralds" and npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_9")
			npcHandler:setTopic(playerId, 9)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_10")
			npcHandler:setTopic(playerId, 10)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_11")
			npcHandler:setTopic(playerId, 11)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_12")
			npcHandler:setTopic(playerId, 12)
		elseif message:lower() == "take rubies" and npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_13")
			npcHandler:setTopic(playerId, 13)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_14")
			npcHandler:setTopic(playerId, 14)
		elseif message:lower() == "use attachment" and npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_15")
			npcHandler:setTopic(playerId, 15)
		elseif message:lower() == "take mirror" and npcHandler:getTopic(playerId) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_20")
			npcHandler:setTopic(playerId, 16)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_16")
			npcHandler:setTopic(playerId, 17)
		elseif message:lower() == "use model" and npcHandler:getTopic(playerId) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_18")
			npcHandler:setTopic(playerId, 18)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_17")
			npcHandler:setTopic(playerId, 19)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_18")
			npcHandler:setTopic(playerId, 20)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_19")
			npcHandler:setTopic(playerId, 21)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 21 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_20")
			npcHandler:setTopic(playerId, 22)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_21")
			npcHandler:setTopic(playerId, 23)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_22")
			npcHandler:setTopic(playerId, 24)
		elseif message:lower() == "take sapphire" and npcHandler:getTopic(playerId) == 24 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_23")
			npcHandler:setTopic(playerId, 25)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_24")
			npcHandler:setTopic(playerId, 26)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_25")
			npcHandler:setTopic(playerId, 27)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_26")
			npcHandler:setTopic(playerId, 28)
		elseif message:lower() == "use stand" and npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_27")
			npcHandler:setTopic(playerId, 29)
		elseif message:lower() == "use ruby" and npcHandler:getTopic(playerId) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_28")
			npcHandler:setTopic(playerId, 30)
		elseif message:lower() == "use sapphire" and npcHandler:getTopic(playerId) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_29")
			npcHandler:setTopic(playerId, 31)
		elseif message:lower() == "use emerald" and npcHandler:getTopic(playerId) == 31 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_30")
			npcHandler:setTopic(playerId, 32)
		elseif message:lower() == "use mirror" and npcHandler:getTopic(playerId) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_16")
			player:addAchievement("Wayfarer")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 28)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission09, 2) --Questlog, Wrath of the Emperor "Mission 09: The Sleeping Dragon"
			npcHandler:setTopic(playerId, 0)
		end
	elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 28 then
		if MsgContains(message, "wayfarer") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_31")
		elseif MsgContains(message, "mission") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_9")
			npcHandler:setTopic(playerId, 41)
		elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 41 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.multi_6")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 29)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission10, 1) --Questlog, Wrath of the Emperor "Mission 10: A Message of Freedom"
			player:addItem(10343, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
