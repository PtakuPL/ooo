local internalNpcName = "Bolfona"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 37,
	lookBody = 16,
	lookLegs = 54,
	lookFeet = 114,
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

	if MsgContains(message, "chocolate cake") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake) == 1 and player:getItemCount(8019) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(8019, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_3")
				npcHandler:setTopic(playerId, 2)
				player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.SweetAsChocolateCake, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_4")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "Frafnar") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_5")
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bolfona.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.bolfona.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.bolfona.farewell_msg_1")

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.bolfona.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bread", clientId = 3600, buy = 4 },
	{ itemName = "cheese", clientId = 3607, buy = 4 },
	{ itemName = "ham", clientId = 3582, buy = 8 },
	{ itemName = "meat", clientId = 3577, buy = 5 },
	{ itemName = "mug of beer", clientId = 2880, buy = 2, count = 3 },
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
