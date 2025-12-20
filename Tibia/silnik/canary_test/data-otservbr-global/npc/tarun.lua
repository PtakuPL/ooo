local internalNpcName = "Tarun"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 146,
	lookHead = 0,
	lookBody = 67,
	lookLegs = 0,
	lookFeet = 67,
	lookAddons = 2,
	lookMount = 0,
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
	if not player then
		return false
	end
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local theLostBrotherStorage = player:getStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest)
	if MsgContains(message, "mission") then
		if theLostBrotherStorage < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.multi_4")
			npcHandler:setTopic(playerId, 1)
		elseif theLostBrotherStorage == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif theLostBrotherStorage == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.multi_2")
			player:addItem(3039, 1)
			player:addExperience(3000, true)
			player:setStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.say_2")
			if theLostBrotherStorage < 1 then
				player:setStorageValue(Storage.Quest.U9_80.AdventurersGuild.QuestLine, 1)
			end
			player:setStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tarun.say_3")
		end
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

local function onTradeRequest(npc, creature)
	local player = Player(creature)
	if not player then
		return false
	end
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest) ~= 3 then
		return false
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.tarun.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.tarun.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.tarun.sendtrade_msg_1")
npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.tarun.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "colourful feather", clientId = 11514, sell = 110 },
	{ itemName = "empty potion flask", clientId = 283, sell = 5 },
	{ itemName = "empty potion flask", clientId = 284, sell = 5 },
	{ itemName = "empty potion flask", clientId = 285, sell = 5 },
	{ itemName = "golden lotus brooch", clientId = 21974, sell = 270 },
	{ itemName = "great health potion", clientId = 239, buy = 225 },
	{ itemName = "great mana potion", clientId = 238, buy = 158 },
	{ itemName = "great spirit potion", clientId = 7642, buy = 254 },
	{ itemName = "health potion", clientId = 266, buy = 50 },
	{ itemName = "hellspawn tail", clientId = 10304, sell = 475 },
	{ itemName = "mammoth tusk", clientId = 10321, sell = 100 },
	{ itemName = "mana potion", clientId = 268, buy = 56 },
	{ itemName = "orc tusk", clientId = 7786, sell = 700 },
	{ itemName = "peacock feather fan", clientId = 21975, sell = 350 },
	{ itemName = "sabretooth", clientId = 10311, sell = 400 },
	{ itemName = "spider silk", clientId = 5879, sell = 100 },
	{ itemName = "strong health potion", clientId = 236, buy = 115 },
	{ itemName = "strong mana potion", clientId = 237, buy = 108 },
	{ itemName = "supreme health potion", clientId = 23375, buy = 650 },
	{ itemName = "tusk", clientId = 3044, sell = 100 },
	{ itemName = "ultimate health potion", clientId = 7643, buy = 379 },
	{ itemName = "ultimate mana potion", clientId = 23373, buy = 488 },
	{ itemName = "ultimate spirit potion", clientId = 23374, buy = 488 },
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
