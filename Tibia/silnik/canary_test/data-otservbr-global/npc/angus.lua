local internalNpcName = "Angus"
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
	lookHead = 57,
	lookBody = 132,
	lookLegs = 114,
	lookFeet = 113,
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

	-- Joining
	if MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) < 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_1")
			npcHandler:setTopic(playerId, 1)
		end
		-- The New Frontier Start
	elseif MsgContains(message, "farmine") and player:getStorageValue(TheNewFrontier.Questline) == 14 then
		if player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_2")
			npcHandler:setTopic(playerId, 1)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_3")
			npcHandler:setTopic(playerId, 35)
		end
	elseif MsgContains(message, "bluff") and player:getStorageValue(TheNewFrontier.Mission05.AngusKeyword) == 1 and player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
		if npcHandler:getTopic(playerId) == 1 or npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
				npcHandler:say({
					"Those stories are just amazing! Men with faces on their stomach instead of heads you say? And hens that lay golden eggs? Whereas, most amazing is this fountain of youth you've mentioned! ...",
					"I'll immediately send some of our most dedicated explorers to check those things out!",
				}, npc, creature)
				player:setStorageValue(TheNewFrontier.Mission05.Angus, 3)
			end
		end
	elseif MsgContains(message, "impress") and player:getStorageValue(TheNewFrontier.Mission05.AngusKeyword) == 2 and player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_4")
				player:setStorageValue(TheNewFrontier.Mission05.Angus, 3)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_5")
				player:setStorageValue(TheNewFrontier.Mission05.Angus, 3)
			end
		end
		-- The New Frontier End
		-- Mission Check
	elseif MsgContains(message, "mission") then
		if
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) > 4 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 4 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) < 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 26
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 8 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 8
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 17 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 17
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) == 5 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 5
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_6")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) > 25 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) < 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 35
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 26
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 29 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 29
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 32 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 32
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_7")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) > 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) < 44 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 44
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 35
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 38 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 38
			or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 41 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 41
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_8")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) == 44 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 44 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_9")
			npcHandler:setTopic(playerId, 27)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm) == 46 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 46 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_10")
			npcHandler:setTopic(playerId, 29)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm) == 47 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 47 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_11")
			npcHandler:setTopic(playerId, 30)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress) == 49 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 48 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_12")
			npcHandler:setTopic(playerId, 31)
			-- Spectral stone
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress) == 50 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 50 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_13")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 51)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 51)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone, 1)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 51 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 51 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_14")
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 52)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 52)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 52 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 52 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStone) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_15")
			npcHandler:setTopic(playerId, 32)
			-- Spectral stone
			-- Astral portals
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone) == 55 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 55 then
			npcHandler:say({
				"Both carvings are now charged and harmonised. In theory you should be able to travel in zero time from one base to the other ...",
				"However, you will need to have an orichalcum pearl in your possession to use it as power source. It will be destroyed during the process. I will give you 6 of such pearls and you can buy new ones in our bases ...",
				"In addition, you need to be a premium explorer to use the astral travel. ...",
				"And remember: it's a small teleport for you, but a big teleport for all Tibians! Here is a small present for your efforts!",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheAstralPortals, 56)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 56)
			player:addItem(5021, 6) -- Orichalcum pearl
			player:addItem(9605, 1) -- Crown backpack
			player:addItem(3035, 50) -- 50 Platinum coins
			-- Astral portals
		end
		-- Mission check
		-- Pickaxe mission
	elseif MsgContains(message, "pickaxe") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) < 5 or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) > 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) < 1 or player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) > 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_16")
			npcHandler:setTopic(playerId, 3)
		end
		-- Pickaxe mission
		-- Ice delivery
	elseif MsgContains(message, "ice delivery") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) == 5 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_17")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 7 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_18")
			npcHandler:setTopic(playerId, 5)
		end
		-- Ice delivery
		-- Butterfly hunt
	elseif MsgContains(message, "butterfly hunt") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery) == 8 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_19")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 10 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_20")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 11 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_21")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 12)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 12)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 13 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_22")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 14 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_23")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 15)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 15)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 16 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_24")
			npcHandler:setTopic(playerId, 10)
		end
		-- Butterfly Hunt
		-- Plant Collection
	elseif MsgContains(message, "plant collection") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt) == 17 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_25")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 19 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_26")
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 20 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_27")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 21)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 21)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 22 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_28")
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 23 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_29")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 24)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 24)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 25 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_30")
			npcHandler:setTopic(playerId, 14)
		end
		-- Plant Collection
		-- Lizard Urn
	elseif MsgContains(message, "lizard urn") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection) == 26 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_31")
			npcHandler:setTopic(playerId, 15)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 28 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_32")
			npcHandler:setTopic(playerId, 16)
		end
		-- Lizard Urn
		-- Bonelords
	elseif MsgContains(message, "bonelord secrets") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn) == 29 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 29 then
			npcHandler:say({
				"We want to learn more about the ancient race of bonelords. We believe the black pyramid north east of Darashia was originally built by them ...",
				"We ask you to explore the ruins of the black pyramid and look for any signs that prove our theory. You might probably find some document with the numeric bonelord language ...",
				"That would be sufficient proof. Would you like to accept this mission?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 17)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 31 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_33")
			npcHandler:setTopic(playerId, 18)
		end
		-- Bonelords
		-- Orc Powder
	elseif MsgContains(message, "orc powder") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret) == 32 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_34")
			npcHandler:setTopic(playerId, 19)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 34 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_35")
			npcHandler:setTopic(playerId, 20)
		end
		-- Orc Powder
		-- Elven Poetry
	elseif MsgContains(message, "elven poetry") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder) == 35 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 35 then
			npcHandler:say({
				"Some high ranking members would like to study elven poetry. They want the rare book 'Songs of the Forest' ...",
				"For sure someone in Ab'Dendriel will own a copy. So you would just have to ask around there. Are you willing to accept this mission?",
			}, npc, creature)
			npcHandler:setTopic(player:getId(), 21)
		end
	elseif MsgContains(message, "elven book") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 37 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 36 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_36")
			npcHandler:setTopic(player:getId(), 22)
		end

		-- Elven Poetry
		-- Memory Stone
	elseif MsgContains(message, "memory stone") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry) == 38 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 38 then
			npcHandler:say({
				"We acquired some knowledge about special magic stones. Some lost civilisations used it to store knowledge and lore, just like we use books ...",
				"The wisdom in such stones must be immense, but so are the dangers faced by every person who tries to obtain one...",
				"As far as we know the ruins found in the north-west of Edron were once inhabited by beings who used such stones. Do you have the heart to go there and to get us such a stone?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 23)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 40 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 39 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_37")
			npcHandler:setTopic(playerId, 24)
		end
		-- Memory Stone
		-- Rune Writings
	elseif MsgContains(message, "rune writings") then
		if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone) == 41 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 41 then
			npcHandler:say({
				"We would like to study some ancient runes that were used by the lizard race. We suspect some relation of the lizards to the founders of Ankrahmun ...",
				"Somewhere under the ape infested city of Banuta, one can find dungeons that were once inhabited by lizards...",
				"Look there for an atypical structure that would rather fit to Ankrahmun and its Ankrahmun Tombs. Copy the runes you will find on this structure...",
				"Are you up to that challenge?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings) == 43 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) == 43 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_38")
			npcHandler:setTopic(playerId, 26)
		end
		-- Rune Writings
		-- Answer Yes
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say({
				"Fine, though it takes more then a mere lip service to join our ranks. To prove your dedication to the cause you will have to acquire an item for us ...",
				"The mission should be simple to fulfil. For our excavations we have ordered a sturdy pickaxe in Kazordoon. You would have to seek out this trader Uzgod and get the pickaxe for us ...",
				"Simple enough? Are you interested in this task?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_39")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 1)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(4845, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers, 5)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_40")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 6)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 6)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_41")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4872, 1)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(4837, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 8)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 8)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_42")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheIceDelivery, 6)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 6)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_43")
			npcHandler:setTopic(playerId, 0)
			-- Butterfly Hunt
		elseif npcHandler:getTopic(playerId) == 7 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 9)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 9)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_44")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4863, 1)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(4864, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 11)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 11)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_45")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(4865, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 14)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 14)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_46")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 10 then
			if player:removeItem(4866, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheButterflyHunt, 17)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 17)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_47")
				npcHandler:setTopic(playerId, 0)
			end
			-- Butterfly Hunt
			-- Plant Collection
		elseif npcHandler:getTopic(playerId) == 11 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 18)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 18)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_48")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4867, 1)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:removeItem(4868, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 20)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 20)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_49")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeItem(4869, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 23)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 23)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_50")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 14 then
			if player:removeItem(4870, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ThePlantCollection, 26)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 26)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_51")
				npcHandler:setTopic(playerId, 0)
			end
			-- Plant Collection
			-- Lizard Urn
		elseif npcHandler:getTopic(playerId) == 15 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn, 27)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 27)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ChorurnDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_52")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			if player:removeItem(4847, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheLizardUrn, 29)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 29)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_53")
				npcHandler:setTopic(playerId, 0)
			end
			-- Lizard Urn
			-- Bonelords
		elseif npcHandler:getTopic(playerId) == 17 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret, 30)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 30)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.BonelordsDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_54")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 18 then
			if player:removeItem(173, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheBonelordSecret, 32)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 32)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_55")
				npcHandler:setTopic(playerId, 0)
			end
			-- Bonelords
			-- Orc Powder
		elseif npcHandler:getTopic(playerId) == 19 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder, 33)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 33)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.OrcDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_56")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 20 then
			if player:removeItem(13974, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheOrcPowder, 35)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 35)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_57")
				npcHandler:setTopic(playerId, 0)
			end
			-- Orc Powder
			-- Elven Poetry
		elseif npcHandler:getTopic(playerId) == 21 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry, 36)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 36)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ElvenDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_58")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 22 then
			if player:removeItem(4844, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheElvenPoetry, 38)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 38)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_59")
				npcHandler:setTopic(playerId, 0)
			end
			-- Elven Poetry
			-- Memory Stone
		elseif npcHandler:getTopic(playerId) == 23 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone, 39)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 39)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.MemoryStoneDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_60")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 24 then
			if player:removeItem(4841, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheMemoryStone, 41)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 41)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_61")
				npcHandler:setTopic(playerId, 0)
			end
			-- Memory Stone
			-- Rune Writings
		elseif npcHandler:getTopic(playerId) == 25 then
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings, 42)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 42)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_62")
			npcHandler:setTopic(playerId, 0)
			player:addItem(4842, 1)
		elseif npcHandler:getTopic(playerId) == 26 then
			if player:removeItem(4843, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheRuneWritings, 44)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 44)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_63")
				npcHandler:setTopic(playerId, 0)
			end
			-- Rune Writings
			-- Ectoplasm
		elseif npcHandler:getTopic(playerId) == 27 then
			npcHandler:say({
				"Fine. The society is looking for new means to travel. Some of our most brilliant minds have some theories about astral travel that they want to research further ...",
				"Therefore we need you to collect some ectoplasm from the corpse of a ghost. We will supply you with a collector that you can use on the body of a slain ghost ...",
				"Do you think you are ready for that mission?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 28)
		elseif npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_64")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_65")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm, 45)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 45)
			player:addItem(4852, 1)
		elseif npcHandler:getTopic(playerId) == 29 then
			if player:removeItem(4853, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheEctoplasm, 47)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 47)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_66")
				npcHandler:setTopic(playerId, 0)
			end
			-- Ectoplasm
			-- Spectral Dress
		elseif npcHandler:getTopic(playerId) == 30 then
			npcHandler:say({
				"That is quite courageous. We know, it's much we are asking for. The queen of the banshees lives in the so called Ghostlands, south west of Carlin. It is rumoured that her lair is located in the deepest dungeons beneath that cursed place ...",
				"Any violence will probably be futile, you will have to negotiate with her. Try to get a spectral dress from her. Good luck.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress, 48)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 48)
		elseif npcHandler:getTopic(playerId) == 31 then
			if player:removeItem(4836, 1) then
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralDress, 50)
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 50)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_67")
				npcHandler:setTopic(playerId, 0)
			end
			-- Spectral Dress
			-- Spectral Stone
		elseif npcHandler:getTopic(playerId) == 32 then
			npcHandler:say("Good, just take this spectral essence and use it on the strange carving in this building as well as on the corresponding tile in our base at Northport ...", "As soon as you have charged the portal tiles that way, report about the spectral portals.", npc, creature)
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.TheSpectralStone, 53)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SpectralStoneDoor, 1)
			player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine, 53)
			player:addItem(4840, 1) -- Spectral stone
			-- Spectral Stone
			-- Skull Of Ratha / Giant Smithhammer
		elseif npcHandler:getTopic(playerId) == 33 then
			if player:removeItem(3207, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_69")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.SkullOfRatha.Bag1, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_70")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 34 then
			if player:removeItem(12510, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_71")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.GiantSmithHammer.Hamer, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_72")
				npcHandler:setTopic(playerId, 0)
			end
			-- The New Frontier
		elseif npcHandler:getTopic(playerId) == 35 then
			if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Angus) == 2 and player:removeItem(10011, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_73")
				player:setStorageValue(TheNewFrontier.Mission05.Angus, 1)
				npcHandler:setTopic(playerId, 2)
			end
			-- Explorer Brooch
		elseif npcHandler:getTopic(playerId) == 36 then
			if player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch) == 1 and player:removeItem(4871, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_74")
				player:setStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch, 2)
				npcHandler:setTopic(playerId, 0)
			end
		end
		-- Answer Yes
		-- Answer No
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_75")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_76")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_77")
			npcHandler:setTopic(playerId, 0)
		end
		-- Answer No
		-- Skull Of Ratha / Giant Smithhammer
	elseif MsgContains(message, "skull of ratha") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.SkullOfRatha.Bag1) == 1 then
		npcHandler:say({
			"Ratha was a great explorer and even greater ladies' man. Sadly he never returned from a visit to the amazons. Probably he is dead ...",
			"The society offers a substantial reward for the retrieval of Ratha or his remains. Do you have any news about Ratha?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 33)
	elseif MsgContains(message, "giant smith hammer") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.GiantSmithHammer.Hammer) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_78")
		npcHandler:setTopic(playerId, 34)
		-- Explorer Brooch
	elseif MsgContains(message, "brooch") and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.ExplorerBrooch) == 1 then
		npcHandler:say({
			"Our members travel to far away places and cross dangerous areas, many fall prey to enemies or the land ...",
			"Sometimes the personal explorer brooches can be recovered. That way we learn about the fate of our members ...",
			"We offer a reward for each brooch returned to us. Have you found an explorer brooch?",
		}, npc, creature)
		npcHandler:setTopic(playerId, 36)
	else
		-- The New Frontier
		if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Angus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.angus.say_79")
			player:setStorageValue(TheNewFrontier.Mission05.Angus, 2)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, what can I do for you?")
npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)
npcConfig.shop = {
	{
		itemName = "atlas",
		clientId = 6108,
		buy = 150,
	},
	{
		itemName = "botanist s container",
		clientId = 4867,
		buy = 500,
	},
	{
		itemName = "butterfly conservation kit",
		clientId = 4863,
		buy = 250,
	},
	{
		itemName = "crown backpack",
		clientId = 9605,
		buy = 800,
		storageKey = Storage.Quest.U7_6.ExplorerSociety.TheAstralPortals,
		storageValue = 56,
	},
	{
		itemName = "ectoplasm container",
		clientId = 4852,
		buy = 750,
	},
	{
		itemName = "explorer brooch",
		clientId = 4871,
		sell = 50,
	},
	{
		itemName = "giant smithhammer",
		clientId = 12510,
		sell = 250,
	},
	{
		itemName = "hydra egg",
		clientId = 4839,
		sell = 500,
	},
	{
		itemName = "old parchment",
		clientId = 5956,
		sell = 500,
	},
	{
		itemName = "orichalcum pearl",
		clientId = 5021,
		buy = 80,
	},
	{
		itemName = "skull of ratha",
		clientId = 3207,
		sell = 250,
	},
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
