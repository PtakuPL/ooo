local internalNpcName = "Chondur"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 154,
	lookHead = 38,
	lookBody = 113,
	lookLegs = 119,
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

local function handleAddonMessages(npcHandler, npc, creature, message, playerId)
	local player = Player(creature)

	if MsgContains(message, "addon") then
		if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and 158 or 154) then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) >= 4 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove) >= 5 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) >= 10 and player:getStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask) < 1 then
				npcHandler:sayLocalized("npc.chondur.say_1", npc, creature)
				npcHandler:setTopic(playerId, 1)
			elseif player:hasOutfit(158, 2) or player:hasOutfit(154, 2) and not (player:hasOutfit(158, 1) or player:hasOutfit(154, 1)) then
				npcHandler:sayLocalized("npc.chondur.say_2", npc, creature)
				npcHandler:setTopic(playerId, 3)
			end
		else
			npcHandler:sayLocalized("npc.chondur.say_3", npc, creature)
		end
		return true
	elseif MsgContains(message, "task") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_14")
		npcHandler:setTopic(playerId, 2)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:sayLocalized("npc.chondur.say_4", npc, creature)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 1)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionStaff, 1)
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "dworc voodoo doll") or MsgContains(message, "mandrake") then
		npcHandler:sayLocalized("npc.chondur.say_5", npc, creature)
		npcHandler:setTopic(playerId, 5)
		return true
	elseif MsgContains(message, "tribal masks") or MsgContains(message, "banana staff") then
		npcHandler:sayLocalized("npc.chondur.say_6", npc, creature)
		npcHandler:setTopic(playerId, 6)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 then
		if player:getItemCount(3002) >= 5 and player:getItemCount(5014) >= 1 then
			player:removeItem(3002, 5)
			player:removeItem(5014, 1)
			player:addOutfitAddon(158, 2)
			player:addOutfitAddon(154, 2)
			player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 2)
			player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionStaff, 2)
			player:addAchievement("Way of the Shaman")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			npcHandler:sayLocalized("npc.chondur.say_7", npc, creature)
		else
			npcHandler:sayLocalized("npc.chondur.say_8", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		if player:getItemCount(3348) >= 5 and player:getItemCount(3403) >= 5 then
			player:removeItem(3348, 5)
			player:removeItem(3403, 5)
			player:addOutfitAddon(158, 1)
			player:addOutfitAddon(154, 1)
			player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 4)
			player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionMask, 2)
			player:addAchievement("Way of the Shaman")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			npcHandler:sayLocalized("npc.chondur.say_9", npc, creature)
		else
			npcHandler:sayLocalized("npc.chondur.say_10", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_11")
		npcHandler:setTopic(playerId, 4)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_8")
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 3)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionMask, 1)
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 2 then
		npcHandler:sayLocalized("npc.chondur.say_11", npc, creature)
		npcHandler:setTopic(playerId, 0)
	end

	return false
end

local function handleOtherMessages(npcHandler, npc, creature, message, playerId)
	local player = Player(creature)

	if MsgContains(message, "stampor") or MsgContains(message, "mount") then
		if not player:hasMount(11) then
			npcHandler:sayLocalized("npc.chondur.say_12", npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:sayLocalized("npc.chondur.say_13", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 11 then
			npcHandler:sayLocalized("npc.chondur.say_14", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 12)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 12 then
			npcHandler:sayLocalized("npc.chondur.say_15", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(12312, 50) and player:removeItem(12314, 30) and player:removeItem(12313, 100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_6")
				player:addMount(11)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			else
				npcHandler:sayLocalized("npc.chondur.say_16", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 12 then
				if player:removeItem(5810, 5) then
					npcHandler:sayLocalized("npc.chondur.say_17", npc, creature)
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 13)
					npcHandler:setTopic(playerId, 0)
				else
					npcHandler:sayLocalized("npc.chondur.say_18", npc, creature)
					npcHandler:setTopic(playerId, 0)
				end
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			npcHandler:sayLocalized("npc.chondur.say_19", npc, creature)
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chondur.multi_2")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			if player:getItemCount(4330) > 0 then
				player:removeItem(4330, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 2)
				npcHandler:sayLocalized("npc.chondur.say_20", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.say_21", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:getItemCount(3994) > 0 then
				player:removeItem(3994, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 3)
				npcHandler:sayLocalized("npc.chondur.say_22", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.say_23", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:getItemCount(4095) > 0 then
				player:removeItem(4095, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 4)
				npcHandler:sayLocalized("npc.chondur.say_24", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.say_25", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "stake") then
		if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 11 then
			npcHandler:sayLocalized("npc.chondur.say_26", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 12)
			player:addAchievement("Blessed!")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			return true
		elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 12 then
			if player:getItemCount(5941) == 0 then
				npcHandler:sayLocalized("npc.chondur.say_27", npc, creature)
				return true
			elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStakeWaitTime) >= os.time() then
				npcHandler:sayLocalized("npc.chondur.say_28", npc, creature)
				return true
			else
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStakeWaitTime, os.time() + 7 * 86400)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:removeItem(5941, 1)
				player:addItem(5942, 1)
				npcHandler:sayLocalized("npc.chondur.say_29", npc, creature)
				return true
			end
		end
	elseif MsgContains(message, "counterspell") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DragahsSpellbook) == -1 then
			npcHandler:sayLocalized("npc.chondur.say_30", npc, creature)
			return true
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == -1 then
			npcHandler:sayLocalized("npc.chondur.say_31", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 0)
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 1 then
			npcHandler:sayLocalized("npc.chondur.say_32", npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 2 then
			npcHandler:sayLocalized("npc.chondur.say_33", npc, creature)
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 3 then
			npcHandler:sayLocalized("npc.chondur.say_34", npc, creature)
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 4 then
			npcHandler:sayLocalized("npc.chondur.say_35", npc, creature)
			return true
		end
	elseif MsgContains(message, "spellbook") then
		if player:getItemCount(6120) > 0 then
			npcHandler:sayLocalized("npc.chondur.say_36", npc, creature)
			player:removeItem(6120, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DragahsSpellbook, 1)
			return true
		else
			npcHandler:sayLocalized("npc.chondur.say_37", npc, creature)
			return true
		end
	elseif MsgContains(message, "energy field") then
		npcHandler:sayLocalized("npc.chondur.say_38", npc, creature)
		return true
	end

	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if handleAddonMessages(npcHandler, npc, creature, message, playerId) then
		return true
	end

	if handleOtherMessages(npcHandler, npc, creature, message, playerId) then
		return true
	end

	return false
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.chondur.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.chondur.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "black skull", clientId = 9056, sell = 4000 },
	{ itemName = "blood goblet", clientId = 8531, sell = 10000 },
	{ itemName = "blood herb", clientId = 3734, sell = 500 },
	{ itemName = "enigmatic voodoo skull", clientId = 5669, sell = 4000 },
	{ itemName = "mysterious voodoo skull", clientId = 5668, sell = 4000 },
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
