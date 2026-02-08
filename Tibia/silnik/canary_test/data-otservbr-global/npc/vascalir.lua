local internalNpcName = "Vascalir"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 96,
	lookBody = 121,
	lookLegs = 79,
	lookFeet = 116,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.vascalir.voice_1" },
	{ i18nKey = "npc.vascalir.voice_2" },
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	local player = Player(creature)
	-- Reject to start missions
	if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline) == -1 and player:getLevel() > 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_1")
		return false
		-- Warn if started missions and reached level 8
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline) == 1 and player:getLevel() == 8 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Level8Warning) == -1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.vascalir.greet_msg_27",
			"npc.vascalir.greet_msg_28",
			"npc.vascalir.greet_msg_29",
			"npc.vascalir.greet_msg_30",
		}, 1000)
		return false
		-- Completed all missions
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_2")
		return false
		-- Not started mission 2
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_1")
		-- Not finished mission 2
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) <= 3 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_1")
		-- Finishing mission 2
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_2")
		-- Finished mission 2 but not started mission 3
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_3")
		-- Not finished or finishing mission 3
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_4")
		-- Started but not finished mission 4
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) <= 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_3")
		return false
		-- Finishing mission 4
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 5 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_5")
		-- Finished mission 4 but not started mission 5
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 6 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_6")
		-- Started but not finished mission 5
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) <= 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_7")
		-- Finishing mission 5
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == 3 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_2")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05, 5)
		player:addExperience(50, true)
		-- Finishing mission 5
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == 5 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_8")
		-- Started but not finished mission 6
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06) <= 6 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_4")
		return false
		-- Finished mission 6 but not started mission 7
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06) == 7 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_9")
		-- Started but not finished mission 7
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryChest) == -1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_5")
		return false
		-- Finishing mission 7
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryChest) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_10")
		-- Finished mission 7 but not started mission 8
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_11")
		-- Started but not finished mission 8
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_6")
		return false
		-- Finished mission 8 but not started mission 9
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_12")
		-- Started but not finished mission 9
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) <= 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_7")
		return false
		-- Finishing mission 9
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_13")
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09, 9)
		player:addExperience(50, true)
		-- Finish mission 9
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 9 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_14")
		-- Finished mission 9 but not started mission 10
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 10 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_15")
		-- Started but not finished mission 10
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_16")
		-- Finishing mission 10
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_17")
		-- Finish mission 10
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_18")
		-- Finished mission 10 but not started mission 11
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 3 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_19")
		-- Started but not finished mission 11
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 1 or player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 2 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_20")
		-- Finishing mission 11
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 3 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_21")
		-- Finish mission 11
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_22")
		-- Finished mission 11 but not started mission 12
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_23")
		-- Started but not finished mission 12
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) <= 13 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vascalir.say_8")
		return false
		-- Finish mission 12
	elseif player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) == 14 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vascalir.greet_msg_3")
	end
	return true
end

-- Mission 2: Start
local mission2 = keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_39",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == -1
end)
keywordHandler:addAliasKeyword({ "mission" })

-- Mission 2: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_1",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == -1
end)

local mission02Reject = KeywordNode:new({ "no" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.vascalir.stdmod_1" })

-- Mission 2: Accept
local mission2Accept = mission2:addChildKeyword(
	{ "yes" },
	StdModule.say,
	{
		npcHandler = npcHandler,
		i18nKey = "npc.vascalir.stdmod_40",
	},
	nil,
	function(player)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline, 1)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02, 1)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Catapults, 0)
		player:addMapMark({ x = 32082, y = 32182, z = 7 }, MAPMARK_FLAG, "Barn")
		player:addMapMark({ x = 32097, y = 32181, z = 7 }, MAPMARK_BAG, "Norma's Bar")
		player:addMapMark({ x = 32105, y = 32203, z = 7 }, MAPMARK_BAG, "Obi's Shop")
	end
)

mission2Accept:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_2",
	ungreet = true,
})

mission2Accept:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_41",
	moveup = 1,
})

-- Mission 2: Finish - Confirm
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_42",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 4
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02, 5)
	player:addItemEx(Game.createItem(3426, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 2: Finish - Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_3",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 4
end)

-- Mission 3: Start
local mission3 = keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_43",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == -1
end)

-- Mission 3: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_4",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == -1
end)

-- Mission 3: Accept
mission3:addChildKeyword(
	{ "yes" },
	StdModule.say,
	{
		npcHandler = npcHandler,
		i18nKey = "npc.vascalir.stdmod_44",
	},
	nil,
	function(player)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03, 1)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.RatKills, 0)
		player:addMapMark({ x = 32097, y = 32205, z = 7 }, MAPMARK_GREENSOUTH, "Rat Dungeon")
		player:addMapMark({ x = 32041, y = 32228, z = 7 }, MAPMARK_GREENSOUTH, "Rat Dungeon")
	end
)

