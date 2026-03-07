local internalNpcName = "Siflind"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 158,
	lookHead = 76,
	lookBody = 81,
	lookLegs = 95,
	lookFeet = 114,
	lookAddons = 1,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_2")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_3")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 10)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_4")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 11)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 1) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_6")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 13)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 2) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_7")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_8")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 15)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 3) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_9")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_10")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 17)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 4) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_11")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_12")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 19)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 5) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_13")
			npcHandler:setTopic(playerId, 9)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_14")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "jug") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_15")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.multi_3")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission03, 1) -- Questlog The Ice Islands Quest, Nibelor 2: Ecological Terrorism
			player:addItem(7243, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getMoney() + player:getBankBalance() >= 1000 then
				player:removeMoneyBank(1000)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_16")
				npcHandler:setTopic(playerId, 0)
				player:addItem(7243, 1)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_17")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_18")
			player:addItem(7253, 1)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 8)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission04, 1) -- Questlog The Ice Islands Quest, Nibelor 3: Artful Sabotage
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then -- Wings
			if player:removeItem(5894, 5) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_19")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 12)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_20")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then -- Paws
			if player:removeItem(5896, 4) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_21")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 14)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_22")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then -- Eyes
			if player:removeItem(5898, 3) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_23")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 16)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_24")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then -- Fins
			if player:removeItem(5895, 2) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_25")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 18)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_26")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then -- Scale
			if player:removeItem(5920, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_27")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 20)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission05, 6) -- Questlog The Ice Islands Quest, Nibelor 4: Berserk Brewery
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_28")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "buy animal cure") or MsgContains(message, "animal cure") then -- animal cure for in service of yalahar
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) >= 30 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) <= 54 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_29")
			npcHandler:setTopic(playerId, 13)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_30")
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 13 then
		if npcHandler:getTopic(playerId) == 13 and player:removeMoneyBank(400) then
			player:addItem(8819, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_31")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.siflind.say_32")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.siflind.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "animal cure", clientId = 8819, buy = 400 },
	{ itemName = "avalanche rune", clientId = 3161, buy = 64 },
	{ itemName = "blank rune", clientId = 3147, buy = 10 },
	{ itemName = "chameleon rune", clientId = 3178, buy = 210 },
	{ itemName = "convince creature rune", clientId = 3177, buy = 80 },
	{ itemName = "cure poison rune", clientId = 3153, buy = 65 },
	{ itemName = "destroy field rune", clientId = 3148, buy = 15 },
	{ itemName = "durable exercise rod", clientId = 35283, buy = 1250000, count = 1800 },
	{ itemName = "durable exercise wand", clientId = 35284, buy = 1250000, count = 1800 },
	{ itemName = "empty potion flask", clientId = 283, sell = 5 },
	{ itemName = "empty potion flask", clientId = 284, sell = 5 },
	{ itemName = "empty potion flask", clientId = 285, sell = 5 },
	{ itemName = "energy field rune", clientId = 3164, buy = 38 },
	{ itemName = "energy wall rune", clientId = 3166, buy = 85 },
	{ itemName = "exercise rod", clientId = 28556, buy = 347222, count = 500 },
	{ itemName = "exercise wand", clientId = 28557, buy = 347222, count = 500 },
	{ itemName = "explosion rune", clientId = 3200, buy = 31 },
	{ itemName = "fire bomb rune", clientId = 3192, buy = 147 },
	{ itemName = "fire field rune", clientId = 3188, buy = 28 },
	{ itemName = "fire wall rune", clientId = 3190, buy = 61 },
	{ itemName = "great fireball rune", clientId = 3191, buy = 64 },
	{ itemName = "great health potion", clientId = 239, buy = 225 },
	{ itemName = "great mana potion", clientId = 238, buy = 158 },
	{ itemName = "great spirit potion", clientId = 7642, buy = 254 },
	{ itemName = "hailstorm rod", clientId = 3067, buy = 15000 },
	{ itemName = "health potion", clientId = 266, buy = 50 },
	{ itemName = "heavy magic missile rune", clientId = 3198, buy = 12 },
	{ itemName = "intense healing rune", clientId = 3152, buy = 95 },
	{ itemName = "lasting exercise rod", clientId = 35289, buy = 10000000, count = 14400 },
	{ itemName = "lasting exercise wand", clientId = 35290, buy = 10000000, count = 14400 },
	{ itemName = "light magic missile rune", clientId = 3174, buy = 4 },
	{ itemName = "mana potion", clientId = 268, buy = 56 },
	{ itemName = "moonlight rod", clientId = 3070, buy = 1000 },
	{ itemName = "necrotic rod", clientId = 3069, buy = 5000 },
	{ itemName = "northwind rod", clientId = 8083, buy = 7500 },
	{ itemName = "poison field rune", clientId = 3172, buy = 21 },
	{ itemName = "poison wall rune", clientId = 3176, buy = 52 },
	{ itemName = "snakebite rod", clientId = 3066, buy = 500 },
	{ itemName = "spellbook", clientId = 6120, buy = 150 },
	{ itemName = "springsprout rod", clientId = 8084, buy = 18000 },
	{ itemName = "stalagmite rune", clientId = 3179, buy = 12 },
	{ itemName = "strong health potion", clientId = 236, buy = 115 },
	{ itemName = "strong mana potion", clientId = 237, buy = 108 },
	{ itemName = "sudden death rune", clientId = 3155, buy = 162 },
	{ itemName = "supreme health potion", clientId = 23375, buy = 650 },
	{ itemName = "terra rod", clientId = 3065, buy = 10000 },
	{ itemName = "ultimate healing rune", clientId = 3160, buy = 175 },
	{ itemName = "ultimate health potion", clientId = 7643, buy = 379 },
	{ itemName = "ultimate mana potion", clientId = 23373, buy = 488 },
	{ itemName = "ultimate spirit potion", clientId = 23374, buy = 488 },
	{ itemName = "underworld rod", clientId = 8082, buy = 22000 },
	{ itemName = "vial", clientId = 2874, sell = 5 },
	{ itemName = "wand of cosmic energy", clientId = 3073, buy = 10000 },
	{ itemName = "wand of decay", clientId = 3072, buy = 5000 },
	{ itemName = "wand of draconia", clientId = 8093, buy = 7500 },
	{ itemName = "wand of dragonbreath", clientId = 3075, buy = 1000 },
	{ itemName = "wand of inferno", clientId = 3071, buy = 15000 },
	{ itemName = "wand of starstorm", clientId = 8092, buy = 18000 },
	{ itemName = "wand of voodoo", clientId = 8094, buy = 22000 },
	{ itemName = "wand of vortex", clientId = 3074, buy = 500 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
