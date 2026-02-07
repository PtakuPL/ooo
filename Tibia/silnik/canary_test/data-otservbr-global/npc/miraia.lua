local internalNpcName = "Miraia"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 150,
	lookHead = 114,
	lookBody = 0,
	lookLegs = 7,
	lookFeet = 132,
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

local topic = {}

local config = {
	["ape fur"] = {
		itemId = 5883,
		count = 100,
		storageValue = 1,
		textKey = {
			"npc.miraia.ape_fur_ask",
			"npc.miraia.ape_fur_info",
			"npc.miraia.ape_fur_done",
		},
	},
	["fish fins"] = {
		itemId = 5895,
		count = 100,
		storageValue = 2,
		textKey = {
			"npc.miraia.fish_fins_ask",
			"npc.miraia.fish_fins_info",
			"npc.miraia.fish_fins_done",
		},
	},
	["enchanted chicken wings"] = {
		itemId = 5891,
		count = 2,
		storageValue = 3,
		textKey = {
			"npc.miraia.chicken_wings_ask",
			"npc.miraia.chicken_wings_info",
			"npc.miraia.chicken_wings_done",
		},
	},
	["blue cloth"] = {
		itemId = 5912,
		count = 100,
		storageValue = 4,
		textKey = {
			"npc.miraia.blue_cloth_ask",
			"npc.miraia.blue_cloth_info",
			"npc.miraia.blue_cloth_done",
		},
	},
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getSex() == PLAYERSEX_FEMALE and MsgContains(message, "outfit") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_1")
	elseif player:getSex() == PLAYERSEX_FEMALE and MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_2")
			npcHandler:setTopic(playerId, 1)
		end
	elseif config[message] and npcHandler:getTopic(playerId) == 0 then
		if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) == config[message].storageValue then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].textKey[1])
			npcHandler:setTopic(playerId, 3)
			topic[playerId] = message
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].textKey[2])
		end
	elseif MsgContains(message, "scarab cheese") then
		if player:getStorageValue(Storage.Quest.U8_1.TheTravellingTrader.Mission03) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_3")
		elseif player:getStorageValue(Storage.Quest.U8_1.TheTravellingTrader.Mission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_4")
		end
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.multi_6")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.OutfitQuest.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			local targetMessage = config[topic[playerId]]
			if not player:removeItem(targetMessage.itemId, targetMessage.count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_6")
				npcHandler:setTopic(playerId, 0)
				return true
			end
			player:setStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon, player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) + 1)
			if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) == 5 then
				player:addOutfitAddon(150, 2) -- female addon
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.textKey[3])
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getMoney() + player:getBankBalance() >= 100 then
				player:setStorageValue(Storage.Quest.U8_1.TheTravellingTrader.Mission03, 2)
				player:addItem(169, 1)
				player:removeMoneyBank(100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_8")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) ~= 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.miraia.say_9")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	topic[playerId] = nil
end

keywordHandler:addKeyword({ "drink" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.miraia.stdmod_1" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.miraia.stdmod_2" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.miraia.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.miraia.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bread", clientId = 3600, buy = 4 },
	{ itemName = "cheese", clientId = 3607, buy = 6 },
	{ itemName = "ham", clientId = 3582, buy = 8 },
	{ itemName = "ice cube", clientId = 7441, sell = 250 },
	{ itemName = "meat", clientId = 3577, buy = 5 },
	{ itemName = "mug of lemonade", clientId = 2880, buy = 3, count = 12 },
	{ itemName = "mug of milk", clientId = 2880, buy = 5, count = 9 },
	{ itemName = "mug of water", clientId = 2880, buy = 2, count = 1 },
	{ itemName = "scarab cheese", clientId = 169, buy = 100 },
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
