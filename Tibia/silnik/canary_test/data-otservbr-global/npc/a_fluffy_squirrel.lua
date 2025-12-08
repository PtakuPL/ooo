local internalNpcName = "A Fluffy Squirrel"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 274,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Chchch" },
}
npcConfig.shop = { -- Sellable items
	{ itemName = "acorn", clientId = 10296, sell = 10 },
	{ itemName = "walnut", clientId = 836, sell = 80 },
}

-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	sendLocalized(
		Player(player),
		"npc.a_fluffy_squirrel.trade_sold",
		"Sold %ix %s for %i gold.",
		MESSAGE_TRADE,
		{ amount, name, totalCost }
	)
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n

if npcI18n and npcHandler.setLocalizedMessage then
	npcI18n.setLocalizedGreet(npcHandler, "npc.a_fluffy_squirrel.greet")
	npcI18n.setLocalizedFarewell(npcHandler, "npc.a_fluffy_squirrel.farewell")
	npcI18n.setLocalizedWalkaway(npcHandler, "npc.a_fluffy_squirrel.walkaway")
	npcI18n.setLocalizedTradeMessage(npcHandler, "npc.a_fluffy_squirrel.trade_offer")
else
	npcHandler:setMessage(MESSAGE_GREET, "Chhchh?")
	npcHandler:setMessage(MESSAGE_FAREWELL, "Chh...")
	npcHandler:setMessage(MESSAGE_WALKAWAY, "Chh...")
	npcHandler:setMessage(MESSAGE_SENDTRADE, "Chchch. Chh! <you're not sure, but it seems that squirrel wants to trade your valuable acorns for useless stones that it found and considered uneatable>")
end

local function sendLocalized(player, key, fallback, messageClass, args)
	if not player then
		return false
	end

	if npcI18n then
		return npcI18n.sayLocalized(player, key, args, messageClass or MESSAGE_NPC_FROM)
	end

	if fallback and fallback ~= "" then
		if args and #args > 0 then
			player:sendTextMessage(messageClass or MESSAGE_NPC_FROM, string.format(fallback, table.unpack(args)))
		else
			player:sendTextMessage(messageClass or MESSAGE_NPC_FROM, fallback)
		end
	end
	return true
end

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

keywordHandler:addKeyword({ "acorn" }, function(npc, creature)
	return sendLocalized(Player(creature), "npc.a_fluffy_squirrel.acorn", "Chh? Chhh?? <though you don't understand squirrelish, that one seems really excited>")
end)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
