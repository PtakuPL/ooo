local internalNpcName = "Anerui"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 63,
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

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_1" })
keywordHandler:addKeyword({ "hunt" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_2" })
keywordHandler:addKeyword({ "bow" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_3" })
keywordHandler:addKeyword({ "hunter" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_4" })
keywordHandler:addKeyword({ "nature" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_5" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_6" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_7" })
keywordHandler:addKeyword({ "teshial" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_8" })
keywordHandler:addKeyword({ "kuridai" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_9" })
keywordHandler:addKeyword({ "balance" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_10" })
keywordHandler:addKeyword({ "deraisim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_11" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_12" })
keywordHandler:addKeyword({ "death" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_13" })
keywordHandler:addKeyword({ "life" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_14" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_15" })
keywordHandler:addKeyword({ "elf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_16" })
keywordHandler:addKeyword({ "cenath" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.anerui.stdmod_17" })

-- Greeting message
keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, text = "Ashari, |PLAYERNAME|.", i18nKey = "npc.anerui.greet_1" })
-- Farewell message
keywordHandler:addFarewellKeyword({ "asgha thrazi" }, { npcHandler = npcHandler, text = "Asha Thrazi.", i18nKey = "npc.anerui.farewell_1" })

npcHandler:setMessage(MESSAGE_GREET, "Ashari |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Asha Thrazi.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Asha Thrazi.")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcConfig.shop = {
	{ itemName = "ham", clientId = 3582, buy = 6 },
	{ itemName = "meat", clientId = 3577, buy = 4 },
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
