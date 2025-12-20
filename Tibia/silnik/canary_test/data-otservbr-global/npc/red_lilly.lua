local internalNpcName = "Red Lilly"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 96,
	lookBody = 57,
	lookLegs = 28,
	lookFeet = 47,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.red_lilly.voice_1" },
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

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "basket", clientId = 2855, buy = 6 },
	{ itemName = "beach backpack", clientId = 5949, buy = 20 },
	{ itemName = "beach bag", clientId = 5950, buy = 4 },
	{ itemName = "bottle", clientId = 2875, buy = 3 },
	{ itemName = "bucket", clientId = 2873, buy = 4 },
	{ itemName = "candelabrum", clientId = 2912, buy = 8 },
	{ itemName = "candlestick", clientId = 2917, buy = 2 },
	{ itemName = "closed trap", clientId = 3481, buy = 280, sell = 75 },
	{ itemName = "crowbar", clientId = 3304, buy = 260, sell = 50 },
	{ itemName = "crusher", clientId = 46627, buy = 500 },
	{ itemName = "cup", clientId = 2881, buy = 2 },
	{ itemName = "document", clientId = 2818, buy = 12 },
	{ itemName = "fishing rod", clientId = 3483, buy = 150, sell = 40 },
	{ itemName = "hand auger", clientId = 31334, buy = 25 },
	{ itemName = "machete", clientId = 3308, buy = 35, sell = 6 },
	{ itemName = "net", clientId = 31489, buy = 50 },
	{ itemName = "parchment", clientId = 2817, buy = 8 },
	{ itemName = "pick", clientId = 3456, buy = 50, sell = 15 },
	{ itemName = "plate", clientId = 2905, buy = 6 },
	{ itemName = "present", clientId = 2856, buy = 10 },
	{ itemName = "rope", clientId = 3003, buy = 50, sell = 15 },
	{ itemName = "scroll", clientId = 2815, buy = 5 },
	{ itemName = "scythe", clientId = 3453, buy = 50, sell = 10 },
	{ itemName = "shovel", clientId = 3457, buy = 50, sell = 8 },
	{ itemName = "torch", clientId = 2920, buy = 2 },
	{ itemName = "vial", clientId = 2874, sell = 5 },
	{ itemName = "vial of oil", clientId = 2874, buy = 20, count = 7 },
	{ itemName = "vial of water", clientId = 2874, buy = 20, count = 1 },
	{ itemName = "watch", clientId = 2906, buy = 20, sell = 6 },
	{ itemName = "waterskin of water", clientId = 2901, buy = 10, count = 1 },
	{ itemName = "wooden hammer", clientId = 3459, sell = 15 },
	{ itemName = "worm", clientId = 3492, buy = 1 },
}
-- Basic
keywordHandler:addKeyword({ "charlotta" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_1" })
keywordHandler:addKeyword({ "cult" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_2" })
keywordHandler:addKeyword({ "djinn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_3" })
keywordHandler:addKeyword({ "eleonore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_4" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_5" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_6" })
keywordHandler:addKeyword({ "governor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_7" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_8" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_9" })
keywordHandler:addKeyword({ "liberty bay" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_10" })
keywordHandler:addKeyword({ "light" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_11" })

keywordHandler:addKeyword({ "loveless" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_12" })
keywordHandler:addAliasKeyword({ "theodore" })

keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_13" })
keywordHandler:addAliasKeyword({ "buy" })
keywordHandler:addAliasKeyword({ "goods" })
keywordHandler:addAliasKeyword({ "sell" })
keywordHandler:addAliasKeyword({ "equipment" })
keywordHandler:addAliasKeyword({ "stuff" })
keywordHandler:addAliasKeyword({ "ware" })

keywordHandler:addKeyword({ "pirate" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_14" })
keywordHandler:addKeyword({ "plantations" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_15" })
keywordHandler:addKeyword({ "quara" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The quara are the curse of the sea. Everybody that dares to enrage the sea spirits has to fear their vengeance. They come at night to kidnap people who forgot their lucky charms at home ...",
		"Sometimes those evil beings take the most naughty children to raise them as their own underwater.",
	},
})
keywordHandler:addKeyword({ "rum" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_16" })
keywordHandler:addKeyword({ "striker" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_17" })
keywordHandler:addKeyword({ "sugar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_18" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_19" })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_20" })
keywordHandler:addKeyword({ "voodoo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_21" })
keywordHandler:addKeyword({ "wyrmslicer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_22" })
-- keywordHandler:addKeyword({'vial'}, StdModule.say, {npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_23"})
-- keywordHandler:addKeyword({'no'}, StdModule.say, {npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_24"})
-- keywordHandler:addKeyword({'yes'}, StdModule.say, {npcHandler = npcHandler, i18nKey = "npc.red_lilly.stdmod_25"})
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.red_lilly.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.red_lilly.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.red_lilly.sendtrade_msg_1")
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
