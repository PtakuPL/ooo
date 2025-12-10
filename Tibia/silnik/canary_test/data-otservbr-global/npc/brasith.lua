local internalNpcName = "Brasith"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 159,
	lookHead = 41,
	lookBody = 94,
	lookLegs = 97,
	lookFeet = 76,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_1" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_2" })
keywordHandler:addKeyword({ "teshial" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_3" })
keywordHandler:addKeyword({ "kuridai" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_4" })
keywordHandler:addKeyword({ "deraisim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_5" })
keywordHandler:addKeyword({ "cenath" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_6" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_7" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_8" })
keywordHandler:addKeyword({ "plants" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_9" })
keywordHandler:addKeyword({ "tree" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.brasith.stdmod_10" })

npcHandler:setMessage(MESSAGE_GREET, "Ashari, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Asha Thrazi.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Asha Thrazi.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "banana", clientId = 3587, buy = 2 },
	{ itemName = "bottle of bug milk", clientId = 8758, buy = 200 },
	{ itemName = "bottle of milk", clientId = 2875, buy = 15, count = 9 },
	{ itemName = "broccoli", clientId = 11461, buy = 3 },
	{ itemName = "bulb of garlic", clientId = 8197, buy = 4 },
	{ itemName = "carrot", clientId = 3595, buy = 3 },
	{ itemName = "cauliflower", clientId = 11462, buy = 4 },
	{ itemName = "cherry", clientId = 3590, buy = 1 },
	{ itemName = "corncob", clientId = 3597, buy = 3 },
	{ itemName = "grapes", clientId = 3592, buy = 3 },
	{ itemName = "juice squeezer", clientId = 5865, buy = 100 },
	{ itemName = "melon", clientId = 3593, buy = 8 },
	{ itemName = "potato", clientId = 8010, buy = 4 },
	{ itemName = "pumpkin", clientId = 3594, buy = 10 },
	{ itemName = "strawberry", clientId = 3591, buy = 1 },
	{ itemName = "vial of milk", clientId = 2874, buy = 15, count = 1, subType = 9 },
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
