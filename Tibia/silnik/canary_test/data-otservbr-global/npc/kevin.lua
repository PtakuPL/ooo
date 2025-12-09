local internalNpcName = "Kevin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 76,
	lookBody = 43,
	lookLegs = 38,
	lookFeet = 76,
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

local function getPlayerBones(creature)
	local player = Player(creature)
	return player:getItemCount(3115) + player:getItemCount(3116)
end

local function doPlayerRemoveBones(creature)
	local player = Player(creature)
	return player:removeItem(3115, player:getItemCount(3115)) and player:removeItem(3116, player:getItemCount(3116))
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_2")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_3")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02, 3)
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_4")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_5")
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_6")
			npcHandler:setTopic(playerId, 16)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_7")
			npcHandler:setTopic(playerId, 21)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) >= 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) < 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_8")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_9")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 13)
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_10")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 11)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_11")
			npcHandler:setTopic(playerId, 23)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_12")
			npcHandler:setTopic(playerId, 26)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_13")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10, 3)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_14")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_15")
			npcHandler:setTopic(playerId, 27)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_16")
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_17")
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 or player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09) == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_18")
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) < 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_19")
			npcHandler:setTopic(playerId, 19)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) >= 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_20")
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_21")
			npcHandler:setTopic(playerId, 15)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_22")
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_23")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_24")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_25")
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "dress pattern") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_26")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 3)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_27")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 5)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_28")
			npcHandler:setTopic(playerId, 18)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_29")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 11)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "advancement") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_30")
			npcHandler:setTopic(playerId, 14)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_31")
			npcHandler:setTopic(playerId, 20)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_32")
			npcHandler:setTopic(playerId, 24)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_33")
			npcHandler:setTopic(playerId, 27)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_34")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_35")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_36")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_37")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_38")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_39")
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_40")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_41")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 6)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_42")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 1)
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_43")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03, 1)
			player:addItem(3216, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_44")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03, 3)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if getPlayerBones(creature) >= 20 then
				doPlayerRemoveBones(creature)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_45")
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04, 2)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:setTopic(playerId, 0)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_46")
			end
		elseif npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_47")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 2)
			player:addItem(3576, 1)
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_48")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_49")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05, 4)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_50")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 7)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_51")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_52")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 3)
			npcHandler:setTopic(playerId, 19)
		elseif npcHandler:getTopic(playerId) == 21 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_53")
			npcHandler:setTopic(playerId, 22)
		elseif npcHandler:getTopic(playerId) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_54")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, 9)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 23 then
			if player:removeItem(3219, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_55")
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08, 3)
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 0)
				npcHandler:setTopic(playerId, 28)
			end
		elseif npcHandler:getTopic(playerId) == 24 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_56")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 4)
			player:addItem(3252, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_57")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_58")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 4)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10, 1)
			player:addItem(3220, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_59")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 5)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Door, 1)
			player:addAchievement("Archpostman")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.kevin.say_60")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
