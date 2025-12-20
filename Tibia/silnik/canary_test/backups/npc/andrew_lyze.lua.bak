local internalNpcName = "Andrew Lyze"
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
	lookHead = 38,
	lookBody = 43,
	lookLegs = 75,
	lookFeet = 58,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}
npcConfig.shop = {
	{ itemName = "broken compass", clientId = 25746, buy = 10000 },
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

local brokenCompass = 25746
local chargeableCompass = 29291
local chargedCompass = 29294
local goldenAxe = 29286
local CompassValue = 10000

local buildCompass = {
	[1] = { id = 29346, qnt = 15 },
	[2] = { id = 29345, qnt = 50 },
	[3] = { id = 29347, qnt = 5 },
	[4] = { id = 25746, qnt = 1 },
}

local chargeCompass = {
	[1] = { id = 29287, qnt = 5 },
	[2] = { id = 29288, qnt = 3 },
	[3] = { id = 29289, qnt = 1 },
	[4] = { id = 29348, qnt = 1 },
	[5] = { id = 29291, qnt = 1 },
}

local function removeBait(player)
	local player = Player(player)

	if player and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.HasBait) == 1 then
		player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.HasBait, -1)
	end
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) < 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Hello, I am the warden of this {monument}. The {sarcophagus} in front of you was established to prevent people from going {down} there. But I doubt that this step is sufficient.")
	elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Well, let's see if your mission was successful. Just bring me all needed {materials}.")
	elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) == 2 then
		npcHandler:setMessage(MESSAGE_GREET, "If you dug up all three crystals of sufficient quantity and obtained the poison gland, the charging of your compass can start! For the very first time it will be charged by the violet crystal. Ready to {unleash} the power of the crystals?")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Greetings.")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "monument") and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_12")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "deep") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "sarcophagus") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_2")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "down") and npcHandler:getTopic(playerId) == 10 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_3")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "materials") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_9")
			player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_4")
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 11 then
			local haveItens = false

			for _, k in pairs(buildCompass) do
				if player:getItemCount(k.id) >= k.qnt then
					haveItens = true
				else
					haveItens = false
				end
			end

			if haveItens then
				for _, k in pairs(buildCompass) do
					if player:getItemCount(k.id) >= k.qnt then
						player:removeItem(k.id, k.qnt)
					end
				end

				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_6")
				player:addItem(chargeableCompass, 1)
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline, 2)
				npcHandler:setTopic(playerId, 12)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_5")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 12 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.GotAxe) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_4")
			player:addItem(goldenAxe, 1)
			player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.GotAxe, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 51 then
			if (player:getMoney() + player:getBankBalance()) >= CompassValue then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_6")
				player:removeMoneyBank(CompassValue)
				player:addItem(brokenCompass, 1)
				npcHandler:setTopic(playerId, 10)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_7")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "unleash") then
		if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) == 2 then
			local haveItens = false

			for _, k in pairs(chargeCompass) do
				if player:getItemCount(k.id) >= k.qnt then
					haveItens = true
				else
					haveItens = false
				end
			end

			if haveItens then
				for _, k in pairs(chargeCompass) do
					if player:getItemCount(k.id) >= k.qnt then
						player:removeItem(k.id, k.qnt)
					end
				end

				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.multi_2")
				player:addItem(chargedCompass, 1)
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline, 3)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "bait") then
		if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.Questline) == 2 then
			if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.HasBait) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_9")
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.UnsafeRelease.HasBait, 1)
				addEvent(removeBait, 3 * 60 * 1000, player:getId())
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_11")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "compass") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_12")
		npcHandler:setTopic(playerId, 50)
	elseif MsgContains(message, "sell") then
		if npcHandler:getTopic(playerId) == 50 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_13")
			npcHandler:setTopic(playerId, 51)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_14")
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.andrew_lyze.say_15")
	end

	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
