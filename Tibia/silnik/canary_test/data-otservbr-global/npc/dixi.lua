local internalNpcName = "Dixi"
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
	lookBody = 99,
	lookLegs = 76,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.dixi.voice_1", yell = true },
	{ i18nKey = "npc.dixi.voice_2" },
	{ i18nKey = "npc.dixi.voice_3" },
	{ i18nKey = "npc.dixi.voice_4" },
	{ i18nKey = "npc.dixi.voice_5" },
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

-- Greeting and Farewell
keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, i18nKey = "npc.dixi.greet_1" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end)
keywordHandler:addAliasKeyword({ "hello" })
keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, i18nKey = "npc.dixi.greet_2" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end)
keywordHandler:addAliasKeyword({ "hello" })
keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, i18nKey = "npc.dixi.farewell_1" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end)
keywordHandler:addAliasKeyword({ "farewell" })
keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, i18nKey = "npc.dixi.farewell_2" })
keywordHandler:addAliasKeyword({ "farewell" })

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_1" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_4" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_5" })
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_6" })
keywordHandler:addKeyword({ "profession" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_7" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_8" })
keywordHandler:addKeyword({ "equipment" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_9" })
keywordHandler:addKeyword({ "torch" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_10" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_11" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_12" })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_13" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_14" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_15" })
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_16" })
keywordHandler:addKeyword({ "mainland" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_17" })
keywordHandler:addKeyword({ "buy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_18" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_19" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_20" })
keywordHandler:addKeyword({ "blueberr" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_21" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_22" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_23" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_24" })

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_25" })
keywordHandler:addAliasKeyword({ "information" })

keywordHandler:addKeyword({ "money" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_26" })
keywordHandler:addAliasKeyword({ "gold" })

keywordHandler:addKeyword({ "backpack" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_27" })
keywordHandler:addAliasKeyword({ "rope" })
keywordHandler:addAliasKeyword({ "shovel" })
keywordHandler:addAliasKeyword({ "fishing" })

keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_28" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addAliasKeyword({ "helmet" })

keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_29" })
keywordHandler:addAliasKeyword({ "stuff" })
keywordHandler:addAliasKeyword({ "wares" })

-- Names
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_30" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_31" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_32" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_33" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_34" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_35" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_36" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_37" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_38" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_39" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_40" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_41" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_42" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_43" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_44" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_45" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_46" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dixi.stdmod_47" })
keywordHandler:addAliasKeyword({ "zerbrus" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dixi.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.dixi.sendtrade_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "brass helmet", clientId = 3354, sell = 22 },
	{ itemName = "brass shield", clientId = 3411, sell = 25 },
	{ itemName = "chain armor", clientId = 3358, sell = 40 },
	{ itemName = "chain helmet", clientId = 3352, buy = 52, sell = 12 },
	{ itemName = "coat", clientId = 3562, buy = 8 },
	{ itemName = "copper shield", clientId = 3430, sell = 50 },
	{ itemName = "doublet", clientId = 3379, buy = 16, sell = 3 },
	{ itemName = "jacket", clientId = 3561, buy = 10 },
	{ itemName = "leather armor", clientId = 3361, buy = 25, sell = 5 },
	{ itemName = "leather boots", clientId = 3552, sell = 2 },
	{ itemName = "leather helmet", clientId = 3355, buy = 12, sell = 3 },
	{ itemName = "leather legs", clientId = 3559, buy = 10, sell = 2 },
	{ itemName = "legion helmet", clientId = 3374, sell = 22 },
	{ itemName = "plate shield", clientId = 3410, sell = 40 },
	{ itemName = "studded armor", clientId = 3378, sell = 10 },
	{ itemName = "studded helmet", clientId = 3376, buy = 63, sell = 20 },
	{ itemName = "studded legs", clientId = 3362, sell = 15 },
	{ itemName = "studded shield", clientId = 3426, buy = 50, sell = 16 },
	{ itemName = "viking helmet", clientId = 3367, sell = 25 },
	{ itemName = "wooden shield", clientId = 3412, buy = 15 },
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
