local internalNpcName = "Sandra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 115,
	lookBody = 95,
	lookLegs = 125,
	lookFeet = 57,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.sandra.voice_1" },
	{ i18nKey = "npc.sandra.voice_2" },
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

	if table.contains({ "vial", "ticket", "bonus", "deposit" }, message) then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonBelt) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonBelt) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "prize") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_3")
		npcHandler:setTopic(playerId, 4)
	elseif string.match(message:lower(), "fafnar") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_4")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "your continued existence is payment enough") then
		if npcHandler:getTopic(playerId) == 6 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_5")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1, 2)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.multi_5")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_6")
			player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonBelt, 1)
			player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1) --this for default start of Outfit and Addon Quests
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(283, 100) or player:removeItem(284, 100) or player:removeItem(285, 100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_7")
				player:addItem(5957, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonBelt) == 1 and player:removeItem(5958, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_9")
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonBelt, 2)
				player:addOutfitAddon(130, 1) --male mage addon
				player:addOutfitAddon(133, 1) --male summoner addon
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandra.say_11")
				npcHandler:setTopic(playerId, 6)
			end
		end
		return true
	end
end

keywordHandler:addKeyword({ "shop" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.sandra.stdmod_1",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.sandra.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.sandra.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.sandra.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.sandra.sendtrade_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "empty potion flask", clientId = 283, sell = 5 },
	{ itemName = "empty potion flask", clientId = 284, sell = 5 },
	{ itemName = "empty potion flask", clientId = 285, sell = 5 },
	{ itemName = "great health potion", clientId = 239, buy = 225 },
	{ itemName = "great mana potion", clientId = 238, buy = 158 },
	{ itemName = "great spirit potion", clientId = 7642, buy = 254 },
	{ itemName = "health potion", clientId = 266, buy = 50 },
	{ itemName = "mana potion", clientId = 268, buy = 56 },
	{ itemName = "strong health potion", clientId = 236, buy = 115 },
	{ itemName = "strong mana potion", clientId = 237, buy = 108 },
	{ itemName = "supreme health potion", clientId = 23375, buy = 650 },
	{ itemName = "ultimate health potion", clientId = 7643, buy = 379 },
	{ itemName = "ultimate mana potion", clientId = 23373, buy = 488 },
	{ itemName = "ultimate spirit potion", clientId = 23374, buy = 488 },
	{ itemName = "vial", clientId = 2874, sell = 5 },
	{ itemName = "vial of blood", clientId = 2874, buy = 15, count = 5 },
	{ itemName = "vial of oil", clientId = 2874, buy = 20, count = 7 },
	{ itemName = "vial of slime", clientId = 2874, buy = 12, count = 6 },
	{ itemName = "vial of urine", clientId = 2874, buy = 10, count = 8 },
	{ itemName = "vial of water", clientId = 2874, buy = 8, count = 1 },
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
