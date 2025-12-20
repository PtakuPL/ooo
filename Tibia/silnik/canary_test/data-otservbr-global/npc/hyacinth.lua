local internalNpcName = "Hyacinth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 11,
	lookBody = 123,
	lookLegs = 123,
	lookFeet = 94,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.hyacinth.greet_msg_1")
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 3 or player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.hyacinth.greet_msg_2")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.hyacinth.greet_msg_3")
	end
	return true
end

-- The Rookie Guard Quest - Mission 04: Home-Brewed

-- Mission 4: Confirm (Give herbs)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_1",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 2 and player:getItemCount(12671) >= 1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, 3)
	player:removeItem(12671, 1)
end)
keywordHandler:addAliasKeyword({ "herbs" })

-- Mission 4: Decline (Give herbs)
local mission4LostHerbs = keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_2",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 2
end)

-- Mission 4: Confirm (Lost herbs)
mission4LostHerbs:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_3",
	reset = true,
})

-- Mission 4: Decline (Lost herbs)
mission4LostHerbs:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_4",
	ungreet = true,
})

-- Mission 4: Accept (First reward)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Here you go - two small health potions. If you use them on yourself, they will recover some of your hitpoints. ...",
		"I recommend setting them on a hotkey so you don't have to search for them in a case of emergency. ...",
		"Once you are a bit more experienced and have chosen a vocation, you'll have access to many different potions and also spells to restore your health. ...",
		"Oh, and I also have another present for you! Do you still have some space in your inventory?",
	},
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 3
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, 4)
	player:addItemEx(Game.createItem(7876, 2), true, CONST_SLOT_BACKPACK)
end)

-- Mission 4: Accept (Second reward)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Take this star ring. When you wear it in your ring slot, it will improve the effect of food that you have eaten for a limited time. So as long as you're not hungry, you will have increased hitpoint regeneration. ...",
		"It makes sense to undress it when you have full hitpoints, so that the effect of the ring won't be wasted. ...",
		"There are a lot of different rings in Tibia, but this one only works as long as you haven't learnt a vocation, so don't be afraid to use it. ...",
		"Anyway, thanks so much for your help. I can brew a lot of potions from these herbs. If you're in the area and find yourself in need of potions, don't hesitate to drop by and ask me for a {trade}. ...",
		"Anyway, this old man has taken enough of your time. Why don't you go back to the village and talk to Vascalir? If you stay on the path, you should be safe. Don't forget your potions!",
	},
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 4
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, 5)
	player:addItemEx(Game.createItem(12669, 1), true, CONST_SLOT_BACKPACK)
end)

-- Mission 4: Decline (First reward)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_5",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 3
end)

-- Mission 4: Decline (Second reward)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.hyacinth.stdmod_6",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 4
end)

-- Basic Keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_1" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_3" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_4" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_5" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_6" })
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_7" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_8" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_9" })
keywordHandler:addKeyword({ "spell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_10" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_11" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_12" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_13" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_14" })
keywordHandler:addKeyword({ "library" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_15" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_16" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_17" })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_18" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_19" })
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_20" })
keywordHandler:addKeyword({ "main" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_21" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_22" })
keywordHandler:addKeyword({ "blueberr" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_23" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_24" })

keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_25" })
keywordHandler:addAliasKeyword({ "stuff" })
keywordHandler:addAliasKeyword({ "wares" })
keywordHandler:addAliasKeyword({ "buy" })
keywordHandler:addAliasKeyword({ "sell" })

keywordHandler:addKeyword({ "equipment" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_26" })
keywordHandler:addAliasKeyword({ "rope" })
keywordHandler:addAliasKeyword({ "backpack" })
keywordHandler:addAliasKeyword({ "shovel" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addAliasKeyword({ "armor" })
keywordHandler:addAliasKeyword({ "helmet" })

keywordHandler:addKeyword({ "deposit" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_27" })
keywordHandler:addAliasKeyword({ "flask" })
keywordHandler:addAliasKeyword({ "vial" })

-- Names
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_28" })
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_29" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_30" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_31" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_32" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_33" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_34" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_35" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_36" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_37" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_38" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_39" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_40" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_41" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_42" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_43" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_44" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_45" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.hyacinth.stdmod_46" })
keywordHandler:addAliasKeyword({ "zerbrus" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.hyacinth.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.hyacinth.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.hyacinth.sendtrade_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "empty potion flask", clientId = 283, sell = 5 },
	{ itemName = "empty potion flask", clientId = 284, sell = 5 },
	{ itemName = "empty potion flask", clientId = 285, sell = 5 },
	{ itemName = "small health potion", clientId = 7876, buy = 20 },
	{ itemName = "vial", clientId = 2874, sell = 5 },
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
