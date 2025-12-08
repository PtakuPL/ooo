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
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
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
			npcHandler:say({
				"Ha! Men and wood you say? Well, I might be able to relocate some of our miners to the base. Acquiring wood is an entirely different matter though. ... ",
				"I can't spare any men for woodcutting right now but I have an unusual idea that might help. ... ",
				"As you might know, this area is troubled by giant beavers. Once a year, the miners decide to have some fun, so they lure the beavers and jump on them to have some sort of rodeo. ... ",
				"However, I happen to have some beaver bait left from the last year's competition. ... ",
				"If you place it on trees on some strategic locations, we could let the beavers do the work and later on, I'll send men to get the fallen trees. ... ",
				"Does this sound like something you can handle? ",
			}, npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(TheNewFrontier.Mission02.Beaver1) == 1 and player:getStorageValue(TheNewFrontier.Mission02.Beaver2) == 1 and player:getStorageValue(TheNewFrontier.Mission02.Beaver3) == 1 then
			npcHandler:sayLocalized("npc.melfar.yes_i_can_1", npc, creature)
			player:setStorageValue(TheNewFrontier.Questline, 6)
			player:setStorageValue(TheNewFrontier.Mission02[1], 3) --Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
		else
			npcHandler:sayLocalized("npc.melfar.if_you_place_2", npc, creature)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say({
				"So take this beaver bait. It will work best on dwarf trees. I'll mark the three trees on your map. Here .. here .. and here! So now mark those trees with the beaver bait. ...",
				"If you're unlucky enough to meet one of the giant beavers, try to stay calm. Don't do any hectic moves, don't yell, don't draw any weapon, and if you should carry anything wooden on you, throw it away as far as you can.",
				"Just great, another disturbance. Just what I need.",
			}, npc, creature)
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
				npcHandler:sayLocalized("npc.melfar.here_you_go_3", npc, creature)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.melfar.you_dont_have_4", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "buy flask") or MsgContains(message, "flask") then
		if player:getStorageValue(TheNewFrontier.Questline) == 5 then
			npcHandler:sayLocalized("npc.melfar.you_want_to_5", npc, creature)
			npcHandler:setTopic(playerId, 2)
		else
			npcHandler:sayLocalized("npc.melfar.im_out_of_6", npc, creature)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Just great, another disturbance. Just what I need.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
