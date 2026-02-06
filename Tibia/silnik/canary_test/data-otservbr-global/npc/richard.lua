local internalNpcName = "Richard"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 472,
	lookHead = 97,
	lookBody = 38,
	lookLegs = 41,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}
local itemsTable = {
	["containers"] = {
		{ itemName = "backpack", clientId = 2854, buy = 10, count = 1 },
		{ itemName = "bag", clientId = 2853, buy = 4, count = 1 },
	},
	["food"] = {
		{ itemName = "bread", clientId = 3600, buy = 3, count = 1 },
		{ itemName = "carrot", clientId = 3595, buy = 1, count = 1 },
		{ itemName = "cheese", clientId = 3607, sell = 2, count = 1 },
		{ itemName = "cherry", clientId = 3590, buy = 1, count = 1 },
		{ itemName = "egg", clientId = 3606, buy = 1, count = 1 },
		{ itemName = "ham", clientId = 3582, buy = 8, count = 1 },
		{ itemName = "meat", clientId = 3577, sell = 2, count = 1 },
		{ itemName = "salmon", clientId = 3579, buy = 2, count = 1 },
	},
	["equipment"] = {
		{ itemName = "fishing rod", clientId = 3483, sell = 30, count = 1 },
		{ itemName = "machete", clientId = 3308, buy = 6, count = 1 },
		{ itemName = "pick", clientId = 3456, buy = 15, count = 1 },
		{ itemName = "rope", clientId = 3003, sell = 8, count = 1 },
		{ itemName = "shovel", clientId = 3457, sell = 2, count = 1 },
		{ itemName = "torch", clientId = 2920, buy = 2, count = 1 },
	},
	["others"] = {
		{ itemName = "scroll", clientId = 2815, buy = 5, count = 1 },
		{ itemName = "worm", clientId = 3492, buy = 1, count = 1 },
	},
}

npcConfig.shop = {}
for _, category in pairs(itemsTable) do
	for _, item in ipairs(category) do
		table.insert(npcConfig.shop, item)
	end
end

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

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.richard.voice_1" },
	{ i18nKey = "npc.richard.voice_2" },
	{ i18nKey = "npc.richard.voice_3" },
	{ i18nKey = "npc.richard.voice_4" },
	{ i18nKey = "npc.richard.voice_5" },
	{
		i18nKey = "npc.richard.voice_6",
	},
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

	local categoryTable = itemsTable[message:lower()]
	if MsgContains(message, "job") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.richard.say_1", "npc.richard.say_2"}, 10)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "rope") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.richard.say_3", "npc.richard.say_4"}, 10)
		npcHandler:setTopic(playerId, 0)
	elseif categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(message:lower(), itemsTable)
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.richard.say_1", { remainingCategories })
		npc:openShopWindowTable(player, categoryTable)
	end
	return true
end

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_1",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_2",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_3",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_4",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_5",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_6",
})
keywordHandler:addKeyword({ "squirrel" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_7",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_8",
})
keywordHandler:addKeyword({ "oressa" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_9",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_10",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.richard.stdmod_11",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.richard.greet_msg_1")
npcHandler:setLocalizedMessage(MESSAGE_SENDTRADE, "npclib.handler.sendtrade_with_categories", { args = function(_player) return { GetFormattedShopCategoryNames(itemsTable) } end })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.richard.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