-- Mission 3: Decline
mission3:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_45",
	moveup = 1,
})

-- Mission 3: Complain not finished
keywordHandler:addKeyword({ "yes" }, nil, {}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.RatKills) < 5
end, function(player)
	local ratKills = player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.RatKills)
	player:sendLocalizedTextMessage(MESSAGE_NPC_FROM, "npc.vascalir.say_rats_remaining", { tostring(5 - ratKills) })
end)
keywordHandler:addAliasKeyword({ "no" })

-- Mission 3: Finish - Confirm
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_46",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.RatKills) >= 5
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03, 2)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, 1)
	player:addExperience(30, true)
	player:addItemEx(Game.createItem(3273, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 3: Finish - Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_5",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.RatKills) == 5
end)

-- Mission 4: Finish - Confirm
keywordHandler:addKeyword({ "help" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_47",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 5
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, 6)
end)

-- Mission 4: Finish - Wrong Confirm
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_6",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 5
end)
keywordHandler:addAliasKeyword({ "no" })

-- Mission 5: Accept - Explain again
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_48",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 6 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == -1 or (player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) <= 2)
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05, 1)
	player:addMapMark({ x = 32051, y = 32110, z = 7 }, MAPMARK_GREENSOUTH, "Spider Lair")
end)

-- Mission 5: Decline - Explain again
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_7",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04) == 6 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == -1 or (player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) >= 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) <= 2)
end)

-- Mission 5: Finish - Accept Reward (Studded armor)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_8",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == 5
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05, 6)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, 1)
	player:addItemEx(Game.createItem(3378, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 5: Finish - Reject Reward (Studded armor)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_9",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05) == 5
end)

-- Mission 7: Start
local mission7 = keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_49",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06) == 7 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == -1
end)
--keywordHandler:addAliasKeyword({"no"})

-- Mission 7: Accept
mission7:addChildKeyword(
	{ "yes" },
	StdModule.say,
	{
		npcHandler = npcHandler,
		i18nKey = "npc.vascalir.stdmod_50",
	},
	nil,
	function(player)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07, 1)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryDoor, 1)
	end
)

-- Mission 7: Decline
mission7:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_10",
	ungreet = true,
})

-- Mission 7: Finish - Confirm/Decline (Without having the book)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_51",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryChest) == 1 and player:getItemCount(12675) <= 0
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07, 2)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryDoor, -1)
	player:addExperience(100, true)
end)
keywordHandler:addAliasKeyword({ "no" })

-- Mission 7: Finish - Confirm (Having the book)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_52",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryChest) == 1 and player:getItemCount(12675) >= 1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07, 2)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryDoor, -1)
	player:removeItem(12675, 1)
	player:addExperience(100, true)
	player:addItemEx(Game.createItem(3035, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 7: Finish - Decline (Having the book)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_53",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryChest) == 1 and player:getItemCount(12675) >= 1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07, 2)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.LibraryDoor, -1)
	player:removeItem(12675, 1)
	player:addExperience(100, true)
	player:addItemEx(Game.createItem(3035, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 8: Accept
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_54",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08, 1)
end)

-- Mission 8: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_11",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == -1
end)

-- Mission 9: Accept
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_55",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09, 1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.TrollChests, 0)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.TunnelPillars, 0)
	player:addMapMark({ x = 32094, y = 32137, z = 7 }, MAPMARK_GREENSOUTH, "Troll Caves")
end)

-- Mission 9: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_12",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 2 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == -1
end)

-- Mission 9: Finish - Accept Reward (Brass helmet)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_13",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 9
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09, 10)
	player:addItemEx(Game.createItem(3354, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 9: Finish - Reject Reward (Brass helmet)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_14",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 9
end)

-- Mission 10: Accept
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_56",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 10 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10, 1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.UnholyCryptDoor, 1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.UnholyCryptChests, 0)
	player:addItemEx(Game.createItem(3083, 1), true, CONST_SLOT_WHEREEVER)
	player:addMapMark({ x = 32131, y = 32201, z = 7 }, MAPMARK_GREENSOUTH, "Unholy Crypt")
end)

-- Mission 10: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_15",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09) == 10 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == -1
end)

-- Mission 10: Confirm (Explain again)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_57",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == -1
end)

-- Mission 10: Decline (Explain again)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_16",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == -1
end)

-- Mission 10: Finish - Confirm/Decline (Having the fleshy bone)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_17",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == 1 and player:getItemCount(12674) >= 1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10, 2)
	player:addExperience(150, true)
	player:removeItem(12674, 1)
