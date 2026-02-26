local internalNpcName = "Obi"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 19,
	lookBody = 63,
	lookLegs = 96,
	lookFeet = 38,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.obi.voice_1" },
	{ i18nKey = "npc.obi.voice_2" },
	{ i18nKey = "npc.obi.voice_3" },
	{ i18nKey = "npc.obi.voice_4" },
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

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_1" })
keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_2" })
keywordHandler:addKeyword({ "torch" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_3" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_4" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_5" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_7" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_8" })
keywordHandler:addKeyword({ "equipment" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_9" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_10" })
keywordHandler:addKeyword({ "mainland" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_11" })
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_12" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_13" })
keywordHandler:addKeyword({ "sam" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_14" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_15" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_16" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_17" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_18" })
keywordHandler:addKeyword({ "guard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_19" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_20" })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_21" })
keywordHandler:addKeyword({ "blueberr" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_22" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_23" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_24" })

keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_25" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addAliasKeyword({ "helmet" })

keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_26" })

keywordHandler:addKeyword({ "gold" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_27" })
keywordHandler:addAliasKeyword({ "money" })

keywordHandler:addKeyword({ "rope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_28" })
keywordHandler:addAliasKeyword({ "shovel" })
keywordHandler:addAliasKeyword({ "backpack" })
keywordHandler:addAliasKeyword({ "fishing" })

keywordHandler:addKeyword({ "buy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_29" })
keywordHandler:addAliasKeyword({ "stuff" })
keywordHandler:addAliasKeyword({ "wares" })
keywordHandler:addAliasKeyword({ "offer" })

-- Names
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_30" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_31" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_32" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_33" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_34" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_35" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_36" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_37" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_38" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_39" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_40" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_41" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_42" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_43" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_44" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_45" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_46" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.obi.stdmod_47" })
keywordHandler:addAliasKeyword({ "zerbrus" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.obi.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.obi.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.obi.sendtrade_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.obi.greet_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "axe", clientId = 3274, buy = 20, sell = 7 },
	{ itemName = "bone club", clientId = 3337, sell = 5 },
	{ itemName = "dagger", clientId = 3267, buy = 5, sell = 2 },
	{ itemName = "hand axe", clientId = 3268, buy = 8, sell = 4 },
	{ itemName = "hatchet", clientId = 3276, sell = 25 },
	{ itemName = "katana", clientId = 3300, sell = 35 },
	{ itemName = "mace", clientId = 3286, sell = 30 },
	{ itemName = "machete", clientId = 3308, sell = 6 },
	{ itemName = "rapier", clientId = 3272, buy = 15, sell = 5 },
	{ itemName = "sabre", clientId = 3273, buy = 25, sell = 12 },
	{ itemName = "scythe", clientId = 3453, buy = 12, sell = 3 },
	{ itemName = "short sword", clientId = 3294, buy = 30, sell = 10 },
	{ itemName = "sickle", clientId = 3293, buy = 8, sell = 2 },
	{ itemName = "spear", clientId = 3277, buy = 10, sell = 3 },
	{ itemName = "sword", clientId = 3264, sell = 25 },
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
