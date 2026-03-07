local internalNpcName = "Pemaret"
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
	lookHead = 79,
	lookBody = 10,
	lookLegs = 126,
	lookFeet = 126,
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

	if MsgContains(message, "marlin") then
		if player:getStorageValue(Storage.Quest.U7_8.MarlinTrophy) < 1 then
			if player:getItemCount(901) > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.pemaret.say_1")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U7_8.MarlinTrophy) < 1 then
		if player:removeItem(901, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.pemaret.say_2")
			player:addItem(902, 1)
			player:setStorageValue(Storage.Quest.U7_8.MarlinTrophy, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.pemaret.say_3")
		end
		npcHandler:setTopic(playerId, 0)
	end
	if MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.pemaret.say_4")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Travel
local function addTravelKeyword(keyword, text, cost, destination)
	local travelKeyword = keywordHandler:addKeyword({ keyword }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_1", i18nArgs = { keyword:titleCase() }, cost = cost, discount = "postman" })
	travelKeyword:addChildKeyword({ "yes" }, StdModule.travel, { npcHandler = npcHandler, premium = false, cost = cost, discount = "postman", destination = destination })
	travelKeyword:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_2", reset = true })
end

addTravelKeyword("edron", "Do you want to get to Edron for |TRAVELCOST|?", 20, Position(33176, 31764, 6))
addTravelKeyword("eremo", "Oh, you know the good old sage Eremo. I can bring you to his little island. Do you want me to do that?", 0, Position(33314, 31883, 7))

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(33293, 31957, 6), Position(33294, 31955, 6), Position(33294, 31958, 6) } })

-- Basic
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_3" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_4" })
keywordHandler:addKeyword({ "fish" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_5" })
keywordHandler:addKeyword({ "cormaya" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.pemaret.stdmod_7" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.pemaret.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.pemaret.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.pemaret.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "fish", clientId = 3578, buy = 5 },
	{ itemName = "green perch", clientId = 7159, sell = 100 },
	{ itemName = "marlin", clientId = 901, sell = 800 },
	{ itemName = "northern pike", clientId = 3580, sell = 100 },
	{ itemName = "rainbow trout", clientId = 7158, sell = 100 },
	{ itemName = "shimmer swimmer", clientId = 12557, sell = 3000 },
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
