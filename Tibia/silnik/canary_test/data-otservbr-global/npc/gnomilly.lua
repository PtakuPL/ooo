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
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_1")
	end

	if MsgContains(message, "gnome") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_2")
	end

	if MsgContains(message, "area") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_8")
	end

	if MsgContains(message, "mission") then
		if player:getLevel() > levels[2] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_3")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_4")
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_5")
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "pacifiers") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_6")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_7")
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_8")
			end
		elseif MsgContains(message, "release") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_9")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_10")
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_11")
			end
		elseif MsgContains(message, "tracking") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_12")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_13")
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_14")
			end
		elseif MsgContains(message, "killing") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_15")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_16")
				player:addFamePoint()
				player:addExperience(1000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_17")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_18")
		end
		talkState[playerId] = nil
		return
	end

	--[[///////////////////
	////GHOST PACIFIERS////
	/////////////////////]]
	if MsgContains(message, "pacifiers") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_1", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_2", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.multi_2")
			talkState[playerId] = "pacifiers"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_20")
		end
	end

	if talkState[playerId] == "pacifiers" then
		if MsgContains(message, "yes") then
			player:addItem(19204, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Pacifier_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_21")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_22")
			talkState[playerId] = nil
		end
	end

	--[[///////////////////
	////SPIRIT RELEASE/////
	/////////////////////]]
	if MsgContains(message, "release") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_3", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_4", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_24")
			talkState[playerId] = "release"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_25")
		end
	end

	if talkState[playerId] == "release" then
		if MsgContains(message, "yes") then
			player:addItem(19203, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Mound_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_26")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_27")
			talkState[playerId] = nil
		end
	end

	--[[/////////////////
	////TRACK GHOSTS/////
	///////////////////]]
	if MsgContains(message, "track") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_5", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_6", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main) == -1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.gnomilly.say_7", "npc.gnomilly.say_8" })
			talkState[playerId] = "track"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_29")
		end
	end

	if talkState[playerId] == "track" then
		if MsgContains(message, "yes") then
			GHOST_DETECTOR_MAP[player:getGuid()] = Position.getFreeSand()
			player:addItem(19205, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Track_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_30")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_31")
			talkState[playerId] = nil
		end
	end

	--[[/////////
	////KILL/////
	///////////]]
	if MsgContains(message, "kill") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_9", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_10", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_33")
			talkState[playerId] = "kill"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_34")
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Upper_Kill_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_35")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomilly.say_36")
			talkState[playerId] = nil
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomilly.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
