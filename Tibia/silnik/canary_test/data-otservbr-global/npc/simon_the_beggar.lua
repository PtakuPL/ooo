local internalNpcName = "Simon The Beggar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 116,
	lookBody = 123,
	lookLegs = 123,
	lookFeet = 40,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}
npcConfig.shop = {
	{ itemName = "shovel", clientId = 3457, count = 1 },
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

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Alms! Alms for the poor!" },
	{ text = "Sir, Ma'am, have a gold coin to spare?" },
	{ text = "I need help! Please help me!" },
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

	-- Outfits and Addons logic
	if MsgContains(message, "outfit") then
		if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 6 then
			if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and 157 or 153) then
				npcHandler:sayLocalized("npc.simon_the_beggar.haha_that_beard_1", npc, creature)
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "100 ape fur") then
		npcHandler:sayLocalized("npc.simon_the_beggar.have_you_brought_2", npc, creature)
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "beard") then
		if player:getSex() == PLAYERSEX_MALE then
			if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 8 then
				npcHandler:sayLocalized("npc.simon_the_beggar.hmm_im_not_3", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 9)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon, os.time())
			elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 9 then
				local beggarOutfitTimer = player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon)
				if os.time() - beggarOutfitTimer >= 432000 then -- 5 dias em segundos
					npcHandler:sayLocalized("npc.simon_the_beggar.aha_i_can_4", npc, creature)
					player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 10)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
					player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
					player:addOutfitAddon(153, 1)
					npcHandler:setTopic(playerId, 0)
				else
					npcHandler:sayLocalized("npc.simon_the_beggar.hmm_it_seems_5", npc, creature)
				end
			end
		end
	elseif MsgContains(message, "addon") then
		if player:getSex() == PLAYERSEX_MALE and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 9 then
			local beggarOutfitTimer = player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon)
			if os.time() - beggarOutfitTimer >= 432000 then
				npcHandler:sayLocalized("npc.simon_the_beggar.aha_i_can_6", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 10)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
				player:addOutfitAddon(153, 1)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.simon_the_beggar.hmm_it_seems_7", npc, creature)
			end
		end
	elseif MsgContains(message, "gypsy dress") then
		if player:getSex() == PLAYERSEX_FEMALE then
			if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 8 then
				npcHandler:sayLocalized("npc.simon_the_beggar.oh_im_sorry_8", npc, creature)
				player:addOutfitAddon(157, 1)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getSex() == PLAYERSEX_MALE then
				npcHandler:say({
					"I can mix a secret potion which will increase your facial hair growth enormously. I call it 'Instabeard'. However, it requires certain ingredients. ...",
					"For the small fee of 20000 gold pieces I will help you mix this potion. Just bring me 100 pieces of ape fur, which are necessary to create this potion. ...",
					"Do we have a deal?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 2)
			else
				npcHandler:say({
					"I can mix a secret potion which increases facial hair growth enormously. I call it 'Instabeard'. However, I fear it works only for men. ...",
					"Even if it worked on girls, I'd rather not be responsible for you ruining your pretty face. I have an idea though. If you help me brew one of these potions, I will sell something nice to you. ...",
					"I still have a pretty gypsy dress and a pearl necklace somewhere, which you could wear instead of this ragged skirt. For the small fee of 20000 gold pieces, it'd be yours. ...",
					"You only have to bring me 100 pieces of ape fur, so I can brew the potion. Do we have a deal?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 2)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.simon_the_beggar.great_come_back_9", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 7)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:isPremium() then
				if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor) == -1 then
					if player:getItemCount(5883) >= 100 and player:getMoney() + player:getBankBalance() >= 20000 then
						if player:removeItem(5883, 100) and player:removeMoneyBank(20000) then
							npcHandler:sayLocalized("npc.simon_the_beggar.ahh_very_good_10", npc, creature)
							player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 8)
							if player:getSex() == PLAYERSEX_MALE then
								player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon, os.time())
							end
						else
							npcHandler:sayLocalized("npc.simon_the_beggar.you_do_not_11", npc, creature)
						end
					else
						npcHandler:sayLocalized("npc.simon_the_beggar.you_do_not_12", npc, creature)
					end
				else
					npcHandler:sayLocalized("npc.simon_the_beggar.it_seems_you_13", npc, creature)
				end
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- Second addon logic
	if MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 10 then
		npcHandler:sayLocalized("npc.simon_the_beggar.no_no_our_14", npc, creature)
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "staff") then
		if npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.simon_the_beggar.i_said_no_15", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 5 then
			npcHandler:say({
				"When I was wandering around in Tibia, I lost my favourite staff somewhere in the northern ruins in Edron. ...",
				"Uh, don't ask me what I was doing there... sort of a pilgrimage. Well anyway, if you could bring that staff back to me, I promise I'll give you my current one. ...",
				"What do you say?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:sayLocalized("npc.simon_the_beggar.good_come_back_16", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 11)
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "staff") and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 11 then
		npcHandler:sayLocalized("npc.simon_the_beggar.did_you_bring_17", npc, creature)
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 7 then
			if player:isPremium() then
				if player:getItemCount(6107) >= 1 then
					if player:removeItem(6107, 1) then
						npcHandler:sayLocalized("npc.simon_the_beggar.yes_thats_it_18", npc, creature)
						player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
						player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarSecondAddon, 2)
						player:addOutfitAddon(153, 2)
						player:addOutfitAddon(157, 2)
					else
						npcHandler:sayLocalized("npc.simon_the_beggar.you_do_not_19", npc, creature)
					end
				else
					npcHandler:sayLocalized("npc.simon_the_beggar.you_do_not_20", npc, creature)
				end
			else
				npcHandler:sayLocalized("npc.simon_the_beggar.sorry_but_you_21", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.SimonTheBeggar) ~= 1 then
			npcHandler:sayLocalized("npc.simon_the_beggar.have_you_brought_22", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "help") then
		npcHandler:sayLocalized("npc.simon_the_beggar.i_need_gold_23", npc, creature)
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 8 then
			if not player:removeItem(130, 1) then
				npcHandler:sayLocalized("npc.simon_the_beggar.you_have_no_24", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.SimonTheBeggar, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end
			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			npcHandler:say({
				"Well, it's the least you can do for those who live in dire poverty.",
				"A single cookie is a bit less than I'd expected, but better than ... WHA ... WHAT??",
				"MY BEARD! MY PRECIOUS BEARD! IT WILL TAKE AGES TO CLEAR IT OF THIS CONFETTI!",
			}, npc, creature)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif npcHandler:getTopic(playerId) == 9 then
			if not player:removeMoneyBank(100) then
				npcHandler:sayLocalized("npc.simon_the_beggar.you_havent_got_25", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
			npcHandler:sayLocalized("npc.simon_the_beggar.thank_you_very_26", npc, creature)
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			if not player:removeMoneyBank(500) then
				npcHandler:sayLocalized("npc.simon_the_beggar.sorry_thats_not_27", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
			npcHandler:say({
				"That's great! I have stolen something from Dermot.",
				"You can buy it for 200 gold. Do you want to buy it?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif npcHandler:getTopic(playerId) == 11 then
			if not player:removeMoneyBank(200) then
				npcHandler:sayLocalized("npc.simon_the_beggar.pah_i_said_28", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
			local key = player:addItem(2968, 1)
			if key then
				key:setActionId(3940)
			end
			npcHandler:sayLocalized("npc.simon_the_beggar.now_you_own_29", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "no") and npcHandler:getTopic(playerId) ~= 0 then
		local noResponse = {
			[1] = "I see.",
			[2] = "Hmm, maybe next time.",
			[3] = "It was your decision.",
			[4] = "I see.",
			[5] = "Hmm, maybe next time.",
			[6] = "It was your decision.",
			[7] = "Ok. No problem",
			[8] = "Ok. No problem",
			[9] = "Ok. No problem",
			[10] = "Ok. No problem",
			[11] = "Ok. No problem",
		}
		npcHandler:say(noResponse[npcHandler:getTopic(playerId)], npc, creature)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|. I am a poor man. Please help me.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Have a nice day.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Have a nice day.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
