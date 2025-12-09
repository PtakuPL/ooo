local internalNpcName = "Palimuth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 325,
	lookHead = 97,
	lookBody = 0,
	lookLegs = 79,
	lookFeet = 98,
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

	if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) < 1 then
		player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 3)
	end

	if MsgContains(message, "job") and not player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 54 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_1")
	elseif MsgContains(message, "job") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 54 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_2")
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_54")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_55")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 4 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission01, 1) -- StorageValue for Questlog "Mission 01: Something Rotten"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 5)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_52")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_53")
			player:addMapMark(Position(32823, 31161, 8), 4, "Sewer Problem 1")
			player:addMapMark(Position(32795, 31152, 8), 4, "Sewer Problem 2")
			player:addMapMark(Position(32842, 31250, 8), 4, "Sewer Problem 3")
			player:addMapMark(Position(32796, 31192, 8), 4, "Sewer Problem 4")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_3")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_49")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_50")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) >= 7 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) <= 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_45")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_48")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 1) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 16)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.NotesPalimuth, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.NotesPalimuth) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_43")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_44")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 2) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 17)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToAzerus, 1)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_40")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_41")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 21)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToBog, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission03, 5) -- StorageValue for Questlog "Mission 03: Death to the Deathbringer"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_35")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_37")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 24)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 2) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 25 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestStatus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_33")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) + 1 or 0)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 26)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 5) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_31")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 29)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus, 0)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 2) -- StorageValue for Questlog "Mission 05: Food or Fight"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 32 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_5")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) + 1 or 0) -- Side Storage
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 33)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission05, 8) -- StorageValue for Questlog "Mission 05: Food or Fight"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 32 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TamerinStatus) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_6")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 35 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_28")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 36)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission06, 2) -- StorageValue for Questlog "Mission 06: Frightening Fuel"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 37 then
			if player:removeItem(8827, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_25")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_26")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 38)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission06, 4) -- StorageValue for Questlog "Mission 06: Frightening Fuel"
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraState, 1)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) + 1 or 0) -- Side Storage
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 40 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_24")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 41)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToQuara, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission07, 2) -- StorageValue for Questlog "Mission 07: A Fishy Mission"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 42 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.QuaraState) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_7")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 43)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission07, 5) -- StorageValue for Questlog "Mission 07: A Fishy Mission"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) >= 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.GoodSide) + 1 or 0) -- Side Storage
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 44 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_21")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 45)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToMatrix, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission08, 2) -- StorageValue for Questlog "Mission 08: Dangerous Machinations"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 46 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MatrixState) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_8")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 48 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_18")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 49)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 49 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 48 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_9")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 50 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_16")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 51)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.DoorToLastFight, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 2) -- StorageValue for Questlog "Mission 10: The Final Battle"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 52 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_12")
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
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 4)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_5")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SewerPipe01) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SewerPipe02) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SewerPipe03) == 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SewerPipe04) == 1 then
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 6)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission01, 6) -- StorageValue for Questlog "Mission 01: Something Rotten"
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission02, 1) -- StorageValue for Questlog "Mission 02: Watching the Watchmen"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 7)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.multi_2")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 14 then
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission02, 8) -- StorageValue for Questlog "Mission 02: Watching the Watchmen"
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 15)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_11")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_12")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 50)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission09, 2) -- StorageValue for Questlog "Mission 09: Decision"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 1) -- StorageValue for Questlog "Mission 10: The Final Battle"
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_13")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:getItemCount(9041) > 0 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 54 then
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 55)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_14")
				player:addOutfitAddon(325, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision) == 1 and 1 or 2)
				player:addOutfitAddon(324, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SideDecision) == 1 and 1 or 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.palimuth.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
