local internalNpcName = "Hairycles"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 117,
	lookHead = 10,
	lookBody = 20,
	lookLegs = 30,
	lookFeet = 40,
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	if Player(creature):getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline) < 12 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh! Hello! Hello! Did not notice!")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Be greeted, friend of the ape people. If you want to {trade}, just ask for my offers. If you are injured, ask for healing.")
	end
	return true
end

local function releasePlayer(npc, creature)
	if not Player(creature) then
		return
	end

	npcHandler:removeInteraction(npc, creature)
	npcHandler:resetNpc(creature)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local questProgress = player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline)
	if MsgContains(message, "mission") then
		if questProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif questProgress == 1 then
			if player:getStorageValue(Storage.Quest.U7_6.WhisperMoss) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_2")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_3")
			end
		elseif questProgress == 2 then
			npcHandler:say({
				"Whisper moss strong is, but me need liquid that humans have to make it work ...",
				"Our raiders brought it from human settlement, it's called cough syrup. Go ask healer there for it.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 3)
		elseif questProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif questProgress == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif questProgress == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_6")
			npcHandler:setTopic(playerId, 7)
		elseif questProgress == 6 then
			npcHandler:say({
				"Ah yes that scroll. Sadly me not could read it yet. But the holy banana me insight gave! In dreams Hairycles saw where to find solution. ...",
				"Me saw a stone with lizard signs and other signs at once. If you read signs and tell Hairycles, me will know how to read signs. ...",
				"You go east to big desert. In desert there city. East of city under sand hidden tomb is. You will have to dig until you find it, so take shovel. ...",
				"Go down in tomb until come to big level and then go down another. There you find a stone with signs between two huge red stones. ...",
				"Read it and return to me. Are you up to that challenge?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 8)
		elseif questProgress == 7 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.ParchmentDecyphering) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_7")
				npcHandler:setTopic(playerId, 9)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_8")
			end
		elseif questProgress == 8 then
			npcHandler:say({
				"So much there is to do for Hairycles to prepare charm that will protect all ape people. ...",
				"You can help more. To create charm of life me need mighty token of life! Best is egg of a regenerating beast as a hydra is. ...",
				"Bring me egg of hydra please. You may find it in lair of Hydra at little lake south east of our lovely city Banuta! You think you can do?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 10)
		elseif questProgress == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_9")
			npcHandler:setTopic(playerId, 11)
		elseif questProgress == 10 then
			npcHandler:say({
				"Last ingredient for charm of life is thing to lure magic. Only thing me know like that is mushroom called witches' cap. Me was told it be found in isle called Fibula, where humans live. ...",
				"Hidden under Fibula is a secret dungeon. There you will find witches' cap. Are you willing to go there for good ape people?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 12)
		elseif questProgress == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_10")
			npcHandler:setTopic(playerId, 13)
		elseif questProgress == 12 then
			npcHandler:say({
				"Mighty life charm is protecting us now! But my people are still in danger. Danger from within. ...",
				"Some of my people try to mimic lizards to become strong. Like lizards did before, this cult drinks strange fluid that lizards left when fled. ...",
				"Under the city still the underground temple of lizards is. There you find casks with red fluid. Take crowbar and destroy three of them to stop this madness. Are you willing to do that?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 14)
		elseif questProgress == 13 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Casks) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_11")
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 14)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_12")
			end
		elseif questProgress == 14 then
			npcHandler:say({
				"Now that the false cult was stopped, we need to strengthen the spirit of my people. We need a symbol of our faith that ape people can see and touch. ...",
				"Since you have proven a friend of the ape people I will grant you permission to enter the forbidden land. ...",
				"To enter the forbidden land in the north-east of the jungle, look for a cave in the mountains east of it. There you will find the blind prophet. ...",
				"Tell him Hairycles you sent and he will grant you entrance. ...",
				"Forbidden land is home of Bong. Holy giant ape big as mountain. Don't annoy him in any way but look for a hair of holy ape. ...",
				"You might find at places he has been, should be easy to see them since Bong is big. ...",
				"Return a hair of the holy ape to me. Will you do this for Hairycles?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 15)
		elseif questProgress == 15 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.HolyApeHair) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_13")
				npcHandler:setTopic(playerId, 16)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_14")
			end
		elseif questProgress == 16 then
			npcHandler:say({
				"You have proven yourself a friend, me will grant you permission to enter the deepest catacombs under Banuta which we have sealed in the past. ...",
				"Me still can sense the evil presence there. We did not dare to go deeper and fight creatures of evil there. ...",
				"You may go there, fight the evil and find the monument of the serpent god and destroy it with hammer me give to you. ...",
				"Only then my people will be safe. Please tell Hairycles, will you go there?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 17)
		elseif questProgress == 17 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.SnakeDestroyer) == 1 then
				npcHandler:say({
					"Finally my people are safe! You have done incredible good for ape people and one day even me brethren will recognise that. ...",
					"I wish I could speak for all when me call you true friend but my people need time to get accustomed to change. ...",
					"Let us hope one day whole Banuta will greet you as a friend. Perhaps you want to check me offers for special friends... or shamanic powers.",
				}, npc, creature)
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 18)
				player:addAchievement("Friend of the Apes")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_15")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_16")
		end
	elseif MsgContains(message, "background") then
		if questProgress == 1 and player:getStorageValue(Storage.Quest.U7_6.WhisperMoss) ~= 1 then
			npcHandler:say({
				"So listen, little ape was struck by plague. Hairycles not does know what plague it is. That is strange. Hairycles should know. But Hairycles learnt lots and lots ...",
				"Me sure to make cure so strong to drive away all plague. But to create great cure me need powerful components ...",
				"Me need whisper moss. Whisper moss growing south of human settlement is. Problem is, evil little dworcs harvest all whisper moss immediately ...",
				"Me know they hoard some in their underground lair. My people raided dworcs often before humans came. So we know the moss is hidden in east of upper level of dworc lair ...",
				"You go there and take good moss from evil dworcs. Talk with me about mission when having moss.",
			}, npc, creature)
		end
	elseif MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Hairycles) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_17")
			npcHandler:setTopic(playerId, 19)
		end
	elseif MsgContains(message, "outfit") or MsgContains(message, "shamanic") then
		if questProgress == 18 then
			if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.ShamanOutfit) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_18")
				npcHandler:setTopic(playerId, 18)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_19")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_20")
		end
	elseif MsgContains(message, "heal") then
		if questProgress > 11 then
			if player:getHealth() < 50 then
				player:addHealth(50 - player:getHealth())
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			elseif player:getCondition(CONDITION_FIRE) then
				player:removeCondition(CONDITION_FIRE)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			elseif player:getCondition(CONDITION_POISON) then
				player:removeCondition(CONDITION_POISON)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_21")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_22")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_23")
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_24")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			npcHandler:say({
				"So listen, little ape was struck by plague. Hairycles not does know what plague it is. That is strange. Hairycles should know. But Hairycles learnt lots and lots ...",
				"Me sure to make cure so strong to drive away all plague. But to create great cure me need powerful components ...",
				"Me need whisper moss. Whisper moss growing south of human settlement is. Problem is, evil little dworcs harvest all whisper moss immediately ...",
				"Me know they hoard some in their underground lair. My people raided dworcs often before humans came. So we know the moss is hidden in east of upper level of dworc lair ...",
				"You go there and take good moss from evil dworcs. Talk with me about mission when having moss.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Started, 1)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 1)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.DworcDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_25")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4827, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_26")
				player:setStorageValue(Storage.Quest.U7_6.WhisperMoss, -1)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_27")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_28")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 4 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4828, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_29")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_30")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 4)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_31")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			npcHandler:say({
				"So listen, please. Plague was not ordinary plague. That's why Hairycles could not heal at first. It is new curse of evil lizard people ...",
				"I think curse on little one was only a try. We have to be prepared for big strike ...",
				"Me need papers of lizard magician! For sure you find it in his hut in their dwelling. It's south east of jungle. Go look there please! Are you willing to go?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 6)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_32")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_33")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 5)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.ChorDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_34")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4831, 1) then
				if player:getStorageValue(Storage.Quest.U7_6.OldParchment) == 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_35")
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_36")
				end
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_37")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 6)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_38")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_39")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 7)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_40")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 9 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_41")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 8)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_42")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 10 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_43")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 9)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_44")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 11 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4839, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_45")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_46")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 10)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_47")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 12 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_48")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 11)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.FibulaDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_49")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 13 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4829, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_50")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_51")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 12)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.FibulaDoor, -1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_52")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 14 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_53")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 13)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.CasksDoor, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_54")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_55")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 15)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_56")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "yes") then
			if not player:removeItem(4832, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_57")
				player:setStorageValue(Storage.Quest.U7_6.TheApeCity.HolyApeHair, -1)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_58")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 16)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_59")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 17 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_60")
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.Questline, 17)
			player:addItem(4835, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_61")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_62")
			player:addOutfit(154)
			player:addOutfit(158)
			player:setStorageValue(Storage.Quest.U7_6.TheApeCity.ShamanOutfit, 1)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_63")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if MsgContains(message, "yes") then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_64")
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.Hairycles, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end

			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_65")
			addEvent(function()
				releasePlayer(npc, creature)
			end, 1000)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hairycles.say_66")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "busy" }, StdModule.say, { npcHandler = npcHandler, text = "Me great {wizard}. Me great doctor of {ape people}. Me know many plants. Me old and me have seen many things." })
