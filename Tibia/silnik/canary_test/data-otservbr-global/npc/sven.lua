local internalNpcName = "Sven"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 143,
	lookHead = 76,
	lookBody = 57,
	lookLegs = 115,
	lookFeet = 40,
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

local function greetCallback(npc, player)
	if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus) == 1 then
		npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.sven.greet_msg_2", {
			args = function(targetPlayer)
				return { targetPlayer:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) * 1500 }
			end,
		})
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.sven.greet_msg_1")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "barbarian") and player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "test") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_15")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_16")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "mead") and player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_2")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "barbarian mead") and player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_14")
		player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, 4)
		player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission02, 1) -- Questlog Barbarian Test Quest Barbarian Test 2: The Bear Hugging
		player:addItem(7140, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "hug") then
		if player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_10")
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission03, 1) -- Questlog Barbarian Test Quest Barbarian Test 3: The Mammoth Pushing
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mammoth") then
		if player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_7")
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, 8)
			player:addAchievement("Honorary Barbarian")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus) == 1 and player:getStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline) == 8 then
			if player:removeMoneyBank(player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) * 1500) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_3")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus, 0)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill, 0)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_4")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_5")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.multi_2")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission01, 1) -- Questlog Barbarian Test Quest Barbarian Test 1: Barbarian Booze
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(5902, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_5")
				npcHandler:setTopic(playerId, 0)
				player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, 2)
				player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission01, 2) -- Questlog Barbarian Test Quest Barbarian Test 1: Barbarian Booze
				player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.MeadTotalSips, 0)
			end
		end
	elseif MsgContains(message, "no") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKillStatus) == 1 and npcHandler:getTopic(playerId) == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_1", { player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.HuskyKill) * 1500 })
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sven.say_6")
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Questline, -1)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission01, -1)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission02, -1)
			player:setStorageValue(Storage.Quest.U8_0.BarbarianTest.Mission03, -1)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
