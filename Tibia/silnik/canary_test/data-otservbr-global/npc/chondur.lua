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
				npcHandler:sayLocalized("npc.chondur.the_time_has_1", npc, creature)
				npcHandler:setTopic(playerId, 1)
			elseif player:hasOutfit(158, 2) or player:hasOutfit(154, 2) and not (player:hasOutfit(158, 1) or player:hasOutfit(154, 1)) then
				npcHandler:sayLocalized("npc.chondur.you_have_successfully_2", npc, creature)
				npcHandler:setTopic(playerId, 3)
			end
		else
			npcHandler:sayLocalized("npc.chondur.you_must_have_3", npc, creature)
		end
		return true
	elseif MsgContains(message, "task") and npcHandler:getTopic(playerId) == 1 then
		npcHandler:say({
			"Deep in the Tiquandian jungle a monster lurks which is seldom seen. It is the revenge of the jungle against humankind. ...",
			"This monster, if slain, carries a rare root called Mandrake. If you find it, bring it to me. Also, gather 5 of the voodoo dolls used by the mysterious dworc voodoomasters. ...",
			"If you manage to fulfil this task, I will grant you your own staff. Have you understood everything and are ready for this test?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 2)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		npcHandler:sayLocalized("npc.chondur.good_come_back_4", npc, creature)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 1)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionStaff, 1)
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "dworc voodoo doll") or MsgContains(message, "mandrake") then
		npcHandler:sayLocalized("npc.chondur.have_you_gathered_5", npc, creature)
		npcHandler:setTopic(playerId, 5)
		return true
	elseif MsgContains(message, "tribal masks") or MsgContains(message, "banana staff") then
		npcHandler:sayLocalized("npc.chondur.have_you_gathered_6", npc, creature)
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
			npcHandler:sayLocalized("npc.chondur.i_am_proud_7", npc, creature)
		else
			npcHandler:sayLocalized("npc.chondur.you_dont_have_8", npc, creature)
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
			npcHandler:sayLocalized("npc.chondur.well_done_my_9", npc, creature)
		else
			npcHandler:sayLocalized("npc.chondur.you_dont_have_10", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		npcHandler:say({
			"The dworcs of Tiquanda like to wear certain tribal masks which I would like to take a look at. Please bring me 5 of these masks. ...",
			"Secondly, the high ape magicians of Banuta use banana staves. I would love to learn more about these staves, so please bring me 5 of them also. ...",
			"If you manage to fulfil this task, I will grant you your own mask. Have you understood everything and are ready for this test?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 4)
		return true
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 4 then
		npcHandler:say({
			"Good! Come back once you have collected 5 tribal masks and 5 banana staves.",
			"I shall grant you a sign of your progress as shaman if you can fulfil my task.",
		}, npc, creature)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.AddonStaffMask, 3)
		player:setStorageValue(Storage.Quest.U7_8.ShamanOutfits.MissionMask, 1)
		npcHandler:setTopic(playerId, 0)
		return true
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 2 then
		npcHandler:sayLocalized("npc.chondur.maybe_next_time_11", npc, creature)
		npcHandler:setTopic(playerId, 0)
	end

	return false
end

local function handleOtherMessages(npcHandler, npc, creature, message, playerId)
	local player = Player(creature)

	if MsgContains(message, "stampor") or MsgContains(message, "mount") then
		if not player:hasMount(11) then
			npcHandler:sayLocalized("npc.chondur.you_did_bring_12", npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:sayLocalized("npc.chondur.you_already_have_13", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 11 then
			npcHandler:sayLocalized("npc.chondur.the_evil_cult_14", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 12)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 12 then
			npcHandler:sayLocalized("npc.chondur.did_you_bring_15", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(12312, 50) and player:removeItem(12314, 30) and player:removeItem(12313, 100) then
				npcHandler:say({
					"Ohhhhh Mmmmmmmmmmmm Ammmmmgggggggaaaaaaa ...",
					"Aaaaaaaaaahhmmmm Mmmaaaaaaaaaa Kaaaaaamaaaa ...",
					"Brrt! I think it worked! It's a male stampor. I linked this spirit to yours. You can probably already summon him to you ...",
					"So, since we are done here... I need to prepare another ritual, so please let me work, child.",
				}, npc, creature)
				player:addMount(11)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			else
				npcHandler:sayLocalized("npc.chondur.sorry_you_dont_16", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 12 then
				if player:removeItem(5810, 5) then
					npcHandler:sayLocalized("npc.chondur.finally_i_can_17", npc, creature)
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 13)
					npcHandler:setTopic(playerId, 0)
				else
					npcHandler:sayLocalized("npc.chondur.you_dont_have_18", npc, creature)
					npcHandler:setTopic(playerId, 0)
				end
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			npcHandler:sayLocalized("npc.chondur.this_is_really_19", npc, creature)
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			npcHandler:say({
				"I guess I cannot stop you then. Since you told me about my apprentice, it is my turn to help you. I will perform a ritual for you, but I need a few ingredients. ...",
				"Bring me one fresh dead chicken, one fresh dead rat and one fresh dead black sheep, in that order.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			if player:getItemCount(4330) > 0 then
				player:removeItem(4330, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 2)
				npcHandler:sayLocalized("npc.chondur.very_good_mumble_20", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.you_dont_have_21", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:getItemCount(3994) > 0 then
				player:removeItem(3994, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 3)
				npcHandler:sayLocalized("npc.chondur.very_good_chants_22", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.you_dont_have_23", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:getItemCount(4095) > 0 then
				player:removeItem(4095, 1)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 4)
				npcHandler:sayLocalized("npc.chondur.very_good_stomps_24", npc, creature)
				return true
			else
				npcHandler:sayLocalized("npc.chondur.you_dont_have_25", npc, creature)
				return true
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "stake") then
		if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 11 then
			npcHandler:sayLocalized("npc.chondur.ten_prayers_for_26", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 12)
			player:addAchievement("Blessed!")
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			return true
		elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 12 then
			if player:getItemCount(5941) == 0 then
				npcHandler:sayLocalized("npc.chondur.you_dont_have_27", npc, creature)
				return true
			elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStakeWaitTime) >= os.time() then
				npcHandler:sayLocalized("npc.chondur.sorry_but_im_28", npc, creature)
				return true
			else
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStakeWaitTime, os.time() + 7 * 86400)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:removeItem(5941, 1)
				player:addItem(5942, 1)
				npcHandler:sayLocalized("npc.chondur.mumblemumble_sha_kesh_29", npc, creature)
				return true
			end
		end
	elseif MsgContains(message, "counterspell") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DragahsSpellbook) == -1 then
			npcHandler:sayLocalized("npc.chondur.you_should_not_30", npc, creature)
			return true
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == -1 then
			npcHandler:sayLocalized("npc.chondur.you_mean_you_31", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell, 0)
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 1 then
			npcHandler:sayLocalized("npc.chondur.did_you_bring_32", npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 2 then
			npcHandler:sayLocalized("npc.chondur.did_you_bring_33", npc, creature)
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 3 then
			npcHandler:sayLocalized("npc.chondur.did_you_bring_34", npc, creature)
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TheCounterspell) == 4 then
			npcHandler:sayLocalized("npc.chondur.hm_i_dont_35", npc, creature)
			return true
		end
	elseif MsgContains(message, "spellbook") then
		if player:getItemCount(6120) > 0 then
			npcHandler:sayLocalized("npc.chondur.ah_thank_you_36", npc, creature)
			player:removeItem(6120, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DragahsSpellbook, 1)
			return true
		else
			npcHandler:sayLocalized("npc.chondur.you_dont_have_37", npc, creature)
			return true
		end
	elseif MsgContains(message, "energy field") then
		npcHandler:sayLocalized("npc.chondur.ah_the_energy_38", npc, creature)
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

npcHandler:setMessage(MESSAGE_GREET, "Be greeted, child.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye.")

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
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