keywordHandler:addKeyword({ "wizard" }, StdModule.say, { npcHandler = npcHandler, text = "We see many things and learning quick. Merlkin magic learn quick, quick. We just watch and learn. Sometimes we try and learn." })
keywordHandler:addKeyword({ "things" }, StdModule.say, { npcHandler = npcHandler, text = "Things not good now. Need helper to do {mission} for me people." })
keywordHandler:addKeyword({ "ape people" }, StdModule.say, { npcHandler = npcHandler, text = "We be {kongra}, {sibang} and {merlkin}. Strange hairless ape people live in city called Port Hope." })
keywordHandler:addKeyword({ "kongra" }, StdModule.say, { npcHandler = npcHandler, text = "Kongra verry strong. Kongra verry angry verry fast. Take care when kongra comes. Better climb on highest tree." })
keywordHandler:addKeyword({ "sibang" }, StdModule.say, { npcHandler = npcHandler, text = "Sibang verry fast and funny. Sibang good gather food. Sibang know {jungle} well." })
keywordHandler:addKeyword({ "merlkin" }, StdModule.say, { npcHandler = npcHandler, text = "Merlkin we are. Merlkin verry wise, merlkin learn many things quick. Teach other apes things a lot. Making {heal} and making {magic}." })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, text = "We see many things and learning quick. Merlkin magic learn quick, quick. We just watch and learn. Sometimes we try and learn." })
keywordHandler:addKeyword({ "jungle" }, StdModule.say, { npcHandler = npcHandler, text = "Jungle is dangerous. Jungle also provides us food. Take care when in jungle and safe you be." })

local function onTradeRequest(npc, creature)
	if Player(creature):getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline) < 18 then
		return false
	end

	return true
end

npcHandler:setCallback(CALLBACK_ON_TRADE_REQUEST, onTradeRequest)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "banana", clientId = 3587, buy = 2 },
	{ itemName = "monkey statue 'hear' kit", clientId = 5055, buy = 65 },
	{ itemName = "monkey statue 'see' kit", clientId = 5046, buy = 65 },
	{ itemName = "monkey statue 'speak' kit", clientId = 5056, buy = 65 },
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
