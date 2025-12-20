local internalNpcName = "Todd"
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
	lookHead = 115,
	lookBody = 0,
	lookLegs = 67,
	lookFeet = 114,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "interesting") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.todd.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.todd.multi_2")
	end
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_1" })
keywordHandler:addKeyword({ "want" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_2" })
keywordHandler:addKeyword({ "head" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_3" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_4" })
keywordHandler:addKeyword({ "hugo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_5" })
keywordHandler:addKeyword({ "todd" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_6" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_7" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_8" })
keywordHandler:addKeyword({ "resistance" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_9" })
keywordHandler:addKeyword({ "money" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_10" })
keywordHandler:addKeyword({ "eclesius" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_11" })
keywordHandler:addKeyword({ "karl" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_12" })
keywordHandler:addKeyword({ "william" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.todd.stdmod_13" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.todd.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.todd.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.todd.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "scroll of heroic deeds", clientId = 11510, sell = 230 },
	{ itemName = "small notebook", clientId = 11450, sell = 480 },
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
