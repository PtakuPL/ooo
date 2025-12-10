local internalNpcName = "Melfar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 69,
}

npcConfig.flags = {
	floorchange = false,
}
npcConfig.shop = {
	{ itemName = "broken crossbow", clientId = 11451, sell = 30 },
	{ itemName = "flask with beaver bait", clientId = 9843, sell = 100 },
	{ itemName = "minotaur horn", clientId = 11472, sell = 75 },
	{ itemName = "piece of archer armor", clientId = 11483, sell = 20 },
	{ itemName = "piece of warrior armor", clientId = 11482, sell = 50 },
	{ itemName = "purple robe", clientId = 11473, sell = 110 },
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

local config = {
	{ position = Position(32474, 31947, 7), type = 2, description = "Tree 1" },
	{ position = Position(32515, 31927, 7), type = 2, description = "Tree 2" },
	{ position = Position(32458, 31997, 7), type = 2, description = "Tree 3" },
}

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(TheNewFrontier.Questline) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_9")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(TheNewFrontier.Mission02.Beaver1) == 1 and player:getStorageValue(TheNewFrontier.Mission02.Beaver2) == 1 and player:getStorageValue(TheNewFrontier.Mission02.Beaver3) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_1")
			player:setStorageValue(TheNewFrontier.Questline, 6)
			player:setStorageValue(TheNewFrontier.Mission02[1], 3) --Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_2")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.multi_3")
			player:setStorageValue(TheNewFrontier.Questline, 5)
			player:setStorageValue(TheNewFrontier.Mission02[1], 2) --Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
			player:addItem(9843, 1)
			for i = 1, #config do
				player:addMapMark(config[i].position, config[i].type, config[i].description)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeMoneyBank(100) then
				player:addItem(9843, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_3")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_4")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "buy flask") or MsgContains(message, "flask") then
		if player:getStorageValue(TheNewFrontier.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_5")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melfar.say_6")
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Just great, another disturbance. Just what I need.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
