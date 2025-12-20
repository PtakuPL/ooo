local internalNpcName = "Jean Pierre"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 104,
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

local ingredients = {
	[1] = { { 3577, 2 }, { 8010, 20 }, { 8015, 1 }, { 8197, 1 }, { 3603, 5 }, { 2874, 2, 3 } },
	[2] = { { 7250, 2 }, { 3596, 2 }, { 8014, 1 }, { 3606, 2 }, { 3741, 1 }, { 2874, 1, 2 } },
	[3] = { { 4363, 1 }, { 8016, 3 }, { 3602, 5 }, { 3606, 2 }, { 3739, 1 }, { 3724, 5 } },
	[4] = { { 4330, 1 }, { 8013, 2 }, { 3586, 2 }, { 5096, 2 }, { 2874, 2, 15 }, { 3735, 1 } },
	[5] = { { 6574, 1 }, { 6393, 1 }, { 3587, 2 }, { 2874, 2, 9 }, { 3738, 1 }, { 3736, 1 } },
	[6] = { { 3595, 2 }, { 3596, 2 }, { 3597, 2 }, { 8014, 2 }, { 8015, 1 }, { 8197, 1 }, { 3607, 1 }, { 3723, 20 }, { 3725, 5 } },
	[7] = { { 8016, 10 }, { 3607, 2 }, { 3741, 1 }, { 3740, 1 }, { 2874, 1, 16 }, { 3606, 2 } },
	[8] = { { 3582, 1 }, { 8011, 5 }, { 8015, 1 }, { 8017, 2 }, { 3594, 1 }, { 8016, 2 } },
	[9] = { { 3580, 1 }, { 7158, 1 }, { 7159, 1 }, { 3581, 5 }, { 3601, 2 }, { 3737, 1 } },
	[10] = { { 3595, 5 }, { 2874, 1, 9 }, { 8013, 1 }, { 3603, 10 }, { 3606, 2 }, { 3598, 10 }, { 841, 2 } },
	[11] = { { 2874, 5, 15 }, { 3725, 5 }, { 3724, 5 }, { 10329, 10 }, { 3581, 10 } },
	[12] = { { 10456, 5 }, { 2874, 2, 1 }, { 3595, 20 }, { 8010, 10 }, { 8016, 3 } },
	[13] = { { 6569, 3 }, { 3599, 3 }, { 6574, 2 }, { 6500, 15 }, { 6558, 1 } },
	[14] = { { 3606, 40 }, { 5096, 20 }, { 5902, 10 }, { 8758, 1 }, { 5942, 1 } },
}

local function playerHasIngredients(creature)
	local player = Player(creature)
	local table = ingredients[player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish)]
	if table then
		for i = 1, #table do
			local itemCount = player:getItemCount(table[i][1], table[i][3] or -1)
			if itemCount < table[i][2] then
				itemCount = table[i][2] - itemCount
				return false
			end
		end
	end

	for i = 1, #table do
		player:removeItem(unpack(table[i]))
	end
	return true
