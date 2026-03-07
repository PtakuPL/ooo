local internalNpcName = "Al Dee"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 97,
	lookBody = 77,
	lookLegs = 87,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.al_dee.voice_1" },
	{ i18nKey = "npc.al_dee.voice_2" },
	{ i18nKey = "npc.al_dee.voice_3" },
	{ i18nKey = "npc.al_dee.voice_4" },
}
npcConfig.shop = { -- Sellable items
	{ itemName = "backpack", clientId = 2854, buy = 10 },
	{ itemName = "bag", clientId = 2853, buy = 4 },
	{ itemName = "fishing rod", clientId = 3483, buy = 150, sell = 30 },
	{ itemName = "rope", clientId = 3003, buy = 50, sell = 8 },
	{ itemName = "scroll", clientId = 2815, buy = 5 },
	{ itemName = "scythe", clientId = 3453, buy = 12 },
	{ itemName = "shovel", clientId = 3457, buy = 10, sell = 2 },
	{ itemName = "torch", clientId = 2920, buy = 2 },
	{ itemName = "worm", clientId = 3492, buy = 1 },
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

-- Basic Keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_1" })
keywordHandler:addKeyword({ "stuff" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_2" })
keywordHandler:addAliasKeyword({ "wares" })
keywordHandler:addAliasKeyword({ "offer" })
keywordHandler:addAliasKeyword({ "buy" })

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_3" })
keywordHandler:addAliasKeyword({ "information" })

keywordHandler:addKeyword({ "equip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_4" })
keywordHandler:addAliasKeyword({ "tools" })

keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_5" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_7" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_8" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_9" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_10" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_11" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_12" })
keywordHandler:addKeyword({ "bug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_13" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_14" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_15" })
keywordHandler:addKeyword({ "mainland" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_16" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_17" })
keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_18" })
keywordHandler:addKeyword({ "shield" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_19" })
keywordHandler:addKeyword({ "cooki" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_20" })
keywordHandler:addKeyword({ "blueberr" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_21" })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_22" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_23" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_24" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_25" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_26" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_27" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_28" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_29" })
keywordHandler:addKeyword({ "profession" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_30" })
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_31" })

keywordHandler:addKeyword({ "torch" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_32" })
keywordHandler:addKeyword({ "fishing" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_33" })
keywordHandler:addKeyword({ "shovel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_34" })
keywordHandler:addAliasKeyword({ "rope" })
keywordHandler:addAliasKeyword({ "backpack" })

-- Names
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_35" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_36" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_37" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_38" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_39" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_40" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_41" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_42" })
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_43" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_44" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_45" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_46" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_47" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_48" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_49" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_50" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_51" })
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_52" })
keywordHandler:addKeyword({ "zerbrus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_53" })
keywordHandler:addAliasKeyword({ "dallheim" })

-- Pick quest
local pickKeyword = keywordHandler:addKeyword({ "pick" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_54" })
pickKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_55", reset = true }, function(player)
	return player:getItemCount(3462) > 0
end, function(player)
	player:removeItem(3462, 1)
	player:addItem(3456, 1)
end)
pickKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_56", reset = true })
pickKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.al_dee.stdmod_57", reset = true })
keywordHandler:addAliasKeyword({ "small", "axe" })

local function greetCallback(npc, creature)
	NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
		"npc.al_dee.greet_msg_1",
		"npc.al_dee.greet_msg_2",
	}, 1000)
	return false
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.al_dee.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.al_dee.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.al_dee.sendtrade_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
