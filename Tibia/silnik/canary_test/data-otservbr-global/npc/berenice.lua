local internalNpcName = "Berenice"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 5,
	lookBody = 87,
	lookLegs = 104,
	lookFeet = 106,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaQuest) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_1")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) > 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 44 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_2")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "calassa") then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaQuest) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_3")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_4")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaQuest) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_5")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.multi_8")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_6")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaQuest, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaDoor, 1)
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(21378, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.CalassaQuest, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.berenice.say_7")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "atlas", clientId = 6108, buy = 150 },
	{ itemName = "first verse of the hymn", clientId = 6087, sell = 100 },
	{ itemName = "fourth verse of the hymn", clientId = 6090, sell = 800 },
	{ itemName = "orichalcum pearl", clientId = 5021, buy = 80 },
	{ itemName = "second verse of the hymn", clientId = 6088, sell = 250 },
	{ itemName = "third verse of the hymn", clientId = 6089, sell = 400 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