end

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function canCookToday(player, lastInteractionKey)
	local currentDate = os.time()
	local lastInteractionDate = player:getStorageValue(lastInteractionKey)

	if lastInteractionDate == -1 then
		return true
	end

	local lastDateTable = os.date("*t", lastInteractionDate)
	local currentDateTable = os.date("*t", currentDate)

	if currentDateTable.month == 8 and (currentDateTable.year > lastDateTable.year or lastDateTable.month ~= 8) then
		return true
	end

	return false
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	local currentDate = os.time()
	local currentDateTable = os.date("*t", currentDate)

	if currentDateTable.month == 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jean_pierre.greet_msg_1")
	else
		endConversationWithDelay(npcHandler, npc, creature)
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local currentDate = os.time()

	if MsgContains(message, "cook") then
		if player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "recipe") or MsgContains(message, "menu") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_2")
			npcHandler:setTopic(playerId, 2)
		end
		if player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			if player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_105")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_106")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_107")
				npcHandler:setTopic(playerId, 4)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_102")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_103")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_104")
				npcHandler:setTopic(playerId, 6)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_99")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_100")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_101")
				npcHandler:setTopic(playerId, 8)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_97")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_98")
				npcHandler:setTopic(playerId, 10)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_95")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_96")
				npcHandler:setTopic(playerId, 12)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 6 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_92")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_93")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_94")
				npcHandler:setTopic(playerId, 14)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 7 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_90")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_91")
				npcHandler:setTopic(playerId, 16)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 8 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_88")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_89")
				npcHandler:setTopic(playerId, 18)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 9 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_86")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_87")
				npcHandler:setTopic(playerId, 20)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 10 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_84")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_85")
				npcHandler:setTopic(playerId, 22)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 11 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_80")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_81")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_82")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_83")
				npcHandler:setTopic(playerId, 24)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 12 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_75")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_76")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_77")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_78")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_79")
				npcHandler:setTopic(playerId, 26)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 13 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_70")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_71")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_72")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_73")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_74")
				npcHandler:setTopic(playerId, 28)
			elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish) == 14 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_66")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_67")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_68")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_69")
				npcHandler:setTopic(playerId, 30)
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_3")
		end
	elseif MsgContains(message, "apprentice") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_4")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_5")
			player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart, 1)
			player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 1)
			player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 1)
		elseif npcHandler:getTopic(playerId) == 5 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate2) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_63")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_64")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_65")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 2)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 2)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate2, currentDate)
					player:addItem(9079, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_6")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_7")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 7 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate3) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_60")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_61")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_62")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 3)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 3)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate3, currentDate)
					player:addItem(9080, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_8")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_9")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate4) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_56")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_57")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_58")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_59")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate4, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 4)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 4)
					player:addItem(9081, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_10")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 11 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate5) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_52")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_53")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_54")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_55")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate5, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 5)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 5)
					player:addItem(9082, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_12")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_13")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 13 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate6) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_48")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_49")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_50")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_51")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate6, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 6)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 6)
					player:addItem(9083, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_14")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 15 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate7) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_44")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_45")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_46")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_47")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate7, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 7)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 7)
					player:addItem(9084, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_16")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_17")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 17 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate8) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_39")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_40")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_41")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_42")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_43")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate8, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 8)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 8)
					player:addItem(9085, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_18")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_19")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 19 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate9) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_35")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_36")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_37")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_38")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate9, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 9)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 9)
					player:addItem(9086, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_20")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_21")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 21 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate10) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_31")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_32")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_33")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_34")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate10, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 10)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 10)
					player:addItem(9088, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_22")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_23")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 23 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate11) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_24")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_25")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_26")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_27")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_28")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_29")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_30")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate11, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 11)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 11)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CookbookDoor, 1)
					player:addItem(10000, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_24")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_25")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 25 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate12) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_18")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_19")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_20")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_21")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_22")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_23")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate12, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 12)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 13)
					player:addItem(11584, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_26")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_27")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 27 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate13) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_12")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_13")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_14")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_15")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_16")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_17")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate13, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 13)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 14)
					player:addItem(11586, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_28")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_29")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 29 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate14) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_7")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_8")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_9")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_10")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_11")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate14, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 14)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 15)
					player:addItem(11587, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_30")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_31")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 31 then
			if canCookToday(player, Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate15) then
				if playerHasIngredients(creature) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_1")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_2")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_3")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_4")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_5")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.multi_6")
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.LastInteractionDate15, currentDate)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart, 2)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 15)
					player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestLog, 16)
					player:addItem(11588, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_32")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_33")
				npcHandler:setTopic(playerId, 0)
			end
		end
		--Dishes first time
	elseif MsgContains(message, "rotworm stew") then
		if npcHandler:getTopic(playerId) == 4 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_34")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "hydra tongue salad") then
		if npcHandler:getTopic(playerId) == 6 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_35")
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "roasted dragon wings") then
		if npcHandler:getTopic(playerId) == 8 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_36")
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "tropical fried terrorbird") then
		if npcHandler:getTopic(playerId) == 10 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_37")
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "banana chocolate shake") then
		if npcHandler:getTopic(playerId) == 12 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_38")
			npcHandler:setTopic(playerId, 13)
		end
	elseif MsgContains(message, "veggie casserole") then
		if npcHandler:getTopic(playerId) == 14 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_39")
			npcHandler:setTopic(playerId, 15)
		end
	elseif MsgContains(message, "filled") or MsgContains(message, "jalapeño") or MsgContains(message, "peppers") then
		if npcHandler:getTopic(playerId) == 16 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_40")
			npcHandler:setTopic(playerId, 17)
		end
	elseif MsgContains(message, "blessed steak") then
		if npcHandler:getTopic(playerId) == 18 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_41")
			npcHandler:setTopic(playerId, 19)
		end
	elseif MsgContains(message, "northern fishburger") then
		if npcHandler:getTopic(playerId) == 20 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_42")
			npcHandler:setTopic(playerId, 21)
		end
	elseif MsgContains(message, "carrot cake") then
		if npcHandler:getTopic(playerId) == 22 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_43")
			npcHandler:setTopic(playerId, 23)
		end
	elseif MsgContains(message, "coconut shrimp bake") then
		if npcHandler:getTopic(playerId) == 24 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_44")
			npcHandler:setTopic(playerId, 25)
		end
	elseif MsgContains(message, "blackjack") then
		if npcHandler:getTopic(playerId) == 26 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_45")
			npcHandler:setTopic(playerId, 27)
		end
	elseif MsgContains(message, "demonic candy ball") then
		if npcHandler:getTopic(playerId) == 28 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_46")
			npcHandler:setTopic(playerId, 29)
		end
	elseif MsgContains(message, "sweet mangonaise elixir") then
		if npcHandler:getTopic(playerId) == 30 or player:getStorageValue(Storage.Quest.U8_5.HotCuisineQuest.QuestStart) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_47")
			player:setStorageValue(Storage.Quest.U8_5.HotCuisineQuest.CurrentDish, 14)
			npcHandler:setTopic(playerId, 31)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jean_pierre.say_48")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
