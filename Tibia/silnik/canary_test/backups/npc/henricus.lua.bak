local internalNpcName = "Henricus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 79,
	lookBody = 0,
	lookLegs = 96,
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

local flaskCost = 1000

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local missing, totalBlessPrice = Blessings.getInquisitionPrice(player)

	if MsgContains(message, "inquisitor") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_1")
	elseif MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "blessing") or MsgContains(message, "bless") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 25 then --if quest is done
			npcHandler:say("Do you want to receive the blessing of the inquisition - which means " .. (missing == 5 and "all five available" or missing) .. " blessings - for " .. totalBlessPrice .. " gold?", npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "flask") or MsgContains(message, "special flask") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) >= 12 then -- give player the ability to purchase the flask.
			npcHandler:say("Do you want to buy the special flask of holy water for " .. flaskCost .. " gold?", npc, creature)
			npcHandler:setTopic(playerId, 8)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") or MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_6")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_45")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 2)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission01, 1) -- The Inquisition Questlog- "Mission 1: Interrogation"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_7")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_40")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_41")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_43")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission02, 1) -- The Inquisition Questlog- "Mission 2: Eclipse"
			player:addItem(133, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_8")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_39")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 1) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) > 6 and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) < 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_9")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_35")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 12)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission04, 1) -- The Inquisition Questlog- "Mission 4: The Haunted Ruin"
			player:addItem(133, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 12 or player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_10")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_33")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 15)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission05, 1) -- The Inquisition Questlog- "Mission 5: Essential Gathering"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 15 then
			if player:removeItem(6499, 20) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_30")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_31")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 16)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission05, 2) -- The Inquisition Questlog- "Mission 5: Essential Gathering"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_11")
			end
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_29")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 18)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission06, 1) -- The Inquisition Questlog- "Mission 6: The Demon Ungreez"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_26")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 20)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission06, 3) -- The Inquisition Questlog- "Mission 6: The Demon Ungreez"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_12")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 21)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission07, 1) -- The Inquisition Questlog- "Mission 7: The Shadow Nexus"
			player:addItem(133, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 21 or player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_13")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_14")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if
				player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.WalterGuard) == 1
				and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.KulagGuard) == 1
				and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.GrofGuard) == 1
				and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.MilesGuard) == 1
				and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.TimGuard) == 1
			then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_23")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_24")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 3)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission01, 7) -- The Inquisition Questlog- "Mission 1: Interrogation"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_15")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 10 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_16")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 11)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 6) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_17")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 13 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_18")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 14)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission04, 3) -- The Inquisition Questlog- "Mission 4: The Haunted Ruin"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_19")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 22 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_21")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_22")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 23)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission07, 3) -- The Inquisition Questlog- "Mission 7: The Shadow Nexus"
				player:addAchievement("High Inquisitor")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_20")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if missing == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_21")
			elseif player:removeMoneyBank(totalBlessPrice) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_22")
				player:addMissingBless(false)
				player:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_23")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeMoneyBank(flaskCost) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_24")
				player:addItem(133, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_25")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(7874, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_26")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 6)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission02, 3) -- The Inquisition Questlog- "Mission 2: Eclipse"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_27")
			end
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_28")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "outfit") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_29")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 17)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission05, 3) -- The Inquisition Questlog- "Mission 5: Essential Gathering"
			player:addOutfit(288, 0)
			player:addOutfit(289, 0)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) >= 19 and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) <= 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_30")
			player:addOutfitAddon(288, 1)
			player:addOutfitAddon(289, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_31")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 24)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission07, 4) -- The Inquisition Questlog- "Mission 7: The Shadow Nexus"
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.RewardDoor, 1)
			player:addOutfitAddon(288, 2)
			player:addOutfitAddon(289, 2)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:addAchievement("Demonbane")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "dark") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_20")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "king") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_16")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_17")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_18")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "banor") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_15")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "fardos") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.say_32")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "uman") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_13")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "fafnar") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_8")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "edron") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_6")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "ankrahmun") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.henricus.multi_2")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, text = "It's a shame that only a few paladins still use their abilities to further the cause of the gods of good. Too many paladins have become selfish and greedy." })
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, text = "Nowadays, most knights seem to have forgotten the noble cause to which all knights were bound in the past. Only a few have remained pious, serve the gods and follow their teachings." })
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, { npcHandler = npcHandler, text = "Those who wield great power have to resist great temptations. We have the burden to eliminate all those who give in to the temptations." })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, text = "The druids here still follow the old rules. Sadly, the druids of Carlin have left the right path in the last years." })
keywordHandler:addKeyword({ "dwarf" }, StdModule.say, { npcHandler = npcHandler, text = "The dwarfs are allied with Thais but follow their own obscure religion. Although dwarfs keep mostly to themselves, we have to observe this alliance closely." })
keywordHandler:addKeyword({ "kazordoon" }, StdModule.say, { npcHandler = npcHandler, text = "The dwarfs are allied with Thais but follow their own obscure religion. Although dwarfs keep mostly to themselves, we have to observe this alliance closely." })
keywordHandler:addKeyword({ "elves" }, StdModule.say, { npcHandler = npcHandler, text = "Those elves are hardly any more civilised than orcs. They can become a threat to mankind at any time." })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, text = "Those elves are hardly any more civilised than orcs. They can become a threat to mankind at any time." })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, text = "Venore is somewhat difficult to handle. The merchants have a close eye on our activities in their city and our authority is limited there. However, we will use all of our influence to prevent a second Carlin." })
keywordHandler:addKeyword({ "drefia" }, StdModule.say, { npcHandler = npcHandler, text = "Drefia used to be a city of sin and heresy, just like Carlin nowadays. One day, the gods decided to destroy this town and to erase all evil there." })
keywordHandler:addKeyword({ "darashia" }, StdModule.say, { npcHandler = npcHandler, text = "Darashia is a godless town full of mislead fools. One day, it will surely share the fate of its sister town Drefia." })
keywordHandler:addKeyword({ "demon" }, StdModule.say, { npcHandler = npcHandler, text = "Demons exist in many different shapes and levels of power. In general, they are servants of the dark gods and command great powers of destruction." })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, text = "Carlin is a city of sin and heresy. After the reunion of Carlin with the kingdom, the inquisition will have much work to purify the city and its inhabitants." })
keywordHandler:addKeyword({ "zathroth" }, StdModule.say, { npcHandler = npcHandler, text = "We can see his evil influence almost everywhere. Keep your eyes open or the dark one will lead you on the wrong way and destroy you." })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, text = "The church of Crunor works closely together with the druid guild. This makes a cooperation sometimes difficult." })
keywordHandler:addKeyword({ "gods" }, StdModule.say, { npcHandler = npcHandler, text = "We owe to the gods of good our creation and continuing existence. If it weren't for them, we would surely fall prey to the minions of the vile and dark gods." })
keywordHandler:addKeyword({ "church" }, StdModule.say, { npcHandler = npcHandler, text = "The churches of the gods united to fight heresy and dark magic. They are the shield of the true believers, while the inquisition is the sword that fights all enemies of virtuousness." })
keywordHandler:addKeyword({ "inquisitor" }, StdModule.say, { npcHandler = npcHandler, text = "The churches of the gods entrusted me with the enormous and responsible task to lead the inquisition. I leave the field work to inquisitors who I recruit from fitting people that cross my way." })
keywordHandler:addKeyword({ "believer" }, StdModule.say, { npcHandler = npcHandler, text = "Belive on the gods and they will show you the path." })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "By edict of the churches I'm the Lord Inquisitor." })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I'm Henricus, the Lord Inquisitor." })

npcHandler:setMessage(MESSAGE_GREET, "Greetings, fellow {believer} |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Always be on guard, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "This ungraceful haste is most suspicious!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "holy water", clientId = 133, buy = 1000 },
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

-- npcType registering the npcConfig table
npcType:register(npcConfig)
