local internalNpcName = "Yalahari"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 309,
	lookHead = 38,
	lookBody = 88,
	lookLegs = 88,
	lookFeet = 115,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_54")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 18)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 3) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.NotesAzerus, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.NotesAzerus) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_50")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_52")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 19)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_45")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_48")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_49")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 20)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 4) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 21 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.AlchemistFormula) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_40")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_41")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_43")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 23)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 1) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_39")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 27)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 6) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 25 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestStatus) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_35")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_37")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) + 1 or 0) -- Side Storage
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 27)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 6) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_34")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 28)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 1) -- StorageValue for Questlog "Mission 05: Food or Fight"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_28")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 34)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 32 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_26")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) + 1 or 0) -- Side Storage
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 34)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 8) -- StorageValue for Questlog "Mission 05: Food or Fight"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_24")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 35)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission06, 1) -- StorageValue for Questlog "Mission 06: Frightening Fuel"
			player:addItem(8822, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 38 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_19")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 39)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission06, 5) -- StorageValue for Questlog "Mission 06: Frightening Fuel"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 37 then
			if player:removeItem(8827, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_16")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_17")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 39)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission06, 5) -- StorageValue for Questlog "Mission 06: Frightening Fuel"
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraState, 2)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) + 1 or 0) -- Side Storage
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 39 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_15")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 40)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission07, 1) -- StorageValue for Questlog "Mission 07: A Fishy Mission"
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 41
			and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraInky) == 1
			and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraSharptooth) == 1
			and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraSplasher) == 1
			and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraState) == 2
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_2")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 43)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission07, 5) -- StorageValue for Questlog "Mission 07: A Fishy Mission"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) + 1 or 0) -- Side Storage
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 43 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_12")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 44)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission08, 1) -- StorageValue for Questlog "Mission 08: Dangerous Machinations"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 46 then
			if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MatrixState) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_3")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) + 1 or 0) -- Side Storage
			elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MatrixState) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_4")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide) + 1 or 0) -- Side Storage
			end
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 47)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission08, 4) -- StorageValue for Questlog "Mission 08: Dangerous Machinations"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 47 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_8")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 48)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission09, 1) -- StorageValue for Questlog "Mission 09: Decision"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 49 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 48 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_5")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 50 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_6")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 51)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToLastFight, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 2) -- StorageValue for Questlog "Mission 10: The Final Battle"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 52 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_6")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 53)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToReward, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 4) -- StorageValue for Questlog "Mission 10: The Final Battle"
			player:addOutfit(324, 0)
			player:addOutfit(325, 0)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(8818, 1) then
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.BadSide, 1)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 22)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 6) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_7")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 50)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision, 2)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission09, 2) -- StorageValue for Questlog "Mission 09: Decision"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) == 0 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 22)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 6) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yalahari.multi_2")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
