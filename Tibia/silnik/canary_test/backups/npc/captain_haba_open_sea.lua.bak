local internalNpcName = "Captain Haba"
local npcType = Game.createNpcType("Captain Haba (Open Sea)")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 98,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

local TheHuntForTheSeaSerpent = Storage.Quest.U8_2.TheHuntForTheSeaSerpent
local function greetCallback(npc, creature)
	local player = Player(creature)

	if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.QuestLine) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_haba_open_sea.greet_msg_1")
	elseif player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.QuestLine) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.captain_haba_open_sea.greet_msg_2")
	end
	return true
end
local randomMessageKeys = {
	straight = {
		"npc.captain_haba_open_sea.straight_1",
		"npc.captain_haba_open_sea.straight_2",
		"npc.captain_haba_open_sea.straight_3",
		"npc.captain_haba_open_sea.straight_4",
		"npc.captain_haba_open_sea.straight_5",
	},
	starboard = {
		"npc.captain_haba_open_sea.starboard_1",
		"npc.captain_haba_open_sea.starboard_2",
		"npc.captain_haba_open_sea.starboard_3",
		"npc.captain_haba_open_sea.starboard_4",
		"npc.captain_haba_open_sea.starboard_5",
	},
	larboard = {
		"npc.captain_haba_open_sea.larboard_1",
		"npc.captain_haba_open_sea.larboard_2",
		"npc.captain_haba_open_sea.larboard_3",
		"npc.captain_haba_open_sea.larboard_4",
		"npc.captain_haba_open_sea.larboard_5",
	},
}
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "instructions") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.multi_5")
		npcHandler:setTopic(playerId, 1)
	elseif npcHandler:getTopic(playerId) == 1 and message:lower() ~= "straight" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.say_1")
		npcHandler:setTopic(playerId, 2)
	elseif npcHandler:getTopic(playerId) == 1 and message:lower() ~= "larboard" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.say_2")
		npcHandler:setTopic(playerId, 3)
	elseif npcHandler:getTopic(playerId) == 1 and message:lower() ~= "starboard" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.multi_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message:lower(), "straight") then
		local key = randomMessageKeys.straight[math.random(#randomMessageKeys.straight)]
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key)
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction) == 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		else
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 0)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		end
	elseif MsgContains(message:lower(), "starboard") then
		local key = randomMessageKeys.starboard[math.random(#randomMessageKeys.starboard)]
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key)
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction) == 2 then
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		else
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 0)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		end
	elseif MsgContains(message:lower(), "larboard") then
		local key = randomMessageKeys.larboard[math.random(#randomMessageKeys.larboard)]
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key)
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction) == 3 then
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		else
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 0)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		end
	elseif MsgContains(message:lower(), "speed") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.say_3")
		if player:getStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction) == 4 then
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		else
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.SuccessSwitch, 0)
			player:setStorageValue(Storage.Quest.U8_2.TheHuntForTheSeaSerpent.Direction, 0)
		end
	elseif table.contains({ "god", "svargrond", "back", "hunt", "passage", "trip" }, message:lower()) then
		if table.contains({ "god", "svargrond", "back", "hunt" }, message:lower()) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.say_4")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.captain_haba_open_sea.say_5")
		end
		npcHandler:setTopic(playerId, 4)
	elseif message:lower() == "yes" and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.captain_haba_open_sea.walkaway_msg_1")
		player:teleportTo(Position(32342, 31123, 6))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end
--Basic
keywordHandler:addKeyword({ "caves" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_haba_open_sea.stdmod_1" })
keywordHandler:addKeyword({ "wares" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_haba_open_sea.stdmod_2" })
keywordHandler:addAliasKeyword({ "go" })
keywordHandler:addKeyword({ "bait" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_haba_open_sea.stdmod_3" })
keywordHandler:addKeyword({ "test" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.captain_haba_open_sea.stdmod_4" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.captain_haba_open_sea.sendtrade_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bait", clientId = 939, buy = 50 },
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
