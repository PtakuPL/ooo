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
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.xelvar.say_5", "npc.xelvar.say_6", "npc.xelvar.say_7", "npc.xelvar.say_8", "npc.xelvar.say_9", "npc.xelvar.say_10" })

			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 1)
			player:addItem(16167, 4)

			--npcHandler:say("Right now I am sort of {recruiting} people.", npc, creature)
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_11")
		end
	elseif MsgContains(message, "recruiting") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_12")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "partners") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.xelvar.say_13")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "gnomes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.xelvar.say_14", "npc.xelvar.say_15" })
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "help") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.xelvar.say_16", "npc.xelvar.say_17" })
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "join") then
		if npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.xelvar.say_18", "npc.xelvar.say_19", "npc.xelvar.say_20", "npc.xelvar.say_21", "npc.xelvar.say_22", "npc.xelvar.say_23" })

			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 1)
			player:addItem(16167, 4)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings. Are you interested in adventures?")

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
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
