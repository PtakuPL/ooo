local internalNpcName = "Penny"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 137,
	lookHead = 58,
	lookBody = 116,
	lookLegs = 117,
	lookFeet = 59,
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
	npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.penny.greet_msg_1", {
		args = function(player)
			return {
				player:getSex() == PLAYERSEX_FEMALE and "Lady" or "Sir",
				player:getName(),
			}
		end,
	})
	return true
end

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_1" })
keywordHandler:addKeyword({ "penny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_3" })
keywordHandler:addKeyword({ "criminal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_4" })
keywordHandler:addKeyword({ "record" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_5" })
keywordHandler:addKeyword({ "paper" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_6" })
keywordHandler:addKeyword({ "mail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_7" })
keywordHandler:addKeyword({ "?" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.penny.stdmod_8" })

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.penny.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.penny.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "cake", clientId = 6277, buy = 1 },
	{ itemName = "letter", clientId = 3505, buy = 1 },
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
