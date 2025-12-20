local internalNpcName = "Xelvar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 70,
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

	if not player then
		return false
	end

	if MsgContains(message, "adventures") or MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_16")

			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 1)
			player:addItem(16167, 4)

			--NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_2")
		end
	elseif MsgContains(message, "recruiting") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_3")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "partners") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_4")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "gnomes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_10")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "help") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_8")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "join") then
		if npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.multi_6")

			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 1)
			player:addItem(16167, 4)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.xelvar.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "teleport crystal", clientId = 16167, buy = 150 },
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
