local internalNpcName = "Tamoril"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 39,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
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

local function isDateWithinEvent()
	local currentDate = os.date("*t")
	local startDate = { day = 14, month = 1 }
	local endDate = { day = 12, month = 2 }

	if (currentDate.month == startDate.month and currentDate.day >= startDate.day) or (currentDate.month == endDate.month and currentDate.day <= endDate.day) or (currentDate.month > startDate.month and currentDate.month < endDate.month) then
		return true
	end
	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not isDateWithinEvent() then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You can only discuss the First Dragon between January 14 and February 12.")
		return true
	end

	if MsgContains(message, "first dragon") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "rumours") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:setTopic(playerId, 2)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.say_2")
	elseif MsgContains(message, "descendants") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:setTopic(playerId, 3)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.say_3")
	elseif MsgContains(message, "draconic incitements") and npcHandler:getTopic(playerId) == 3 then
		npcHandler:setTopic(playerId, 4)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_10")
	elseif MsgContains(message, "find") then
		npcHandler:setTopic(playerId, 5)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.say_4")
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 then
		npcHandler:setTopic(playerId, 6)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_7")
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tamoril.multi_3")
		npcHandler:setTopic(playerId, 0)
		if player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.Questline, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.ChestCounter) < 0 then
			player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.ChestCounter, 0)
		end
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.DragonCounter, 0)
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.GelidrazahAccess, 0)
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.SecretsCounter, 0)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.tamoril.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "blue gem", clientId = 3041, sell = 5000 },
	{ itemName = "golden mug", clientId = 2903, sell = 250 },
	{ itemName = "green gem", clientId = 3038, sell = 5000 },
	{ itemName = "red gem", clientId = 3039, sell = 1000 },
	{ itemName = "violet gem", clientId = 3036, sell = 10000 },
	{ itemName = "white gem", clientId = 32769, sell = 12000 },
	{ itemName = "yellow gem", clientId = 3037, sell = 1000 },
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
