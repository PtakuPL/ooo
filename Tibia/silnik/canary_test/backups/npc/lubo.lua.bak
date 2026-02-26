local internalNpcName = "Lubo"
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
	lookHead = 115,
	lookBody = 39,
	lookLegs = 96,
	lookFeet = 118,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.lubo.voice_1" },
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

	-- Citizen outfit addon
	local addonProgress = player:getStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpack)
	if MsgContains(message, "addon") or MsgContains(message, "outfit") or (addonProgress == 1 and MsgContains(message, "leather")) or ((addonProgress == 1 or addonProgress == 2) and MsgContains(message, "backpack")) then
		if addonProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif addonProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_2")
			npcHandler:setTopic(playerId, 3)
		elseif addonProgress == 2 then
			if player:getStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpackTimer) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_3")
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.MissionBackpack, 0)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpack, 3)
				player:addOutfitAddon(136, 1)
				player:addOutfitAddon(128, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_4")
			end
		elseif addonProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_5")
		end
		return true
	end
	if npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "backpack") or MsgContains(message, "minotaur") or MsgContains(message, "leather") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_6")
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpack, 1)
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.MissionBackpack, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_7")
			npcHandler:removeInteraction(npc, creature)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_8")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5878) < 100 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_10")

				player:removeItem(5878, 100)

				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.MissionBackpack, 2)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpack, 2)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfits.AddonBackpackTimer, os.time() + 2 * 60 * 60)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_11")
		end
		npcHandler:setTopic(playerId, 0)
	end

	-- The paradox tower quest
	if MsgContains(message, "crunor's cottage") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_12")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "flower guys") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_13")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "accident") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_14")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "stable") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo) == 3 then
			-- Questlog: The Feared Hugo (Completed)
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo, 4)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lubo.say_15")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_1" })
keywordHandler:addKeyword({ "dog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_2" })
keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_3" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_4" })
keywordHandler:addKeyword({ "maps" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_5" })
keywordHandler:addKeyword({ "hat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_6" })
keywordHandler:addKeyword({ "finger" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_7" })
keywordHandler:addKeyword({ "pet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lubo.stdmod_8" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lubo.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.lubo.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.lubo.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "backpack", clientId = 2854, buy = 25 },
	{ itemName = "basket", clientId = 2855, buy = 6 },
	{ itemName = "bottle", clientId = 2875, buy = 3 },
	{ itemName = "bucket", clientId = 2873, buy = 4 },
	{ itemName = "candelabrum", clientId = 2927, buy = 8 },
	{ itemName = "candlestick", clientId = 2917, buy = 2 },
	{ itemName = "closed trap", clientId = 3481, buy = 280, sell = 75 },
	{ itemName = "crowbar", clientId = 3304, buy = 260, sell = 50 },
	{ itemName = "crusher", clientId = 46627, buy = 500 },
	{ itemName = "fishing rod", clientId = 3483, buy = 150, sell = 40 },
	{ itemName = "hand auger", clientId = 31334, buy = 25 },
	{ itemName = "machete", clientId = 3308, buy = 35, sell = 6 },
	{ itemName = "net", clientId = 31489, buy = 50 },
	{ itemName = "pick", clientId = 3456, buy = 50, sell = 15 },
	{ itemName = "present", clientId = 2856, buy = 10 },
	{ itemName = "red apple", clientId = 3585, buy = 3 },
	{ itemName = "rope", clientId = 3003, buy = 50, sell = 15 },
	{ itemName = "scythe", clientId = 3453, buy = 50, sell = 10 },
	{ itemName = "shovel", clientId = 3457, buy = 50, sell = 8 },
	{ itemName = "watch", clientId = 2906, buy = 20, sell = 6 },
	{ itemName = "waterskin of water", clientId = 2901, buy = 10, count = 1 },
	{ itemName = "wooden hammer", clientId = 3459, sell = 15 },
	{ itemName = "worm", clientId = 3492, buy = 1 },
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
