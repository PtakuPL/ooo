local internalNpcName = "Irmana"
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
	lookHead = 78,
	lookBody = 90,
	lookLegs = 13,
	lookFeet = 14,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallbackFemale(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_1")
		npcHandler:setTopic(playerId, 19)
	elseif npcHandler:getTopic(playerId) == 19 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_2")
		npcHandler:setTopic(playerId, 20)
	elseif npcHandler:getTopic(playerId) == 20 and MsgContains(message, "dress") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_3")
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_15")
		npcHandler:setTopic(playerId, 22)
	elseif npcHandler:getTopic(playerId) == 22 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_4")
		npcHandler:setTopic(playerId, 23)
	elseif npcHandler:getTopic(playerId) == 23 and MsgContains(message, "150000") then
		player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_5")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_6")
		npcHandler:setTopic(playerId, 24)
	elseif npcHandler:getTopic(playerId) == 24 and MsgContains(message, "yes") then
		if player:removeMoney(150000) then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addOutfitAddon(140, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_7")
			player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_8")
		end
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_9")
		npcHandler:setTopic(playerId, 25)
	elseif npcHandler:getTopic(playerId) == 25 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_10")
		npcHandler:setTopic(playerId, 26)
	elseif npcHandler:getTopic(playerId) == 26 and MsgContains(message, "hat") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_11")
		npcHandler:setTopic(playerId, 27)
	elseif npcHandler:getTopic(playerId) == 27 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_12")
		npcHandler:setTopic(playerId, 28)
	elseif npcHandler:getTopic(playerId) == 28 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_12")
		npcHandler:setTopic(playerId, 29)
	elseif npcHandler:getTopic(playerId) == 29 and MsgContains(message, "150000") then
		player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_13")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_14")
		npcHandler:setTopic(playerId, 30)
	elseif npcHandler:getTopic(playerId) == 30 and MsgContains(message, "yes") then
		if player:removeMoney(150000) then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addOutfitAddon(140, 2)
			player:addAchievement(226) -- Achievement Aristocrat
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_15")
			player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_16")
		end
	end

	return true
end

