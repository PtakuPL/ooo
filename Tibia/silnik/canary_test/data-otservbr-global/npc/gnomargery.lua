local internalNpcName = "Gnomargery"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 507,
	lookHead = 96,
	lookBody = 92,
	lookLegs = 96,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
local level = 80
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
		return npcHandler:sayLocalized("npc.gnomargery.im_the_officer_1", npc, creature)
	end

	if MsgContains(message, "gnome") then
		return npcHandler:sayLocalized("npc.gnomargery.its_good_to_2", npc, creature)
	end

	if MsgContains(message, "area") then
		return npcHandler:say({
			"On the levels outside, we encountered the first serious resistance of our true enemy. As evidenced by the unnatural heat in an area with little volcanic activity, there is 'something' strange going on here. ...",
			"Even the lava pools we have found here are not actually lava, but rock that was molten pretty much recently without any reasonable connection to some natural heat source. And for all we can tell, the heat is growing, slowly but steadily. ...",
			"This is the first time ever that we can witness our enemy at work. Here we can learn a lot about its operations. ...",
			"How they work, and possibly how to stop them. But therefore expeditions into the depths are necessary. The areas around us are highly dangerous, and a lethal threat to us and the Spike as a whole. ... ",
			"Our first object is to divert the forces of the enemy and weaken them as good as we can while gathering as much information as possible about them and their movements. Only highly skilled adventurers stand a chance to help us down here. ...",
		}, npc, creature)
	end

	if MsgContains(message, "spike") then
		return npcHandler:sayLocalized("npc.gnomargery.now_thats_gnomish_3", npc, creature)
	end

	if MsgContains(message, "mission") then
		if player:getLevel() < level then
			npcHandler:sayLocalized("npc.gnomargery.sorry_but_no_4", npc, creature)
		else
			npcHandler:sayLocalized("npc.gnomargery.i_can_offer_5", npc, creature)
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return npcHandler:sayLocalized("npc.gnomargery.what_mission_do_6", npc, creature)
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "delivery") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_not_7", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == 4 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_done_8", npc, creature)
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomargery.gnowful_deliver_the_9", npc, creature)
			end
		elseif MsgContains(message, "undercover") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_not_10", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == 3 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_done_11", npc, creature)
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomargery.gnowful_get_three_12", npc, creature)
			end
		elseif MsgContains(message, "temperature") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_not_13", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == 1 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_done_14", npc, creature)
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomargery.gnowful_use_the_15", npc, creature)
			end
		elseif MsgContains(message, "kill") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_not_16", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == 7 then
				npcHandler:sayLocalized("npc.gnomargery.you_have_done_17", npc, creature)
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomargery.gnowful_just_go_18", npc, creature)
			end
		else
			npcHandler:sayLocalized("npc.gnomargery.thats_not_a_19", npc, creature)
		end
		talkState[playerId] = nil
		return
	end

	--[[///////////////////
	////PARCEL DELIVERY////
	/////////////////////]]
	if MsgContains(message, "deliver") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_have_20" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if player:getLevel() < level then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_are_21" .. level .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomargery.we_need_someone_22", npc, creature)
			talkState[playerId] = "delivery"
		else
			npcHandler:sayLocalized("npc.gnomargery.you_have_already_23", npc, creature)
		end
	end

	if talkState[playerId] == "delivery" then
		if MsgContains(message, "yes") then
			player:addItem(19219, 4)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main, 0)
			npcHandler:say({ "Gnometastic! Here are the parcels. Regrettably, the labels got lost during transport; but I guess those lonely gnomes won't mind as long as they get ANY parcel at all.", "If you lose the parcels, you'll have to get new ones. Gnomux sells all the equipment that is required for our missions." }, npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[//////////////
	////UNDERCOVER////
	////////////////]]
	if MsgContains(message, "undercover") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_have_24" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if player:getLevel() < level then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_are_25" .. level .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomargery.someone_is_needed_26", npc, creature)
			talkState[playerId] = "undercover"
		else
			npcHandler:sayLocalized("npc.gnomargery.you_have_already_27", npc, creature)
		end
	end

	if talkState[playerId] == "undercover" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main, 0)
			npcHandler:sayLocalized("npc.gnomargery.gnometastic_get_three_28", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[////////////////
	////TEMPERATURE/////
	//////////////////]]
	if MsgContains(message, "temperature") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_have_29" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if player:getLevel() < level then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_are_30" .. level .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomargery.your_task_would_31", npc, creature)
			talkState[playerId] = "temperature"
		else
			npcHandler:sayLocalized("npc.gnomargery.you_have_already_32", npc, creature)
		end
	end

	if talkState[playerId] == "temperature" then
		if MsgContains(message, "yes") then
			player:addItem(19206, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main, 0)
			npcHandler:sayLocalized("npc.gnomargery.gnometastic_find_the_33", npc, creature)
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
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_have_34" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if player:getLevel() < level then
			return npcHandler:sayLocalized("npc.gnomargery.sorry_you_are_35" .. level .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomargery.this_mission_will_36", npc, creature)
			talkState[playerId] = "kill"
		else
			npcHandler:sayLocalized("npc.gnomargery.you_have_already_37", npc, creature)
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main, 0)
			npcHandler:sayLocalized("npc.gnomargery.gnometastic_you_should_38", npc, creature)
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