end)
keywordHandler:addAliasKeyword({ "no" })

-- Mission 10: Finish - Confirm/Decline (Without having the fleshy bone)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_18",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 1 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Sarcophagus) == 1 and player:getItemCount(12674) == 0
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10, 2)
	player:addExperience(80, true)
end)
keywordHandler:addAliasKeyword({ "no" })

-- Mission 10: Finish - Accept Reward (Sword)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_19",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 2
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10, 3)
	player:addItemEx(Game.createItem(3264, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 10: Finish - Reject Reward (Sword)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_20",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 2
end)

-- Mission 11: Start
local mission11 = keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_58",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 3 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == -1
end)

-- Mission 11: Decline Start
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_21",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10) == 3 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == -1
end)

-- Mission 11: Accept
mission11:addChildKeyword(
	{ "yes" },
	StdModule.say,
	{
		npcHandler = npcHandler,
		i18nKey = "npc.vascalir.stdmod_22",
		ungreet = true,
	},
	nil,
	function(player)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, 1)
		player:addItemEx(Game.createItem(3054, 1), true, CONST_SLOT_WHEREEVER)
		player:addItemEx(Game.createItem(12785, 1), true, CONST_SLOT_WHEREEVER)
		player:addMapMark({ x = 32000, y = 32139, z = 7 }, MAPMARK_GREENSOUTH, "Wasps' Nest")
	end
)

-- Mission 11: Decline
mission11:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_23",
	reset = true,
})

-- Mission 11: Confirm - Lost Flask (Having it)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_24",
	ungreet = true,
}, function(player)
	return (player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 1 or player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 2) and player:getItemCount(12785) > 0
end)

-- Mission 11: Confirm - Lost Flask (Without having it)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_25",
	ungreet = true,
}, function(player)
	return (player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 1 or player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 2) and player:getItemCount(12785) == 0
end, function(player)
	player:addItemEx(Game.createItem(12785, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 11: Decline - Lost Flask
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_26",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 1 or player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 2
end)

-- Mission 11: Finish - Confirm Give (Wasp poison flask, having it)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_59",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 3 and player:getItemCount(12784) > 0
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, 4)
	player:removeItem(12784, 1)
	player:addItemEx(Game.createItem(7644, 1), true, CONST_SLOT_WHEREEVER)
	player:addExperience(150, true)
end)

-- Mission 11: Finish - Decline Give (Wasp poison flask)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_27",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 3
end)

-- Mission 11: Finish - Confirm Give (Wasp poison flask, without having it)
local mission11Reset = keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_28",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 3 and player:getItemCount(12784) == 0
end)

-- Mission 11: Confirm - Reset Mission
mission11Reset:addChildKeyword(
	{ "yes" },
	StdModule.say,
	{
		npcHandler = npcHandler,
		i18nKey = "npc.vascalir.stdmod_29",
		ungreet = true,
	},
	nil,
	function(player)
		player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, 1)
		player:addItemEx(Game.createItem(12785, 1), true, CONST_SLOT_WHEREEVER)
	end
)

-- Mission 11: Decline - Reset Mission
mission11Reset:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_30",
	ungreet = true,
})

-- Mission 11: Finish - Accept Reward (Brass shield)
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_31",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 4
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, 5)
	player:addItemEx(Game.createItem(3411, 1), true, CONST_SLOT_WHEREEVER)
end)

-- Mission 11: Finish - Reject Reward (Brass shield)
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_32",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 4
end)

-- Mission 12: Accept
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_60",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyDoor, 1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.OrcFortressChests, 0)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.KraknaknorkChests, 0)
	player:addMapMark({ x = 31976, y = 32156, z = 7 }, MAPMARK_SKULL, "Orc Fortress")
end)

-- Mission 12: Decline
keywordHandler:addKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_33",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11) == 5 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) == -1
end)

-- Mission 12: Finish - Confirm/Decline
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_61",
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12) == 14
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, 15)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline, 2)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.AcademyDoor, -1)
end)
keywordHandler:addAliasKeyword({ "no" })

-- Missions: Confirm - Continue (Level 8)
keywordHandler:addKeyword({ "continue" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_34",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline) == 1 and player:getLevel() == 8 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Level8Warning) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Level8Warning, 1)
end)

-- Missions: Confirm - Delete (Level 8)
keywordHandler:addKeyword({ "delete" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.vascalir.stdmod_35",
	ungreet = true,
}, function(player)
	return player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline) == 1 and player:getLevel() == 8 and player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Level8Warning) == -1
end, function(player)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Questline, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission01, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission02, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission03, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission04, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission05, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission06, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission07, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission09, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission10, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission11, -1)
	player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission12, -1)
end)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.vascalir.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.vascalir.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
