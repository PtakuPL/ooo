local internalNpcName = "Hamish"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 133,
	lookHead = 19,
	lookBody = 95,
	lookLegs = 87,
	lookFeet = 128,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "That's the spirit!" },
	{ text = "Potions! Wands! Runes! Get them here!" },
	{ text = "You levelled up but your wand is old? Come and buy a new one here!" },
	{ text = "Ran out of mana or a little kablooie? Come to me to resupply!" },
	{ text = "Low on magic and need a little extra? Get yourself a rune!" },
	{ text = "Pack of monsters give you trouble? Throw an area rune at them!" },
	{ text = "Health potions to refill your health in combat!" },
	{ text = "Taking back empty potion flasks! Get your deposit back here!" },
	{ text = "Careful with that! That's a highly reactive potion you have there!" },
	{ text = "Mana potions to refill your magic power!" },
}

local itemsTable = {
	["potions"] = {
		{ itemName = "health potion", clientId = 266, buy = 50 },
		{ itemName = "mana potion", clientId = 268, buy = 56 },
		{ itemName = "small health potion", clientId = 7876, buy = 20 },
	},
	["runes"] = {
		{ itemName = "blank rune", clientId = 3147, buy = 10 },
		{ itemName = "cure poison rune", clientId = 3153, buy = 65 },
		{ itemName = "destroy field rune", clientId = 3148, buy = 15 },
		{ itemName = "energy field rune", clientId = 3164, buy = 38 },
		{ itemName = "fire field rune", clientId = 3188, buy = 28 },
		{ itemName = "intense healing rune", clientId = 3152, buy = 95 },
		{ itemName = "light stone shower rune", clientId = 21351, buy = 25 },
		{ itemName = "lightest missile rune", clientId = 21352, buy = 20 },
		{ itemName = "poison field rune", clientId = 3172, buy = 21 },
	},
	["wands"] = {
		{ itemName = "moonlight rod", clientId = 3070, buy = 1000 },
		{ itemName = "necrotic rod", clientId = 3069, buy = 5000 },
		{ itemName = "snakebite rod", clientId = 3066, buy = 500 },
		{ itemName = "wand of decay", clientId = 3072, buy = 5000 },
		{ itemName = "wand of dragonbreath", clientId = 3075, buy = 1000 },
		{ itemName = "wand of vortex", clientId = 3074, buy = 500 },
	},
}

npcConfig.shop = {}
for _, categoryTable in pairs(itemsTable) do
	for _, itemTable in ipairs(categoryTable) do
		table.insert(npcConfig.shop, itemTable)
	end
end

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

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_1",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_2",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_3",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_4",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_5",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_6",
})
keywordHandler:addKeyword({ "wentworth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_7",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_8",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_9",
})
keywordHandler:addKeyword({ "oressa" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_10",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hamish.stdmod_11",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local categoryTable = itemsTable[message:lower()]
	if MsgContains(message, "dawnport") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.hamish.say_1", "npc.hamish.say_2"}, 200)
	elseif MsgContains(message, "mainland") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.hamish.say_3", "npc.hamish.say_4"}, 200)
	elseif MsgContains(message, "ser tybald") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.hamish.say_5", "npc.hamish.say_6"}, 200)
	elseif categoryTable then
		local remainingCategories = npc:getRemainingShopCategories(message:lower(), itemsTable)
		npcHandler:say("Of course, just browse through my wares. You can also look at " .. remainingCategories .. ".", npc, player)
		npc:openShopWindowTable(player, categoryTable)
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(
	MESSAGE_GREET,
	"Hi there, fellow adventurer. \z
	What's your need? Say {trade} and we'll soon get you fixed up. Or ask me about {potions}, {wands}, or {runes}."
)

npcHandler:setMessage(MESSAGE_SENDTRADE, "Of course, just browse through my wares. Or do you want to look only at " .. GetFormattedShopCategoryNames(itemsTable) .. ".")
npcHandler:setMessage(MESSAGE_FAREWELL, "Use your runes wisely!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Use your runes wisely!")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Take your pick! Or maybe you want to look only at {potions}, {wands} or {runes}?")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

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
