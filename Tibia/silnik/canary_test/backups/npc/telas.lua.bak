local internalNpcName = "Telas"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 133,
	lookHead = 39,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 76,
	lookAddons = 1,
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "farmine") and player:getStorageValue(TheNewFrontier.Questline) == 14 then
		if player:getStorageValue(TheNewFrontier.Mission05.Telas) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "reason") or MsgContains(message, "flatter") and player:getStorageValue(TheNewFrontier.Mission05.TelasKeyword) <= 2 and player:getStorageValue(TheNewFrontier.Mission05.Telas) == 1 then
		if npcHandler:getTopic(playerId) == 1 then
			if MsgContains(message, "reason") and player:getStorageValue(TheNewFrontier.Mission05.TelasKeyword) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_3")
				player:setStorageValue(TheNewFrontier.Mission05.Telas, 3)
			elseif MsgContains(message, "flatter") and player:getStorageValue(TheNewFrontier.Mission05.TelasKeyword) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_4")
				player:setStorageValue(TheNewFrontier.Mission05.Telas, 3)
			end
			player:setStorageValue(TheNewFrontier.Mission05.TelasKeyword, 3)
		end
	elseif MsgContains(message, "plea") and player:getStorageValue(TheNewFrontier.Mission05.TelasKeyword) == 3 and player:getStorageValue(TheNewFrontier.Mission05.Telas) == 1 then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_5")
			player:setStorageValue(TheNewFrontier.Mission05.Telas, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(TheNewFrontier.Mission05.Telas) == 2 and player:removeItem(10027, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_6")
				player:setStorageValue(TheNewFrontier.Mission05.Telas, 1)
				npcHandler:setTopic(playerId, 1)
			end
		end
	else
		if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Telas) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.telas.say_7")
			player:setStorageValue(TheNewFrontier.Mission05.Telas, 2)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.telas.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "ancient stone", clientId = 9632, sell = 200 },
	{ itemName = "battle stone", clientId = 11447, sell = 290 },
	{ itemName = "broken gladiator shield", clientId = 9656, sell = 190 },
	{ itemName = "coal", clientId = 12600, sell = 20 },
	{ itemName = "crystal of balance", clientId = 9028, sell = 1000 },
	{ itemName = "crystal of focus", clientId = 9027, sell = 2000 },
	{ itemName = "crystal of power", clientId = 9067, sell = 3000 },
	{ itemName = "crystal pedestal", clientId = 9063, sell = 500 },
	{ itemName = "crystalline spikes", clientId = 16138, sell = 440 },
	{ itemName = "flintstone", clientId = 12806, sell = 800 },
	{ itemName = "gear crystal", clientId = 9655, sell = 200 },
	{ itemName = "gear wheel", clientId = 8775, sell = 500 },
	{ itemName = "huge chunk of crude iron", clientId = 5892, sell = 15000 },
	{ itemName = "magma clump", clientId = 16130, sell = 570 },
	{ itemName = "metal spike", clientId = 10298, sell = 320 },
	{ itemName = "piece of draconian steel", clientId = 5889, sell = 3000 },
	{ itemName = "piece of hell steel", clientId = 5888, sell = 500 },
	{ itemName = "piece of hellfire armor", clientId = 9664, sell = 550 },
	{ itemName = "piece of royal steel", clientId = 5887, sell = 10000 },
	{ itemName = "pulverized ore", clientId = 16133, sell = 400 },
	{ itemName = "shiny stone", clientId = 10310, sell = 500 },
	{ itemName = "stone nose", clientId = 16137, sell = 590 },
	{ itemName = "sulphurous stone", clientId = 10315, sell = 100 },
	{ itemName = "vein of ore", clientId = 16135, sell = 330 },
	{ itemName = "war crystal", clientId = 9654, sell = 460 },
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