local function creatureSayCallbackMale(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_17")
		npcHandler:setTopic(playerId, 9)
	elseif npcHandler:getTopic(playerId) == 9 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_18")
		npcHandler:setTopic(playerId, 10)
	elseif npcHandler:getTopic(playerId) == 10 and MsgContains(message, "coat") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_19")
		npcHandler:setTopic(playerId, 11)
	elseif npcHandler:getTopic(playerId) == 11 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_9")
		npcHandler:setTopic(playerId, 12)
	elseif npcHandler:getTopic(playerId) == 12 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_20")
		npcHandler:setTopic(playerId, 13)
	elseif npcHandler:getTopic(playerId) == 13 and MsgContains(message, "150000") then
		player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_21")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon) == 1 then
		if player:removeMoney(150000) then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addOutfitAddon(132, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_22")
			player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanFirstAddon, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_23")
		end
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_24")
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_25")
		npcHandler:setTopic(playerId, 15)
	elseif npcHandler:getTopic(playerId) == 15 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_26")
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_6")
		npcHandler:setTopic(playerId, 17)
	elseif npcHandler:getTopic(playerId) == 17 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_27")
		npcHandler:setTopic(playerId, 18)
	elseif npcHandler:getTopic(playerId) == 18 and MsgContains(message, "150000") then
		player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_28")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon) == 1 then
		if player:removeMoney(150000) then
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addOutfitAddon(132, 2)
			player:addAchievement(226) -- Achievement Aristocrat
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_29")
			player:setStorageValue(Storage.Quest.U7_8.NoblemanOutfits.NoblemanSecondAddon, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_30")
		end
	end

	return true
end

local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	local playerSex = player:getSex()

	if MsgContains(message, "fur") then
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 7 and player:getStorageValue(ThreatenedDreams.Mission01.PoacherNotes) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.multi_3")
			npcHandler:setTopic(playerId, 8)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_31")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 5 then
		if player:getItemCount(3566) >= 1 then
			player:removeItem(3566, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_32")
			player:addItem(5911, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_33")
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		if player:getItemCount(3574) >= 1 then
			player:removeItem(3574, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_34")
			player:addItem(5912, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_35")
		end
	elseif npcHandler:getTopic(playerId) == 7 then
		if player:getItemCount(3563) >= 150 then
			player:removeItem(3563, 150)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_36")
			player:addItem(5910, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_37")
		end
	elseif npcHandler:getTopic(playerId) == 8 then
		if player:getMoney() >= 1000 then
			player:removeMoney(1000)
			player:addItem(25238, 1) -- Fur of a Wolf Whelp
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_38")
			player:setStorageValue(ThreatenedDreams.Mission01[1], 8)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_39")
		end
	elseif MsgContains(message, "red robe") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_40")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "mystic turban") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_41")
		npcHandler:setTopic(playerId, 6)
	elseif MsgContains(message, "green tunic") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.irmana.say_42")
		npcHandler:setTopic(playerId, 7)
	elseif playerSex == PLAYERSEX_MALE then
		return creatureSayCallbackMale(npc, creature, type, message)
	else
		return creatureSayCallbackFemale(npc, creature, type, message)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome to the house of fashion, |PLAYERNAME|!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "ape fur", clientId = 5883, sell = 120 },
	{ itemName = "badger fur", clientId = 10299, sell = 15 },
	{ itemName = "black wool", clientId = 11448, sell = 300 },
	{ itemName = "blue piece of cloth", clientId = 5912, sell = 200 },
	{ itemName = "brown piece of cloth", clientId = 5913, sell = 100 },
	{ itemName = "bunch of troll hair", clientId = 9689, sell = 30 },
	{ itemName = "dirty turban", clientId = 11456, sell = 120 },
	{ itemName = "downy feather", clientId = 11684, sell = 20 },
	{ itemName = "earflap", clientId = 17819, sell = 40 },
	{ itemName = "frost giant pelt", clientId = 9658, sell = 160 },
	{ itemName = "geomancer's robe", clientId = 11458, sell = 80 },
	{ itemName = "ghostly tissue", clientId = 9690, sell = 90 },
	{ itemName = "gloom wolf fur", clientId = 22007, sell = 70 },
	{ itemName = "green dragon leather", clientId = 5877, sell = 100 },
	{ itemName = "green piece of cloth", clientId = 5910, sell = 200 },
	{ itemName = "jewelled belt", clientId = 11470, sell = 180 },
	{ itemName = "lion's mane", clientId = 9691, sell = 60 },
	{ itemName = "lizard leather", clientId = 5876, sell = 150 },
	{ itemName = "minotaur leather", clientId = 5878, sell = 80 },
	{ itemName = "necromantic robe", clientId = 11475, sell = 250 },
	{ itemName = "noble turban", clientId = 11486, sell = 430 },
	{ itemName = "piece of crocodile leather", clientId = 10279, sell = 15 },
	{ itemName = "purple robe", clientId = 11473, sell = 110 },
	{ itemName = "red dragon leather", clientId = 5948, sell = 200 },
	{ itemName = "red piece of cloth", clientId = 5911, sell = 300 },
	{ itemName = "rope belt", clientId = 11492, sell = 66 },
	{ itemName = "royal tapestry", clientId = 9045, sell = 1000 },
	{ itemName = "safety pin", clientId = 11493, sell = 120 },
	{ itemName = "shaggy tail", clientId = 10407, sell = 25 },
	{ itemName = "silky fur", clientId = 10292, sell = 35 },
	{ itemName = "simple dress", clientId = 3568, sell = 50 },
	{ itemName = "skunk tail", clientId = 10274, sell = 50 },
	{ itemName = "snake skin", clientId = 9694, sell = 400 },
	{ itemName = "spool of yarn", clientId = 5886, sell = 1000 },
	{ itemName = "striped fur", clientId = 10293, sell = 50 },
	{ itemName = "tattered piece of robe", clientId = 9684, sell = 120 },
	{ itemName = "thick fur", clientId = 10307, sell = 150 },
	{ itemName = "velvet tapestry", clientId = 8923, sell = 800 },
	{ itemName = "warwolf fur", clientId = 10318, sell = 30 },
	{ itemName = "werewolf fur", clientId = 10317, sell = 380 },
	{ itemName = "white piece of cloth", clientId = 5909, sell = 100 },
	{ itemName = "winter wolf fur", clientId = 10295, sell = 20 },
	{ itemName = "wool", clientId = 10319, sell = 15 },
	{ itemName = "yellow piece of cloth", clientId = 5914, sell = 150 },
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
