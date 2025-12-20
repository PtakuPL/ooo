local internalNpcName = "Nilsor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 154,
	lookHead = 41,
	lookBody = 116,
	lookLegs = 95,
	lookFeet = 114,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "svargrond") or MsgContains(message, "passage") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_1")
		npcHandler:setTopic(playerId, 10)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 10 then
			player:teleportTo(Position(32312, 31074, 7))
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_10")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_7")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 29)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission07, 1) -- Questlog The Ice Islands Quest, The Secret of Helheim
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) > 20 and player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) < 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_2")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "waterskin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_4")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "cactus") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 21 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_5")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "water") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_5")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "sulphur") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_6")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "herb") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 24 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_7")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "blossom") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_8")
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "hydra tongue") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_9")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "spores") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_10")
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_3")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 21)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 1) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getMoney() + player:getBankBalance() >= 25 then
				player:removeMoneyBank(25)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_11")
				player:addItem(7286, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_12")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(7245, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_13")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 22)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 2) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_14")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(7246, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_15")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 23)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 3) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_16")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(7247, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_17")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 24)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 4) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_18")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(7248, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_19")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 25)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 5) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_20")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(7249, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_21")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 26)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 6) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_22")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(7250, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_23")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 27)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 7) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_24")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(7251, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_25")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 28)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 8) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_26")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) >= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.say_27")
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.nilsor.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
