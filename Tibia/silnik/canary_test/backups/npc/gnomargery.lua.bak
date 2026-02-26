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
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_48")
	end

	if MsgContains(message, "gnome") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_49")
	end

	if MsgContains(message, "area") then
		return NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.gnomargery.say_50", "npc.gnomargery.say_51", "npc.gnomargery.say_52", "npc.gnomargery.say_53", "npc.gnomargery.say_54" })
	end

	if MsgContains(message, "spike") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_55")
	end

	if MsgContains(message, "mission") then
		if player:getLevel() < level then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_56")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_57")
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_58")
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "delivery") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_59")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_60")
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_61")
			end
		elseif MsgContains(message, "undercover") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_62")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_63")
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_64")
			end
		elseif MsgContains(message, "temperature") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_65")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_66")
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_67")
			end
		elseif MsgContains(message, "kill") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_68")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_69")
				player:addFamePoint()
				player:addExperience(3500, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_70")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_71")
		end
		talkState[playerId] = nil
		return
	end

	--[[///////////////////
	////PARCEL DELIVERY////
	/////////////////////]]
	if MsgContains(message, "deliver") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_72", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Daily) - os.time()) })
		end

		if player:getLevel() < level then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_73", { level })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_74")
			talkState[playerId] = "delivery"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_75")
		end
	end

	if talkState[playerId] == "delivery" then
		if MsgContains(message, "yes") then
			player:addItem(19219, 4)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Parcel_Main, 0)
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.gnomargery.say_76", "npc.gnomargery.say_77" })
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_78")
			talkState[playerId] = nil
		end
	end

	--[[//////////////
	////UNDERCOVER////
	////////////////]]
	if MsgContains(message, "undercover") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_79", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Daily) - os.time()) })
		end

		if player:getLevel() < level then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_80", { level })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_81")
			talkState[playerId] = "undercover"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_82")
		end
	end

	if talkState[playerId] == "undercover" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Undercover_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_83")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_84")
			talkState[playerId] = nil
		end
	end

	--[[////////////////
	////TEMPERATURE/////
	//////////////////]]
	if MsgContains(message, "temperature") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_85", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Daily) - os.time()) })
		end

		if player:getLevel() < level then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_86", { level })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_87")
			talkState[playerId] = "temperature"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_88")
		end
	end

	if talkState[playerId] == "temperature" then
		if MsgContains(message, "yes") then
			player:addItem(19206, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Lava_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_89")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_90")
			talkState[playerId] = nil
		end
	end

	--[[/////////
	////KILL/////
	///////////]]
	if MsgContains(message, "kill") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_91", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Daily) - os.time()) })
		end

		if player:getLevel() < level then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_92", { level })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_93")
			talkState[playerId] = "kill"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_94")
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Lower_Kill_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_95")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomargery.say_96")
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
