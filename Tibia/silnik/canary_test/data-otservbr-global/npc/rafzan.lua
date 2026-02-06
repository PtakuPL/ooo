local internalNpcName = "Rafzan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 540,
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

keywordHandler:addKeyword({ "task" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_1" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_2" })
keywordHandler:addKeyword({ "goblin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_3" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_4" })
keywordHandler:addKeyword({ "profit" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_5" })
keywordHandler:addKeyword({ "swamp" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_6" })
keywordHandler:addKeyword({ "dwarf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_7" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_8" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_9" })
keywordHandler:addKeyword({ "elves" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_10" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_11" })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_12" })
keywordHandler:addKeyword({ "gold" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.rafzan.stdmod_13",
})
keywordHandler:addKeyword(
	{ "ratmen" },
	StdModule.say,
	{ npcHandler = npcHandler, i18nKey = "npc.rafzan.stdmod_14" }
)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "advertisement sign", clientId = 17668, buy = 75 },
	{ itemName = "backpack", clientId = 2854, buy = 10 },
	{ itemName = "bag", clientId = 2853, buy = 4 },
	{ itemName = "bottle with rat urine", clientId = 17671, buy = 150 },
	{ itemName = "fishing rod", clientId = 3483, buy = 150, sell = 30 },
	{ itemName = "guardcatcher", clientId = 17669, buy = 200 },
	{ itemName = "leather harness", clientId = 17846, sell = 750 },
	{ itemName = "life preserver", clientId = 17813, sell = 300 },
	{ itemName = "perfume gatherer", clientId = 17670, buy = 400 },
	{ itemName = "ratana", clientId = 17812, sell = 500 },
	{ itemName = "rope", clientId = 3003, buy = 50, sell = 8 },
	{ itemName = "scroll", clientId = 2815, buy = 5 },
	{ itemName = "scythe", clientId = 3453, buy = 12 },
	{ itemName = "shovel", clientId = 3457, buy = 10, sell = 2 },
	{ itemName = "spike shield", clientId = 17810, sell = 250 },
	{ itemName = "spiky club", clientId = 17859, sell = 300 },
	{ itemName = "torch", clientId = 2920, buy = 2 },
	{ itemName = "trunkhammer", clientId = 17676, buy = 150 },
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

npcType:register(npcConfig)
