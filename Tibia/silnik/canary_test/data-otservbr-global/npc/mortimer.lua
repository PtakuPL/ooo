local internalNpcName = "Mortimer"
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
	lookHead = 0,
	lookBody = 115,
	lookLegs = 102,
	lookFeet = 95,
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- JOINING
	if MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) < 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_1")
			npcHandler:setTopic(playerId, 1)
		end
		--The New Frontier
	elseif MsgContains(message, "farmine") then
		if player:getStorageValue(TheNewFrontier.Questline) <= 15 and player:getStorageValue(TheNewFrontier.BribeExplorerSociety) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_2")
			npcHandler:setTopic(playerId, 30)
		end
	elseif MsgContains(message, "bluff") then
		if npcHandler:getTopic(playerId) == 30 then
			if player:getStorageValue(TheNewFrontier.BribeExplorerSociety) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_59")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_60")
				player:setStorageValue(TheNewFrontier.BribeExplorerSociety, 1)
				--Questlog, The New Frontier Quest "Mission 05: Getting Things Busy"
				player:setStorageValue(TheNewFrontier.Mission05[1], player:getStorageValue(TheNewFrontier.Mission05[1]) + 1)
			end
		end

		-- MISSION CHECK
	elseif MsgContains(message, "mission") then
		if
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) > 4 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 4 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) < 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 26
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 8 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 8
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 17 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 17
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) == 5 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 5
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) > 25 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) < 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 35
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 26
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 29 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 29
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 32 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 32
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_4")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) > 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) < 44 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 44
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 35
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 38 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 38
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 41 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 41
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) == 44 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 44 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_6")
			npcHandler:setTopic(playerId, 27)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm) == 46 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 46 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_7")
			npcHandler:setTopic(playerId, 29)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm) == 47 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 47 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_57")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_58")
			npcHandler:setTopic(playerId, 30)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress) == 49 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 48 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_8")
			npcHandler:setTopic(playerId, 31)
			-- SPECTRAL STONE
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress) == 50 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 50 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_55")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_56")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 51)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 51)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone, 2)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 51 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 51 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_9")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 52)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 52)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 52 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 52 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_10")
			npcHandler:setTopic(playerId, 32)
			-- SPECTRAL STONE
			-- ASTRAL PORTALS
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 55 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 55 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_52")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_54")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheAstralPortals, 56)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 56)
			player:addItem(5021, 6) -- Orichalcum pearl
			player:addItem(9605, 1) -- Crown backpack
			player:addItem(3035, 50) -- 50 Platinum coins
			-- ASTRAL PORTALS
		end
		-- MISSION CHECK

		-- PICKAXE MISSION
	elseif MsgContains(message, "pickaxe") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) < 5 or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) > 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 1 or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_11")
			npcHandler:setTopic(playerId, 3)
		end
		-- PICKAXE MISSION

		-- ICE DELIVERY
	elseif MsgContains(message, "ice delivery") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) == 5 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_48")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_49")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_50")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 7 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_12")
			npcHandler:setTopic(playerId, 5)
		end
		-- ICE DELIVERY

		-- BUTTERFLY HUNT
	elseif MsgContains(message, "butterfly hunt") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 8 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_13")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 10 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_14")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 11 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_47")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 12)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 12)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 13 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_15")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 14 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_45")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 15)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 15)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 16 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_16")
			npcHandler:setTopic(playerId, 10)
		end
		-- BUTTERFLY HUNT
		-- PLANT COLLECTION
	elseif MsgContains(message, "plant collection") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 17 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_17")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 119 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_18")
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 20 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_19")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 21)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 21)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 22 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_20")
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 23 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_21")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 24)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 24)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 25 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_22")
			npcHandler:setTopic(playerId, 14)
		end
		-- PLANT COLLECTION

		-- LIZARD URN
	elseif MsgContains(message, "lizard urn") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_23")
			npcHandler:setTopic(playerId, 15)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 28 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_24")
			npcHandler:setTopic(playerId, 16)
		end
		-- LIZARD URN

		-- BONELORDS
	elseif MsgContains(message, "bonelord secrets") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 29 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_41")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_43")
			npcHandler:setTopic(playerId, 17)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 31 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_25")
			npcHandler:setTopic(playerId, 18)
		end
		-- BONELORDS

		-- ORC POWDER
	elseif MsgContains(message, "orc powder") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 32 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_40")
			npcHandler:setTopic(playerId, 19)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_26")
			npcHandler:setTopic(playerId, 20)
		end
		-- ORC POWDER

		-- ELVEN POETRY
	elseif MsgContains(message, "elven poetry") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 35 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_37")
			npcHandler:setTopic(playerId, 21)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 37 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 36 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_27")
			npcHandler:setTopic(playerId, 22)
		end
		-- ELVEN POETRY

		-- MEMORY STONE
	elseif MsgContains(message, "memory stone") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 38 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 38 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_35")
			npcHandler:setTopic(playerId, 23)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 40 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 39 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_28")
			npcHandler:setTopic(playerId, 24)
		end
		-- MEMORY STONE

		-- RUNE WRITINGS
	elseif MsgContains(message, "rune writings") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 41 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 41 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_32")
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) == 43 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 43 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_29")
			npcHandler:setTopic(playerId, 26)
		end
		-- RUNE WRITINGS

		-- ANSWER YES
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_28")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_30")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 1)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(4845, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers, 5)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_24")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_25")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 5)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 5)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_23")
			npcHandler:setTopic(playerId, 0)
			player:addItem(3456, 1)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(4837, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 7)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 7)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_31")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 5)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 5)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_32")
			npcHandler:setTopic(playerId, 0)

			-- BUTTERFLY HUNT
		elseif npcHandler:getTopic(playerId) == 7 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 8)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 8)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_21")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(4864, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 10)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 10)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_33")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(4865, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 13)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 13)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_34")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 10 then
			if player:removeItem(4866, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 16)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 16)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_35")
				npcHandler:setTopic(playerId, 0)
			end
			-- BUTTERFLY HUNT

			-- PLANT COLLECTION
		elseif npcHandler:getTopic(playerId) == 11 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 17)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 17)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_36")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:removeItem(4868, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 19)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 19)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_37")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeItem(4869, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 22)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 22)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_38")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 14 then
			if player:removeItem(4870, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 26)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 26)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_39")
				npcHandler:setTopic(playerId, 0)
			end
			-- PLANT COLLECTION

			-- LIZARD URN
		elseif npcHandler:getTopic(playerId) == 15 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn, 27)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 27)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ChorurnDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_19")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			if player:removeItem(4847, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn, 29)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 29)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_40")
				npcHandler:setTopic(playerId, 0)
			end
			-- LIZARD URN

			-- BONELORDS
		elseif npcHandler:getTopic(playerId) == 17 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret, 30)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 30)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.BonelordsDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_16")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 18 then
			if player:removeItem(173, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret, 32)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 32)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_41")
				npcHandler:setTopic(playerId, 0)
			end
			-- BONELORDS

			-- ORC POWDER
		elseif npcHandler:getTopic(playerId) == 19 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder, 33)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 33)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.OrcDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_14")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 20 then
			if player:removeItem(13974, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder, 35)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 35)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_42")
				npcHandler:setTopic(playerId, 0)
			end
			-- ORC POWDER

			-- ELVEN POETRY
		elseif npcHandler:getTopic(playerId) == 21 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry, 36)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 36)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ElvenDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_43")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 22 then
			if player:removeItem(4844, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry, 38)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 38)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_44")
				npcHandler:setTopic(playerId, 0)
			end
			-- ELVEN POETRY

			-- MEMORY STONE
		elseif npcHandler:getTopic(playerId) == 23 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone, 39)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 39)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.MemoryStoneDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_45")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 24 then
			if player:removeItem(4841, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone, 41)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 41)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_46")
				npcHandler:setTopic(playerId, 0)
			end
			-- MEMORY STONE

			-- RUNE WRITINGS
		elseif npcHandler:getTopic(playerId) == 25 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings, 42)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 42)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_47")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4842, 1)
		elseif npcHandler:getTopic(playerId) == 26 then
			if player:removeItem(4843, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings, 44)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 44)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_48")
				npcHandler:setTopic(playerId, 0)
			end
			-- RUNE WRITINGS

			-- ECTOPLASM
		elseif npcHandler:getTopic(playerId) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_12")
			npcHandler:setTopic(playerId, 28)
		elseif npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_49")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_50")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm, 45)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 45)
			player:addItem(4852, 1)
		elseif npcHandler:getTopic(playerId) == 29 then
			if player:removeItem(4853, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm, 47)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 47)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_51")
				npcHandler:setTopic(playerId, 0)
			end
			-- ECTOPLASM

			-- SPECTRAL DRESS
		elseif npcHandler:getTopic(playerId) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_9")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress, 48)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 48)
		elseif npcHandler:getTopic(playerId) == 31 then
			if player:removeItem(4836, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress, 50)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 50)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_52")
				npcHandler:setTopic(playerId, 0)
			end
			-- SPECTRAL DRESS

			-- SPECTRAL STONE
		elseif npcHandler:getTopic(playerId) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_7")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 53)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStoneDoor, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 53)
			player:addItem(4840, 1) -- spectral stone
			-- SPECTRAL STONE

			-- SKULL OF RATHA / GIANT SMITHHAMMER
		elseif npcHandler:getTopic(playerId) == 33 then
			if player:removeItem(3207, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_53")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SkullOfRatha.Bag1, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_54")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 34 then
			if player:removeItem(12510, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_55")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.GiantSmithHammer.Hamer, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_56")
				npcHandler:setTopic(playerId, 0)
			end
			-- SKULL OF RATHA / GIANT SMITHHAMMER
		elseif npcHandler:getTopic(playerId) == 35 then
			if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch) == 1 and player:removeItem(4871, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_57")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch, 2)
				npcHandler:setTopic(playerId, 0)
			end
		end
		-- ANSWER YES

		-- ANSWER NO
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_58")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_59")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_60")
			npcHandler:setTopic(playerId, 0)
		end
		-- ANSWER NO

		-- SKULL OF RATHA / GIANT SMITHHAMMER
	elseif MsgContains(message, "skull of ratha") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SkullOfRatha.Bag1) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_5")
		npcHandler:setTopic(playerId, 33)
	elseif MsgContains(message, "giant smith hammer") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.GiantSmithHammer.Hammer) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.say_61")
		npcHandler:setTopic(playerId, 34)
		-- Explorer Brooch
	elseif MsgContains(message, "brooch") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mortimer.multi_3")
		npcHandler:setTopic(playerId, 35)
	end

	return true
end

local function onTradeRequest(npc, creature)
	if Player(creature):getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheAstralPortals) ~= 56 then
		return false
	end

	return true
end

npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "atlas", clientId = 6108, buy = 150 },
	{ itemName = "botanist's container", clientId = 4867, buy = 500 },
	{ itemName = "butterfly conservation kit", clientId = 4863, buy = 250 },
	{ itemName = "crown backpack", clientId = 9605, buy = 800 },
	{ itemName = "ectoplasm container", clientId = 4852, buy = 750 },
	{ itemName = "explorer brooch", clientId = 4871, sell = 50 },
	{ itemName = "giant smithhammer", clientId = 12510, sell = 250 },
	{ itemName = "hydra egg", clientId = 4839, sell = 500 },
	{ itemName = "old parchment", clientId = 4831, sell = 500 },
	{ itemName = "orichalcum pearl", clientId = 5021, buy = 80 },
	{ itemName = "skull of Ratha", clientId = 3207, sell = 250 },
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
