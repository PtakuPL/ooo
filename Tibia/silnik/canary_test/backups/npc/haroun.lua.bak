local internalNpcName = "Haroun"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 80,
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

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	--Checks if the player has completed the quest
	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03) ~= 3 then
		if not MsgContains(message, "djanni'hah") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_1")
			endConversationWithDelay(npcHandler, npc, creature)
			return false
		end

		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Start) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.multi_2")
			endConversationWithDelay(npcHandler, npc, creature)
			return false
		end
	end

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_2")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "enchanted chicken wing", "boots of haste" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_3")
		npcHandler:setTopic(playerId, 1)
	elseif table.contains({ "warrior sweat", "warrior helmet" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_4")
		npcHandler:setTopic(playerId, 2)
	elseif table.contains({ "fighting spirit", "royal helmet" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_5")
		npcHandler:setTopic(playerId, 3)
	elseif table.contains({ "magic sulphur", "fire sword" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_6")
		npcHandler:setTopic(playerId, 4)
	elseif table.contains({ "job", "items" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_7")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) <= 4 and npcHandler:getTopic(playerId) >= 1 then
		local trade = {
			{ NeedItem = 3079, Ncount = 1, GiveItem = 5891, Gcount = 1 }, -- Enchanted Chicken Wing
			{ NeedItem = 3369, Ncount = 4, GiveItem = 5885, Gcount = 1 }, -- Flask of Warrior's Sweat
			{ NeedItem = 3392, Ncount = 2, GiveItem = 5884, Gcount = 1 }, -- Spirit Container
			{ NeedItem = 3280, Ncount = 3, GiveItem = 5904, Gcount = 1 }, -- Magic Sulphur
		}
		if player:getItemCount(trade[npcHandler:getTopic(playerId)].NeedItem) >= trade[npcHandler:getTopic(playerId)].Ncount then
			player:removeItem(trade[npcHandler:getTopic(playerId)].NeedItem, trade[npcHandler:getTopic(playerId)].Ncount)
			player:addItem(trade[npcHandler:getTopic(playerId)].GiveItem, trade[npcHandler:getTopic(playerId)].Gcount)
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_8")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_9")
		end
	elseif MsgContains(message, "no") and (npcHandler:getTopic(playerId) >= 1 and npcHandler:getTopic(playerId) <= 5) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_10")
		npcHandler:setTopic(playerId, 0)
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	end
	return true
end

local function onTradeRequest(npc, creature)
	local player = Player(creature)

	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03) ~= 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.haroun.say_11")
		return false
	end

	return true
end

-- Greeting
keywordHandler:addCustomGreetKeyword({ "djanni'hah" }, greetCallback, { npcHandler = npcHandler })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.haroun.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.haroun.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.haroun.sendtrade_msg_1")

npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "axe ring", clientId = 3092, buy = 500, sell = 100 },
	{ itemName = "bronze amulet", clientId = 3056, buy = 100, sell = 50, count = 200 },
	{ itemName = "club ring", clientId = 3093, buy = 500, sell = 100 },
	{ itemName = "elven amulet", clientId = 3082, buy = 500, sell = 100, count = 50 },
	{ itemName = "garlic necklace", clientId = 3083, buy = 100, sell = 50 },
	{ itemName = "life crystal", clientId = 3061, sell = 50 },
	{ itemName = "magic light wand", clientId = 3046, buy = 120, sell = 35 },
	{ itemName = "mind stone", clientId = 3062, sell = 100 },
	{ itemName = "orb", clientId = 3060, sell = 750 },
	{ itemName = "power ring", clientId = 3050, buy = 100, sell = 50 },
	{ itemName = "stealth ring", clientId = 3049, buy = 5000, sell = 200 },
	{ itemName = "stone skin amulet", clientId = 3081, buy = 25000, sell = 500, count = 5 },
	{ itemName = "sword ring", clientId = 3091, buy = 500, sell = 100 },
	{ itemName = "wand of cosmic energy", clientId = 3073, sell = 2000 },
	{ itemName = "wand of decay", clientId = 3072, sell = 1000 },
	{ itemName = "wand of defiance", clientId = 16096, sell = 6500 },
	{ itemName = "wand of draconia", clientId = 8093, sell = 1500 },
	{ itemName = "wand of dragonbreath", clientId = 3075, sell = 200 },
	{ itemName = "wand of everblazing", clientId = 16115, sell = 6000 },
	{ itemName = "wand of inferno", clientId = 3071, sell = 3000 },
	{ itemName = "wand of starstorm", clientId = 8092, sell = 3600 },
	{ itemName = "wand of voodoo", clientId = 8094, sell = 4400 },
	{ itemName = "wand of vortex", clientId = 3074, sell = 100 },
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
