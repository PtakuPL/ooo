local internalNpcName = "Gnomilly"
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
	lookHead = 14,
	lookBody = 15,
	lookLegs = 91,
	lookFeet = 92,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

local talkState = {}
local levels = { 25, 49 }
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
		return npcHandler:sayLocalized("npc.gnomilly.im_the_officer_1", npc, creature)
	end

	if MsgContains(message, "gnome") then
		return npcHandler:sayLocalized("npc.gnomilly.we_are_the_2", npc, creature)
	end

	if MsgContains(message, "area") then
		return npcHandler:say({
			"On these levels we found evidence of some monumental battle that has taken place here centuries ago. We also found some grave sites, but oddly enough no clues of any form of settlement. ...",
			"Some evidence we have found suggests that at least one of the battles here was fought for many, many years. People came here, lived here, fought here and died here. ...",
			"The battles continued until someone or something literally ploughed through the battlefields, turning everything upside down. All this killing and death soaked the area with negative energy. ...",
			"Necromantic forces are running wild all over the place and we are hard-pressed to drive all these undead, spirits and ghosts, away from the Spike. ...",
			"Unless we can secure that area somehow, the Spike operation is threatened to become crippled by the constant attacks of the undead. ...",
			"The whole growing downwards could come to a halt, leaving us exposed to even more attacks, counter attacks, and giving the enemy time to prepare their defences. There's a lot to do for aspiring adventurers.",
		}, npc, creature)
	end

	if MsgContains(message, "mission") then
		if player:getLevel() > levels[2] then
			npcHandler:sayLocalized("npc.gnomilly.sorry_but_no_3", npc, creature)
		else
			npcHandler:sayLocalized("npc.gnomilly.i_can_offer_4", npc, creature)
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return npcHandler:sayLocalized("npc.gnomilly.what_mission_do_5", npc, creature)
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "pacifiers") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_not_6", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == 7 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_done_7", npc, creature)
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomilly.gnowful_take_the_8", npc, creature)
			end
		elseif MsgContains(message, "release") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_not_9", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == 1 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_done_10", npc, creature)
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomilly.gnowful_take_the_11", npc, creature)
			end
		elseif MsgContains(message, "tracking") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_not_12", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == 3 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_done_13", npc, creature)
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomilly.gnowful_take_the_14", npc, creature)
			end
		elseif MsgContains(message, "killing") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == -1 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_not_15", npc, creature)
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == 7 then
				npcHandler:sayLocalized("npc.gnomilly.you_have_done_16", npc, creature)
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily, os.time() + 72000)
			else
				npcHandler:sayLocalized("npc.gnomilly.gnowful_just_go_17", npc, creature)
			end
		else
			npcHandler:sayLocalized("npc.gnomilly.thats_not_a_18", npc, creature)
		end
		talkState[playerId] = nil
		return
	end

	--[[///////////////////
	////GHOST PACIFIERS////
	/////////////////////]]
	if MsgContains(message, "pacifiers") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_have_19" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_are_20" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == -1 then
			npcHandler:say({ "We need you to recharge our ghost pacifiers. They are placed at several strategic points in the caves around us and should be easy to find. Your mission would be to charge seven of them.", "If you are interested, I can give you some more {information} about it. Are you willing to accept this mission?" }, npc, creature)
			talkState[playerId] = "pacifiers"
		else
			npcHandler:sayLocalized("npc.gnomilly.you_have_already_21", npc, creature)
		end
	end

	if talkState[playerId] == "pacifiers" then
		if MsgContains(message, "yes") then
			player:addItem(19204, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main, 0)
			npcHandler:sayLocalized("npc.gnomilly.gnometastic_take_this_22", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[///////////////////
	////SPIRIT RELEASE/////
	/////////////////////]]
	if MsgContains(message, "release") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_have_23" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_are_24" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomilly.your_task_would_25", npc, creature)
			talkState[playerId] = "release"
		else
			npcHandler:sayLocalized("npc.gnomilly.you_have_already_26", npc, creature)
		end
	end

	if talkState[playerId] == "release" then
		if MsgContains(message, "yes") then
			player:addItem(19203, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main, 0)
			npcHandler:sayLocalized("npc.gnomilly.gnometastic_take_this_27", npc, creature)
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			npcHandler:say("Ok then.", npc, creature)
			talkState[playerId] = nil
		end
	end

	--[[/////////////////
	////TRACK GHOSTS/////
	///////////////////]]
	if MsgContains(message, "track") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_have_28" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_are_29" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == -1 then
			npcHandler:say(
				{ "You'd be given the highly important task to track down an enormously malevolent spiritual presence in the cave system. Use your tracking device to find out how close you are to the presence.", "Use that information to find the residual energy and use the tracker there. If you are interested, I can give you some more information about it. Are you willing to accept this mission?" },
				npc,
				creature
			)
			talkState[playerId] = "track"
		else
			npcHandler:sayLocalized("npc.gnomilly.you_have_already_30", npc, creature)
		end
	end

	if talkState[playerId] == "track" then
		if MsgContains(message, "yes") then
			GHOST_DETECTOR_MAP[player:getGuid()] = Position.getFreeSand()
			player:addItem(19205, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main, 0)
			npcHandler:sayLocalized("npc.gnomilly.gnometastic_use_this_31", npc, creature)
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
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily) >= os.time() then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_have_32" .. string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily) - os.time()) .. " before this task gets available again.", npc, creature)
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return npcHandler:sayLocalized("npc.gnomilly.sorry_you_are_33" .. levels[1] .. "-" .. levels[2] .. "].", npc, creature)
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == -1 then
			npcHandler:sayLocalized("npc.gnomilly.we_need_someone_34", npc, creature)
			talkState[playerId] = "kill"
		else
			npcHandler:sayLocalized("npc.gnomilly.you_have_already_35", npc, creature)
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main, 0)
			npcHandler:sayLocalized("npc.gnomilly.gnometastic_just_go_36", npc, creature)
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
