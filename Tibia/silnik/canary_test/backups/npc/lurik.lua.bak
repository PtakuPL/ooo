local internalNpcName = "Lurik"
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
	lookHead = 38,
	lookBody = 94,
	lookLegs = 96,
	lookFeet = 116,
	lookAddons = 3,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheAstralPortals) == 56 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 56 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIslandofDragons) == 57 then --will need review in the future
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIslandofDragons) == 58 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 58 then
			if player:removeItem(7314, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_19")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_20")
				player:addItem(3035, 50)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIslandofDragons, 59)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 59)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_2")
			end
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIslandofDragons) == 59 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 59 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_18")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceMusic, 60)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 60)
			player:addItem(7242, 1)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceMusic) == 61 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 61 and player:removeItem(7315, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_13")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceMusic, 62)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 62)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.IceMusicDoor, 1)
		elseif player:getStorageValue(Storage.TheIceIslands.Questline) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_10")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 34 and player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.MemoryCrystal) > os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_4")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 34 and player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.MemoryCrystal) < os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_7")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 35)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission09, 1) -- Questlog The Ice Islands Quest, Formorgar Mines 1: The Mission
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.FormorgarMinesDoor, 1)
		end
	elseif MsgContains(message, "yes") then
		-- ISLAND OF DRAGONS
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.multi_4")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIslandofDragons, 57)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 57)
			-- ISLAND OF DRAGONS
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_5")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 33)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission08, 2) -- Questlog The Ice Islands Quest, The Contact
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(7281, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lurik.say_6")
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 34)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission08, 4) -- Questlog The Ice Islands Quest, The Contact
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.MemoryCrystal, os.time() + 5 * 60)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome to the {explorer society} headquarter of Svargrond, |PLAYERNAME|!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "orichalcum pearl", clientId = 5021, buy = 80 },
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
