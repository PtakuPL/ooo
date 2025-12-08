local internalNpcName = "Myra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 138,
	lookHead = 58,
	lookBody = 19,
	lookLegs = 0,
	lookFeet = 132,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "outfit") then
		npcHandler:sayLocalized("npc.myra.this_tiara_is_1", npc, creature)
		npcHandler:setTopic(playerId, 100)
	elseif MsgContains(message, "tiara") and player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) < 1 then
		if npcHandler:getTopic(playerId) ~= 100 then
			npcHandler:sayLocalized("npc.myra.please_ask_about_2", npc, creature)
		else
			local storageValue = player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak)
			if storageValue == -1 then
				npcHandler:sayLocalized("npc.myra.well_maybe_if_3", npc, creature)
				npcHandler:setTopic(playerId, 1)
			elseif storageValue > 0 and storageValue < 10 then
				npcHandler:sayLocalized("npc.myra.before_i_can_4", npc, creature)
			elseif storageValue == 10 then
				npcHandler:sayLocalized("npc.myra.go_to_the_5", npc, creature)
			elseif storageValue == 11 then
				npcHandler:sayLocalized("npc.myra.i_dont_have_6", npc, creature)
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			npcHandler:say({
				"Okay, great! You see, I need a few magical ingredients which I've run out of. First of all, please bring me 70 bat wings. ...",
				"Then, I urgently need a lot of red cloth. I think 20 pieces should suffice. ...",
				"Oh, and also, I could use a whole load of ape fur. Please bring me 40 pieces. ...",
				"After that, um, let me think... I'd like to have some holy orchids. Or no, many holy orchids, to be safe. Like 35. ...",
				"Then, 10 spools of spider silk yarn, 60 lizard scales and 40 red dragon scales. ...",
				"I know I'm forgetting something.. wait... ah yes, 15 ounces of magic sulphur and 30 ounces of vampire dust. ...",
				"That's it already! Easy task, isn't it? I'm sure you could get all of that within a short time. ...",
				"Did you understand everything I told you and are willing to handle this task?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.thats_a_pity_7", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			npcHandler:sayLocalized("npc.myra.fine_lets_start_8", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 1)
			player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 1)
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_9", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "task") then
		local tasks = {
			[1] = "Your current task is to bring me 70 bat wings, |PLAYERNAME|.",
			[2] = "Your current task is to bring me 20 pieces of red cloth, |PLAYERNAME|.",
			[3] = "Your current task is to bring me 40 pieces of ape fur, |PLAYERNAME|.",
			[4] = "Your current task is to bring me 35 holy orchids, |PLAYERNAME|.",
			[5] = "Your current task is to bring me 10 spools of spider silk yarn, |PLAYERNAME|.",
			[6] = "Your current task is to bring me 60 lizard scales, |PLAYERNAME|.",
			[7] = "Your current task is to bring me 40 red dragon scales, |PLAYERNAME|.",
			[8] = "Your current task is to bring me 15 ounces of magic sulphur, |PLAYERNAME|.",
			[9] = "Your current task is to bring me 30 ounces of vampire dust, |PLAYERNAME|.",
			[10] = "Go to the academy in Edron and tell Zoltan that I sent you, |PLAYERNAME|.",
			[11] = "I don't have any tasks for you right now, |PLAYERNAME|. You were of great help.",
		}
		local taskMessage = tasks[player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak)]
		if taskMessage then
			npcHandler:say(taskMessage, npc, creature)
		end
	elseif MsgContains(message, "bat wing") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 1 then
			npcHandler:sayLocalized("npc.myra.oh_did_you_10", npc, creature)
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "red cloth") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 2 then
			npcHandler:sayLocalized("npc.myra.have_you_found_11", npc, creature)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "ape fur") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 3 then
			npcHandler:sayLocalized("npc.myra.were_you_able_12", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "holy orchid") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 4 then
			npcHandler:sayLocalized("npc.myra.did_you_convince_13", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "spider silk") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 5 then
			npcHandler:sayLocalized("npc.myra.oh_did_you_14", npc, creature)
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "lizard scale") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 6 then
			npcHandler:sayLocalized("npc.myra.have_you_found_15", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "red dragon scale") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 7 then
			npcHandler:sayLocalized("npc.myra.were_you_able_16", npc, creature)
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "magic sulphur") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 8 then
			npcHandler:sayLocalized("npc.myra.have_you_collected_17", npc, creature)
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "vampire dust") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 9 then
			npcHandler:sayLocalized("npc.myra.have_you_gathered_18", npc, creature)
			npcHandler:setTopic(playerId, 11)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5894) < 70 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_19", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.thank_you_i_20", npc, creature)
				player:removeItem(5894, 70)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 2)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 2)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_21", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 4 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5911) < 20 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_22", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.great_this_should_23", npc, creature)
				player:removeItem(5911, 20)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 3)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 3)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_24", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5883) < 40 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_25", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.nice_job_player_26", npc, creature)
				player:removeItem(5883, 40)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 4)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 4)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_27", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5922) < 35 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_28", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.thank_god_the_29", npc, creature)
				player:removeItem(5922, 35)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 5)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 5)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_30", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5886) < 10 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_31", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.i_appreciate_it_32", npc, creature)
				player:removeItem(5886, 10)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 6)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 6)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_33", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5881) < 60 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_34", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.good_job_they_35", npc, creature)
				player:removeItem(5881, 60)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 7)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 7)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_36", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 9 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5882) < 40 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_37", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.thanks_they_make_38", npc, creature)
				player:removeItem(5882, 40)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 8)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 8)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_39", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 10 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5904) < 15 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_40", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.ah_thats_enough_41", npc, creature)
				player:removeItem(5904, 15)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 9)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 9)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_42", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 11 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5905) < 30 then
				npcHandler:sayLocalized("npc.myra.no_no_thats_43", npc, creature)
			else
				npcHandler:sayLocalized("npc.myra.ah_great_now_44", npc, creature)
				player:removeItem(5905, 30)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak, 10)
				player:setStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.MissionHatCloak, 10)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("npc.myra.would_you_like_45", npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "addon") then
		if player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 10 then
			npcHandler:sayLocalized("npc.myra.this_tiara_is_46", npc, creature)
			npcHandler:setTopic(playerId, 12)
		end
	elseif npcHandler:getTopic(playerId) == 12 then
		if MsgContains(message, "tiara") and player:getStorageValue(Storage.Quest.U7_8.MageAndSummonerOutfits.AddonHatCloak) == 10 then
			npcHandler:sayLocalized("npc.myra.go_to_the_47", npc, creature)
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|. If you are looking for sorcerer {spells} don't hesitate to ask.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Farewell.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
