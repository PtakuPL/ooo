local internalNpcName = "Frodo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 58,
	lookBody = 68,
	lookLegs = 109,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.frodo.voice_1" },
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

-- Basic
keywordHandler:addKeyword({ "hut" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_2" })
keywordHandler:addAliasKeyword({ "saloon" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_3" })
keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_4" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_5" })
keywordHandler:addAliasKeyword({ "tibianus" })
keywordHandler:addKeyword({ "general" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_6" })
keywordHandler:addKeyword({ "army" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_8" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_9" })
keywordHandler:addKeyword({ "dungeons" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_10" })
keywordHandler:addAliasKeyword({ "graveyard" })
keywordHandler:addKeyword({ "riddle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_11" })
keywordHandler:addKeyword({ "one eyed stranger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_12" })
keywordHandler:addKeyword({ "berfasmur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_13" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_14" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_15" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_16" })
keywordHandler:addKeyword({ "cropwell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_17" })
keywordHandler:addKeyword({ "royal archives" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_18" })
keywordHandler:addKeyword({ "rain castle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_19" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_20" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_21" })
keywordHandler:addKeyword({ "donald" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_22" })
keywordHandler:addKeyword({ "baxter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_23" })
keywordHandler:addKeyword({ "bozo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_24" })
keywordHandler:addKeyword({ "eclesius" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_25" })
keywordHandler:addKeyword({ "elane" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_26" })
keywordHandler:addKeyword({ "galuna" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_27" })
keywordHandler:addKeyword({ "gorn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_28" })
keywordHandler:addKeyword({ "gregor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_29" })
keywordHandler:addKeyword({ "harkath bloodblade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_30" })
keywordHandler:addKeyword({ "hugo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_31" })
keywordHandler:addKeyword({ "lugri" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_32" })
keywordHandler:addKeyword({ "lungelen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_33" })
keywordHandler:addKeyword({ "lynda" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_34" })
keywordHandler:addKeyword({ "marvik" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_35" })
keywordHandler:addKeyword({ "mcronald" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_36" })
keywordHandler:addAliasKeyword({ "sherry" })
keywordHandler:addKeyword({ "muriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_37" })
keywordHandler:addKeyword({ "oswald" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_38" })
keywordHandler:addKeyword({ "quentin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_39" })
keywordHandler:addKeyword({ "samuel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_40" })
keywordHandler:addKeyword({ "todd" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_41" })
keywordHandler:addKeyword({ "xodet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.frodo.stdmod_42" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.frodo.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.frodo.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.frodo.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bread", clientId = 3600, buy = 4 },
	{ itemName = "cheese", clientId = 3607, buy = 6 },
	{ itemName = "ham", clientId = 3582, buy = 8 },
	{ itemName = "meat", clientId = 3577, buy = 5 },
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
