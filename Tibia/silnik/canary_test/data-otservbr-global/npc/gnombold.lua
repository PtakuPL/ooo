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
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_1")
	end

	if MsgContains(message, "gnome") then
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_2")
	end

	if MsgContains(message, "area") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_9")
	end

	if MsgContains(message, "mission") then
		if player:getLevel() > levels[2] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_3")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_4")
		end
		return
	end

	if MsgContains(message, "report") then
		talkState[playerId] = "report"
		return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_5")
	end

	if talkState[playerId] == "report" then
		if MsgContains(message, "charges") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_6")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_7")
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_8")
			end
		elseif MsgContains(message, "fertilisation") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_9")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_10")
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_11")
			end
		elseif MsgContains(message, "nests") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_12")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_13")
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_14")
			end
		elseif MsgContains(message, "killing") then
			if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == -1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_15")
			elseif player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_16")
				player:addFamePoint()
				player:addExperience(2000, true)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main, -1)
				player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily, os.time() + 72000)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_17")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_18")
		end
		talkState[playerId] = nil
		return
	end

	if MsgContains(message, "charges") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_1", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_2", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.multi_2")
			talkState[playerId] = "charges"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_20")
		end
	end

	if talkState[playerId] == "charges" then
		if MsgContains(message, "yes") then
			player:addItem(19207, 1)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Charge_Main, 0)
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.gnombold.say_3", "npc.gnombold.say_4" })
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_21")
			talkState[playerId] = nil
		end
	end

	--[[/////////////
	////FERTILISE////
	///////////////]]
	if MsgContains(message, "fertilise") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_5", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_6", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_23")
			talkState[playerId] = "fertilise"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_24")
		end
	end

	if talkState[playerId] == "fertilise" then
		if MsgContains(message, "yes") then
			player:addItem(19214)
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Mushroom_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_25")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_26")
			talkState[playerId] = nil
		end
	end

	--[[//////////////////
	////DESTROY NESTS/////
	////////////////////]]
	if MsgContains(message, "nests") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_7", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_8", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_28")
			talkState[playerId] = "nests"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_29")
		end
	end

	if talkState[playerId] == "nests" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Nest_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_30")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_31")
			talkState[playerId] = nil
		end
	end

	--[[/////////
	////KILL/////
	///////////]]
	if MsgContains(message, "kill") then
		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily) >= os.time() then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_9", { string.diff(player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Daily) - os.time()) })
		end

		if (player:getLevel() < levels[1]) or (player:getLevel() > levels[2]) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_10", { levels[1], levels[2] })
		end

		if player:getStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_33")
			talkState[playerId] = "kill"
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_34")
		end
	end

	if talkState[playerId] == "kill" then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U10_20.SpikeTaskQuest.Spike_Middle_Kill_Main, 0)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_35")
			talkState[playerId] = nil
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnombold.say_36")
			talkState[playerId] = nil
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnombold.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
