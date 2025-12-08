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
			npcHandler:sayLocalized("npc.kevin.you_are_not_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01) == 5 then
			npcHandler:sayLocalized("npc.kevin.so_you_have_2", npc, creature)
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02) == 2 then
			npcHandler:sayLocalized("npc.kevin.excellent_you_got_3", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02, 3)
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 2 then
			npcHandler:sayLocalized("npc.kevin.you_truly_got_4", npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 1 then
			npcHandler:sayLocalized("npc.kevin.do_you_bring_5", npc, creature)
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05) == 3 then
			npcHandler:sayLocalized("npc.kevin.splendid_i_knew_6", npc, creature)
			npcHandler:setTopic(playerId, 16)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) == 8 then
			npcHandler:sayLocalized("npc.kevin.once_more_you_7", npc, creature)
			npcHandler:setTopic(playerId, 21)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) >= 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) < 10 then
			npcHandler:sayLocalized("npc.kevin.first_you_need_8", npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 12 then
			npcHandler:sayLocalized("npc.kevin.excellent_another_job_9", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 13)
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 10 then
			npcHandler:sayLocalized("npc.kevin.fine_fine_i_10", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 11)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 2 then
			npcHandler:sayLocalized("npc.kevin.so_waldo_is_11", npc, creature)
			npcHandler:setTopic(playerId, 23)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09) == 3 then
			npcHandler:sayLocalized("npc.kevin.you_did_it_12", npc, creature)
			npcHandler:setTopic(playerId, 26)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 2 then
			npcHandler:sayLocalized("npc.kevin.you_have_delivered_13", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10, 3)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 5 then
			npcHandler:sayLocalized("npc.kevin.there_are_no_14", npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			npcHandler:sayLocalized("npc.kevin.there_are_no_15", npc, creature)
			npcHandler:setTopic(playerId, 27)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			npcHandler:sayLocalized("npc.kevin.so_are_you_16", npc, creature)
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			npcHandler:sayLocalized("npc.kevin.so_are_you_17", npc, creature)
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 or player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09) == 0 then
			npcHandler:sayLocalized("npc.kevin.so_are_you_18", npc, creature)
			npcHandler:setTopic(playerId, 25)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) < 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			npcHandler:sayLocalized("npc.kevin.excellent_another_job_19", npc, creature)
			npcHandler:setTopic(playerId, 19)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) >= 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			npcHandler:sayLocalized("npc.kevin.excellent_another_job_20", npc, creature)
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			npcHandler:sayLocalized("npc.kevin.you_have_made_21", npc, creature)
			npcHandler:setTopic(playerId, 15)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			npcHandler:sayLocalized("npc.kevin.you_have_made_22", npc, creature)
			npcHandler:setTopic(playerId, 28)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 0 then
			npcHandler:sayLocalized("npc.kevin.you_truly_got_23", npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03) == 3 then
			npcHandler:sayLocalized("npc.kevin.so_are_you_24", npc, creature)
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			npcHandler:sayLocalized("npc.kevin.so_are_you_25", npc, creature)
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "dress pattern") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 2 then
			npcHandler:sayLocalized("npc.kevin.oh_yes_where_26", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 3)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 4 then
			npcHandler:sayLocalized("npc.kevin.the_mail_with_27", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 5)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 6 then
			npcHandler:sayLocalized("npc.kevin.the_queen_has_28", npc, creature)
			npcHandler:setTopic(playerId, 18)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 10 then
			npcHandler:sayLocalized("npc.kevin.fine_fine_i_29", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 11)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "advancement") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04) == 2 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 1 then
			npcHandler:sayLocalized("npc.kevin.you_are_worthy_30", npc, creature)
			npcHandler:setTopic(playerId, 14)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 13 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 2 then
			npcHandler:sayLocalized("npc.kevin.you_are_worthy_31", npc, creature)
			npcHandler:setTopic(playerId, 20)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 3 then
			npcHandler:sayLocalized("npc.kevin.you_are_worthy_32", npc, creature)
			npcHandler:setTopic(playerId, 24)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10) == 3 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank) == 4 then
			npcHandler:sayLocalized("npc.kevin.you_are_worthy_33", npc, creature)
			npcHandler:setTopic(playerId, 27)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.kevin.hm_i_might_34", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.kevin.excellent_your_first_35", npc, creature)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:sayLocalized("npc.kevin.so_listen_you_36", npc, creature)
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.kevin.excellent_once_you_37", npc, creature)
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			npcHandler:sayLocalized("npc.kevin.fine_fine_next_38", npc, creature)
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:sayLocalized("npc.kevin.good_finally_find_39", npc, creature)
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			npcHandler:sayLocalized("npc.kevin.ok_remember_the_40", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			npcHandler:sayLocalized("npc.kevin.i_am_glad_41", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission01, 6)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission02, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			npcHandler:sayLocalized("npc.kevin.for_your_noble_42", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 1)
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 10 then
			npcHandler:sayLocalized("npc.kevin.i_need_you_43", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03, 1)
			player:addItem(3216, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			npcHandler:sayLocalized("npc.kevin.ok_listen_we_44", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission03, 3)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if getPlayerBones(creature) >= 20 then
				doPlayerRemoveBones(creature)
				npcHandler:sayLocalized("npc.kevin.you_have_collected_45", npc, creature)
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission04, 2)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:setTopic(playerId, 0)
				npcHandler:sayLocalized("npc.kevin.you_dont_have_46", npc, creature)
			end
		elseif npcHandler:getTopic(playerId) == 14 then
			npcHandler:sayLocalized("npc.kevin.i_grant_you_47", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 2)
			player:addItem(3576, 1)
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 15 then
			npcHandler:sayLocalized("npc.kevin.since_i_am_48", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			npcHandler:sayLocalized("npc.kevin.ok_we_need_49", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05, 4)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 18 then
			npcHandler:sayLocalized("npc.kevin.good_go_there_50", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 7)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 19 then
			npcHandler:sayLocalized("npc.kevin.good_so_listen_51", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 20 then
			npcHandler:sayLocalized("npc.kevin.from_now_on_52", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 3)
			npcHandler:setTopic(playerId, 19)
		elseif npcHandler:getTopic(playerId) == 21 then
			npcHandler:sayLocalized("npc.kevin.ok_but_your_53", npc, creature)
			npcHandler:setTopic(playerId, 22)
		elseif npcHandler:getTopic(playerId) == 22 then
			npcHandler:sayLocalized("npc.kevin.find_out_about_54", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, 9)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 23 then
			if player:removeItem(3219, 1) then
				npcHandler:sayLocalized("npc.kevin.thank_you_we_55", npc, creature)
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08, 3)
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 0)
				npcHandler:setTopic(playerId, 28)
			end
		elseif npcHandler:getTopic(playerId) == 24 then
			npcHandler:sayLocalized("npc.kevin.from_now_on_56", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 4)
			player:addItem(3252, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 25 then
			npcHandler:sayLocalized("npc.kevin.so_listen_well_57", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 26 then
			npcHandler:sayLocalized("npc.kevin.excellent_here_is_58", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission09, 4)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission10, 1)
			player:addItem(3220, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 27 then
			npcHandler:sayLocalized("npc.kevin.i_grant_you_59", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Rank, 5)
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Door, 1)
			player:addAchievement("Archpostman")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 28 then
			npcHandler:sayLocalized("npc.kevin.your_eagerness_is_60", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
