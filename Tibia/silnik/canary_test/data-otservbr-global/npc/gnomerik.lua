local internalNpcName = "Gnomerik"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 3,
	lookBody = 60,
	lookLegs = 3,
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

keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "Hello and welcome in the gnomish {recruitment} office." }, function(player)
	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 1 then
		player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 3)
	end
end)
keywordHandler:addAliasKeyword({ "hello" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer) == 1 then
		if MsgContains(message, "recruit") or MsgContains(message, "test") or MsgContains(message, "result") then
			npcHandler:say({ "I suggest you relax a bit with a fresh mushroom beer and we can talk after that. ...", "Gnominus... He is the one you need right now, find him." }, npc, creature)
		end
		return
	end

	if MsgContains(message, "recruit") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			npcHandler:sayLocalized("npc.gnomerik.yes_yes_sigh_1", npc, creature)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 3 then
			npcHandler:sayLocalized("npc.gnomerik.we_are_hiring_2", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end

		-- TEST
	elseif MsgContains(message, "test") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if npcHandler:getTopic(playerId) < 1 then
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, 0)
				npcHandler:say({
					"Imagine, during your travels you come upon a rare and unknown mushroom. Would you {A}) note down its specifics and location and look for a gnome to take care of it. ...",
					"Or would you {B}) smash it to an unrecognisable pulp. Or would you {C}) pluck it to take it with you for further examination. Or would you {D}) try to become friends with the mushroom by singing questionable bar-room songs?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 2)
			elseif npcHandler:getTopic(playerId) == 3 then
				npcHandler:say({
					"Imagine you wake up one morning and discover you have forgotten how to knot your shoelaces. Would you {A}) admit defeat and go to bed once more. ...",
					"{B}) look for a gnome that can remind you how to do it. {C}) Despite the risk of injuring yourself, try to figure it out on your own. {D}) Use some pottery instead of shoes.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 4)
			elseif npcHandler:getTopic(playerId) == 5 then
				npcHandler:say({
					"Now let us assume you see a gnome in danger. Would you {A}) not care because you must be imagining things. {B}) Save the gnome despite all odds and risk to your own life. ...",
					"{C}) Inspire the gnome by singing the gnomish national anthem. {D}) Hide and loot his corpse if he dies.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 6)
			elseif npcHandler:getTopic(playerId) == 7 then
				npcHandler:say({
					"Imagine you were participating in a gnome-throwing competition. Would you {A}) do some physical calculations in advance to increase your chances of winning. ...",
					"{B}) throw the gnome as safely as you can to ensure his safety. {C}) Sabotage the throwing gnomes of your competitors. {D}) Never participate in such an abominable competition.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 8)
			elseif npcHandler:getTopic(playerId) == 9 then
				npcHandler:say({
					"Now imagine you were given the order to guard a valuable and unique mushroom. You guard it for days and no one shows up to release you and you grow hungry. ...",
					"Would you {A}) eat your boots. {B}) eat the mushroom. {C}) eat a bit of the mushroom. {D}) stick to your duty and continue starving.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 10)
			elseif npcHandler:getTopic(playerId) == 11 then
				npcHandler:sayLocalized("npc.gnomerik.what_do_you_3", npc, creature)
				npcHandler:setTopic(playerId, 12)
			elseif npcHandler:getTopic(playerId) == 13 then
				npcHandler:say({
					"How many bigfoot does it take to change a light crystal? {A}) Only one since it's a piece of mushroom cake. {B}) Light crystals are delicate products of gnomish science and should only be handled by certified gnomish experts. ...",
					"{C}) Three. One to hold the crystal and two to turn him around. {D}) Five. A light crystal turner, a light crystal picker, a light crystal exchanger, a light crystal changing manager and finally a light crystal changing manager assistant.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 14)
			elseif npcHandler:getTopic(playerId) == 15 then
				npcHandler:say({
					"What is a pollyfluxed quantumresonator? {A}) Something funny. {B}) Something important. {C}) Something to be destroyed. ...",
					"{D}) Sadly I am not a gnome and lack the intelligence and education to know about even the simplest of gnomish inventions.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 16)
			elseif npcHandler:getTopic(playerId) == 17 then
				npcHandler:say({
					"If your mushroom patch is infested with cave worms, would you {A}) place some green light crystals to drive them away. {B}) place some disharmonic crystals to drive them away. ...",
					"{C}) burn everything down. {D}) switch your diet to cave worms.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 18)
			elseif npcHandler:getTopic(playerId) == 19 then
				npcHandler:sayLocalized("npc.gnomerik.what_is_the_4", npc, creature)
				npcHandler:setTopic(playerId, 20)
			elseif npcHandler:getTopic(playerId) == 21 then
				npcHandler:say({
					"On a military campaign what piece of equipment would you need most? ...",
					"Is it {A}) some tasty mushroom beer to keep the morale high. {B}) A large backpack to carry all the loot. {C}) A mighty weapon to vanquish the foes. {D}) Mushroom earplugs to be spared of the cries of agony of your opponents?",
				}, npc, creature)
				npcHandler:setTopic(playerId, 22)
			elseif npcHandler:getTopic(playerId) == 23 then
				npcHandler:sayLocalized("npc.gnomerik.what_comes_first_5", npc, creature)
				npcHandler:setTopic(playerId, 24)
			elseif npcHandler:getTopic(playerId) == 25 then
				npcHandler:sayLocalized("npc.gnomerik.in_case_of_6", npc, creature)
				npcHandler:setTopic(playerId, 26)
			elseif npcHandler:getTopic(playerId) == 27 then
				npcHandler:sayLocalized("npc.gnomerik.the_greatest_disaster_7", npc, creature)
				npcHandler:setTopic(playerId, 28)
			elseif npcHandler:getTopic(playerId) == 29 then
				npcHandler:sayLocalized("npc.gnomerik.what_would_your_8", npc, creature)
				npcHandler:setTopic(playerId, 30)
			elseif npcHandler:getTopic(playerId) == 31 then
				npcHandler:sayLocalized("npc.gnomerik.why_do_you_9", npc, creature)
				npcHandler:setTopic(playerId, 32)
			end
		end
		-- ANSWERS
	elseif message:lower() == "a" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 2 then
					npcHandler:sayLocalized("npc.gnomerik.indeed_an_excellent_10", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 18 then
					npcHandler:sayLocalized("npc.gnomerik.a_well_thought_11", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 20 then
					npcHandler:sayLocalized("npc.gnomerik.ah_we_have_12", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 28 then
					npcHandler:sayLocalized("npc.gnomerik.fear_not_we_13", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 30 then
					npcHandler:sayLocalized("npc.gnomerik.ha_a_krazzelzak_14", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						npcHandler:sayLocalized("npc.gnomerik.wrong_answer_15", npc, creature)
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							npcHandler:sayLocalized("npc.gnomerik.stop_it_the_16", npc, creature)
						end
					end
				end
			end
		end
	elseif message:lower() == "b" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 6 then
					npcHandler:sayLocalized("npc.gnomerik.although_chances_are_17", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 14 then
					npcHandler:sayLocalized("npc.gnomerik.i_knew_this_18", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						npcHandler:sayLocalized("npc.gnomerik.wrong_answer_19", npc, creature)
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							npcHandler:sayLocalized("npc.gnomerik.stop_it_the_20")
						end
					end
				end
			end
		end
	elseif message:lower() == "c" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 4 then
					npcHandler:sayLocalized("npc.gnomerik.thats_the_spirit_21", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 22 then
					npcHandler:sayLocalized("npc.gnomerik.you_have_no_22", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 24 then
					npcHandler:sayLocalized("npc.gnomerik.thats_the_spirit_23", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						npcHandler:sayLocalized("npc.gnomerik.wrong_answer_24", npc, creature)
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							npcHandler:sayLocalized("npc.gnomerik.stop_it_the_25", npc, creature)
						end
					end
				end
			end
		end
	elseif message:lower() == "d" then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 5 then
			if (npcHandler:getTopic(playerId) % 2) == 0 then
				if npcHandler:getTopic(playerId) == 8 then
					npcHandler:sayLocalized("npc.gnomerik.of_course_you_26", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 10 then
					npcHandler:sayLocalized("npc.gnomerik.i_can_only_27", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 12 then
					npcHandler:sayLocalized("npc.gnomerik.oh_you_silver_28", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 16 then
					npcHandler:sayLocalized("npc.gnomerik.how_true_how_29", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 26 then
					npcHandler:sayLocalized("npc.gnomerik.thats_just_what_30", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				elseif npcHandler:getTopic(playerId) == 32 then
					npcHandler:sayLocalized("npc.gnomerik.excellent_well_this_31", npc, creature)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) + 7)
					npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
				else
					if npcHandler:getTopic(playerId) < 33 then
						npcHandler:sayLocalized("npc.gnomerik.wrong_answer_32", npc, creature)
						npcHandler:setTopic(playerId, npcHandler:getTopic(playerId) + 1)
						if npcHandler:getTopic(playerId) >= 33 then
							npcHandler:sayLocalized("npc.gnomerik.stop_it_the_33", npc, creature)
						end
					end
				end
			end
		end
		-- TEST
	elseif MsgContains(message, "result") then
		if npcHandler:getTopic(playerId) == 33 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) < 100 then
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer, 1)
				npcHandler:say({
					"You have failed the test with " .. player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) .. " of 112 possible points. You probably were just too nervous. ...",
					"I suggest you relax a bit with a fresh mushroom beer and we'll start over after that. Gnominus sells some beer. You should find him somewhere in the central chamber.",
				}, npc, creature)
			else
				npcHandler:sayLocalized("npc.gnomerik.you_have_passed_34" .. player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Test) .. " of 112 possible points. Congratulations. You are ready to proceed with the more physical parts of your examination! Go and talk to Gnomespector about it.", npc, creature)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 6)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.gnomerik.excellent_now_let_35", npc, creature)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 5)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello and welcome in the gnomish {recruitment} office.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
