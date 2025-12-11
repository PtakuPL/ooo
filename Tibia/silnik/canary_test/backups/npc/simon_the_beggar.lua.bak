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
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
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
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_1")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "100 ape fur") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_2")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "beard") then
		if player:getSex() == PLAYERSEX_MALE then
			if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 8 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_3")
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 9)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon, os.time())
			elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 9 then
				local beggarOutfitTimer = player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon)
				if os.time() - beggarOutfitTimer >= 432000 then -- 5 dias em segundos
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_4")
					player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 10)
					player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
					player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
					player:addOutfitAddon(153, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_5")
				end
			end
		end
	elseif MsgContains(message, "addon") then
		if player:getSex() == PLAYERSEX_MALE and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 9 then
			local beggarOutfitTimer = player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon)
			if os.time() - beggarOutfitTimer >= 432000 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_6")
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 10)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
				player:addOutfitAddon(153, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_7")
			end
		end
	elseif MsgContains(message, "gypsy dress") then
		if player:getSex() == PLAYERSEX_FEMALE then
			if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 8 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_8")
				player:addOutfitAddon(157, 1)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getSex() == PLAYERSEX_MALE then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_13")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_15")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_9")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_11")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_12")
				npcHandler:setTopic(playerId, 2)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_9")
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 7)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:isPremium() then
				if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor) == -1 then
					if player:getItemCount(5883) >= 100 and player:getMoney() + player:getBankBalance() >= 20000 then
						if player:removeItem(5883, 100) and player:removeMoneyBank(20000) then
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_10")
							player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 8)
							if player:getSex() == PLAYERSEX_MALE then
								player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimerAddon, os.time())
							end
						else
							NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_11")
						end
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_12")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_13")
				end
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- Second addon logic
	if MsgContains(message, "addon") and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 10 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_14")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "staff") then
		if npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_15")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_8")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_16")
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 11)
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarFirstAddonDoor, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "staff") and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 11 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_17")
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 7 then
			if player:isPremium() then
				if player:getItemCount(6107) >= 1 then
					if player:removeItem(6107, 1) then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_18")
						player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
						player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarSecondAddon, 2)
						player:addOutfitAddon(153, 2)
						player:addOutfitAddon(157, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_19")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_20")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_21")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.SimonTheBeggar) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_22")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_23")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 8 then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_24")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.SimonTheBeggar, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end
			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_5")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif npcHandler:getTopic(playerId) == 9 then
			if not player:removeMoneyBank(100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_25")
				npcHandler:setTopic(playerId, 0)
				return true
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_26")
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			if not player:removeMoneyBank(500) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_27")
				npcHandler:setTopic(playerId, 0)
				return true
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.multi_2")
			npcHandler:setTopic(playerId, 11)
		elseif npcHandler:getTopic(playerId) == 11 then
			if not player:removeMoneyBank(200) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_28")
				npcHandler:setTopic(playerId, 0)
				return true
			end
			local key = player:addItem(2968, 1)
			if key then
				key:setActionId(3940)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.simon_the_beggar.say_29")
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
