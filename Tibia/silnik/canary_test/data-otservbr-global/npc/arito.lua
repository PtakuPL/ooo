local internalNpcName = "Arito"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 59,
	lookBody = 111,
	lookLegs = 99,
	lookFeet = 115,
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

local function greetCallback(npc, player)
	if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.AritosTask) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.arito.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.arito.greet_msg_1")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local AritosTask = player:getStorageValue(Storage.Quest.U8_1.TibiaTales.AritosTask)

	-- Check if the message contains "nomads"
	if MsgContains(message, "nomads") then
		if AritosTask <= 0 and player:getItemCount(7533) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_7")
			npcHandler:setTopic(playerId, 1)
		end
		-- Check if the message contains "yes"
	elseif MsgContains(message, "yes") then
		local topic = npcHandler:getTopic(playerId)
		if topic == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.multi_5")
			if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart) <= 0 then
				player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.AritosTask, 1)
		elseif AritosTask == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.say_1")
			npcHandler:setTopic(playerId, 2)
		end
		-- Check if the message contains "Acquitted" and topic is 2
	elseif MsgContains(message, "Acquitted") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arito.say_2")
		player:setStorageValue(Storage.Quest.U8_1.TibiaTales.AritosTask, 3)
		player:addItem(3035, 100)
	end

	return true
end

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.arito.voice_1" },
}

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.arito.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.arito.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.arito.sendtrade_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bread", clientId = 3600, buy = 8 },
	{ itemName = "cheese", clientId = 3607, buy = 12 },
	{ itemName = "fish", clientId = 3578, buy = 6 },
	{ itemName = "ham", clientId = 3582, buy = 16 },
	{ itemName = "ice cube", clientId = 7441, sell = 250 },
	{ itemName = "meat", clientId = 3577, buy = 10 },
	{ itemName = "mug of beer", clientId = 2880, buy = 2, count = 3 },
	{ itemName = "mug of lemonade", clientId = 2880, buy = 2, count = 12 },
	{ itemName = "mug of water", clientId = 2880, buy = 1, count = 1 },
	{ itemName = "mug of wine", clientId = 2880, buy = 3, count = 2 },
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
