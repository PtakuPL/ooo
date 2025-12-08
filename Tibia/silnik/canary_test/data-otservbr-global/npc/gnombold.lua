local internalNpcName = "Gnombold"
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
	lookHead = 40,
	lookBody = 81,
	lookLegs = 101,
	lookFeet = 57,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
local levels = { 50, 79 }
npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "job") then
		return npcHandler:sayLocalized("npc.gnombold.im_the_officer_1", npc, creature)
	end

	if MsgContains(message, "gnome") then
		return npcHandler:sayLocalized("npc.gnombold.gnomes_have_lived_2", npc, creature)
	end

	if MsgContains(message, "area") then
		return npcHandler:say({
			"The levels around us are... well, they are strange. We are still not entirely sure how they were created. It seems obvious that they are artificial, but they seem not to be burrowed or the like. ... ",
			"We found strange stone formations that were not found on other layers around the Spike, but there is no clue at all if they are as natural as they look. It seems someone used some geomantic force to move the earth. ...",
			"For what reason this has been done we can't tell as we found no clues of colonisation. ...",
			"There are theories that the caves are some kind of burrow of some extinct creature or even creatures that are still around us, but exist as some form of invisible energy; but those theories are far-fetched and not supported by any discoveries. ...",
			"Be that as it may, whatever those caves were meant for, these days they are crawling with creatures of different kinds and all are hostile towards us. The competition for food is great down here, and everything is seen as prey by the cave dwellers. ...",
			"Some would like to feast on the crystal of the Spike, others would prefer a diet of gnomes. What they have in common is that they are a threat. If we can't keep them under control their constant attacks and raids on the Spike will wear us down. ...",
			"That's where adventurers fit in to save the day. ",
		}, npc, creature)
	end

	if MsgContains(message, "mission") then
		if player:getLevel() > levels[2] then
			npcHandler:sayLocalized("npc.gnombold.sorry_but_no_3", npc, creature)
		else
			npcHandler:sayLocalized("npc.gnombold.i_can_offer_4", npc, creature)
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return npcHandler:sayLocalized("npc.gnombold.what_mission_do_5", npc, creature)
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "charges") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == -1 then
				npcHandler:sayLocalized("npc.gnombold.you_have_not_6", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == 3 then
				npcHandler:sayLocalized("npc.gnombold.you_have_done_7", npc, creature)
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnombold.gnowful_charge_this_8", npc, creature)
			end
		elseif MsgContains(message, "fertilisation") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == -1 then
				npcHandler:sayLocalized("npc.gnombold.you_have_not_9", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == 4 then
				npcHandler:sayLocalized("npc.gnombold.you_have_done_10", npc, creature)
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnombold.gnowful_use_the_11", npc, creature)
			end
		elseif MsgContains(message, "nests") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == -1 then
				npcHandler:sayLocalized("npc.gnombold.you_have_not_12", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == 5 then
				npcHandler:sayLocalized("npc.gnombold.you_have_done_13", npc, creature)
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnombold.gnowful_step_into_14", npc, creature)
			end
		elseif MsgContains(message, "killing") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == -1 then
				npcHandler:sayLocalized("npc.gnombold.you_have_not_15", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == 7 then
				npcHandler:sayLocalized("npc.gnombold.you_have_done_16", npc, creature)
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnombold.gnowful_just_go_17", npc, creature)
			end
		else
			npcHandler:sayLocalized("npc.gnombold.thats_not_a_18", npc, creature)
		end
		talkState[playerId] = nil
		return
	end

	if MsgContains(message, "charges") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_have_19" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_are_20" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == -1 then
			npcHandler:say({ "Our mission for you is to use a magnet on three different monoliths in the cave system here. After the magnet evaporates on the last charge, enter the magnetic extractor here to deliver your charge.", "If you are interested, I can give you some more {information} about it. Are you willing to accept this mission?" }, npc, creature)
			talkState[playerId] = "charges"
		else
			npcHandler:sayLocalized("npc.gnombold.you_have_already_21", npc, creature)
		end
	end

	if talkState[playerId] == "charges" then
		if MsgContains(message, "yes") then
			player:addItem(19207, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main, 0)
			npcHandler:say(
				{ "Gnometastic! Charge this magnet at three monoliths in the cave system. With three charges, the magnet will disintegrate and charge you with its gathered energies. Step on the magnetic extractor here to deliver the charge to us, then report to me.", "If you lose the magnet you'll have to bring your own. Gnomux sells all the equipment that is required for our missions." },
				npc,
				creature
			)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[/////////////
	////FERTILISE////
	///////////////]]
	if MsgContains(message, "fertilise") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_have_22" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_are_23" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == -1 then
			npcHandler:sayLocalized("npc.gnombold.your_mission_would_24", npc, creature)
			talkState[playerId] = "fertilise"
		else
			npcHandler:sayLocalized("npc.gnombold.you_have_already_25", npc, creature)
		end
	end

	if talkState[playerId] == "fertilise" then
		if MsgContains(message, "yes") then
			player:addItem(19214)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main, 0)
			npcHandler:sayLocalized("npc.gnombold.gnometastic_and_here_26", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[//////////////////
	////DESTROY NESTS/////
	////////////////////]]
	if MsgContains(message, "nests") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_have_27" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_are_28" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == -1 then
			npcHandler:sayLocalized("npc.gnombold.our_mission_for_29", npc, creature)
			talkState[playerId] = "nests"
		else
			npcHandler:sayLocalized("npc.gnombold.you_have_already_30", npc, creature)
		end
	end

	if talkState[playerId] == "nests" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main, 0)
			npcHandler:sayLocalized("npc.gnombold.gnometastic_dont_forget_31", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[/////////
	////KILL/////
	///////////]]
	if MsgContains(message, "kill") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_have_32" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnombold.sorry_you_are_33" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == -1 then
			npcHandler:sayLocalized("npc.gnombold.this_mission_will_34", npc, creature)
			talkState[playerId] = "kill"
		else
			npcHandler:sayLocalized("npc.gnombold.you_have_already_35", npc, creature)
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main, 0)
			npcHandler:sayLocalized("npc.gnombold.gnometastic_you_should_36", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hi!")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
