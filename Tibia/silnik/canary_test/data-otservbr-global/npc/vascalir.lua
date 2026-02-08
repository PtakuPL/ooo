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
	text = {
		"Have you ever heard of Kraknaknork? He's a powerful orc shaman who has recently risen from the orc tribe and started to terrorise Rookgaard. Maybe we can kill several birds with one stone. Listen: ...",
		"What would you say about you defeat Kraknaknork, save Rookgaard and earn some experience and better equipment on the way? Sounds good?",
	},
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
		text = {
			"Great. We best start by reinforcing our defences. There are four large catapults positioned on roofs high over the village. If you want to fight, you have to build up some muscles. ...",
			"Go into the barn just a few steps to the north-west of here and down the ladder into the cellar. You'll find a huge stone pile down there. Use it to pick up one of the big stones. ...",
			"They are really heavy, so make sure you have lots of space in your inventory. ...",
			"Carry one stone to at least two of the four catapults located on Norma's roof to the north, this academy and Obi's roof to the south. ...",
			"Use the stone on the catapult to load it. You can load each catapult only once, so try spotting two different catapults. Have you understood all of that?",
		},
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
	text = {
		"Let me explain again then. We best start by reinforcing our defences. There are four large catapults positioned on roofs high over the village. If you want to fight, you have to build up some muscles. ...",
		"Go into the barn just a few steps to the north-west of here and down the ladder into the cellar. You'll find a huge stone pile down there. Use it to pick up one of the big stones. ...",
		"Carry one stone to at least two of the four catapults located on Norma's roof to the north, this academy and Obi's roof to the south. ...",
		"Use the stone on the catapult to load it. You can load each catapult only once, so try spotting two different catapults. Have you understood all of that?",
	},
	moveup = 1,
})

-- Mission 2: Finish - Confirm
keywordHandler:addKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Well done! The villagers are much safer now that the catapults are ready to fire. You also look like you've built some muscles. ...",
		"Great - so the piece of equipment I just gave you will not go to waste. Take this studded shield and put it to good use! ...",
		"Actually I have some more equipment I could give to you, but first I want to see how you fight. You have fought before, haven't you?",
	},
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
	text = {
		"Ah, that came with confidence. Suited monsters to do some basic fighting would be rats - they actually fight back, but they don't hit that hard. Just make sure you wear your new studded shield and a sword. ...",
		"You can find rats in the sewers. In case you might think so, this task is not a lame excuse to help us with some rat infestation, we got the rat population quite under control. ...",
		"Also please don't come carrying their dead bodies - what adventurers somehow tend to do for some reason. Maybe they think they're cats? I'm going to believe you, promise. ...",
		"So, back to the topic - please kill 5 rats and then come back to me. Shouldn't be too hard, should it? Just pay attention they don't trap you in a narrow passage and take on one at a time. ...",
		"If you run low on health, go on full defence - click the little shield icon - and leave the dungeon. Nothing corwardish about running, because dying hurts. Are you ready to go?",
	},
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
		text = {
			"Nice. I've marked two rat dungeons on your map. Kill 5 rats and return to me. If you should happen to forget how many you have killed in the meantime, simply check your questlog. ...",
			"I should also give you a small word of warning - once you reach level 8, you should leave this island. Thus you won't be able to continue this quest once you've reached level 9. ...",
			"It's not good to reach level 9 without having chosen a vocation - you'll be weaker than normal. ...",
			"No need to be scared, just saying you don't need to plan large hunting sessions while helping me with this mission or kill more rats than I've asked you to. So, good hunting!",
		},
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
	text = {
		"I'll explain it again then. Suited monsters to do some basic fighting would be rats - they actually fight back, but they don't hit that hard. Just make sure you wear your new studded shield and a sword. ...",
		"You can find rats in the sewers. In case you might think so, this task is not a lame excuse to help us with some rat infestation, we got the rat population quite under control. ...",
		"So, back to the topic - please kill 5 rats and then come back to me. Shouldn't be too hard, should it? Just pay attention they don't trap you in a narrow passage and take on one at a time. ...",
		"If you run low on health, go on full defence - click the little shield icon - and leave the dungeon. Nothing corwardish about running, because dying hurts. Are you ready to go?",
	},
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
	text = {
		"Good job. Here's your promised reward - a sabre. You can replace your wooden sword with it, if you still have it - the sabre does more damage. ...",
		"If you look at a piece of equipment, you can check its stats. By the way, if you use sword weapons such as sabres or swords, you are training your 'sword fighting skill'. ...",
		"This is quite important if you plan on becoming a melee fighter - the better your sword fighting skill, the higher the damage you do will be. ...",
		"There are also club and axe type weapons - they train different skills, so maybe you should choose one type of weapon you always want to use. It doesn't make that much difference, but swords often have a good balance between offence and defence. ...",
		"Anyway, I think you're well enough equipped now to leave the village of Rookgaard for another small task. Find Lily south-west of here, she will tell you what she needs done.",
	},
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
	text = {
		"That's the spirit Rookgaard needs. Listen, while you were gone I thought about a way to weaken and fight Kraknaknork - that orc shaman who terrorises Rookgaard. ...",
		"Even if we could make our way into his stronghold past all his minions, we cannot hope to defeat him as long as he is powerful enough to summon demons and access other dimensions. ...",
		"While studying the fauna of Rookgaard I came across an interesting specimen that might help us in our battle. Deep in the underground tunnels, there is a spider queen - a tarantula, who is bigger and deadlier than all the other spiders here. ...",
		"Her web is enormous - and causes a strong paralysis. If you could get a small sample of her web, I might be able to craft a trap that we can use to paralyse the orcs so you can get past their defences. ...",
		"Do you dare sneak into the tarantula's lair and retrieve a sample of her web?",
	},
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
	text = {
		"That's very courageous. I'll mark the spider lair on your map. If you leave the village to the north again like before, but walk north-west and cross the bridge, you will find it. ...",
		"Listen, I have some more important information regarding your task. It will likely be dark in the cave, so maybe you'll want to buy a torch or two from Al Dee's shop to the left of the barn. ...",
		"The spider queen is far too strong for you to fight and if she catches you, you might end up in her stomach. The good news is that she is almost blind and relies on her sense of smelling to find her prey. ...",
		"Deep in her lair you'll find some blue greasy stones. If you use them, you'll rub some of the smelly grease on your body. From that moment on you'll be invisible to her, but only for a short time. ...",
		"If you run into her lair, you should have enough time to retrieve a sample of her web before she catches you. Just USE one of her intact cobwebs in her lair. Good luck!",
	},
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
	text = {
		"Time is of the essence now. The library vault is on fire! It's where Rookgaard's oldest and most important books are stored. ...",
		"The trolls from the northern ruins somehow found their way into the vault by digging a tunnel from the other side and set everything on fire. ...",
		"You HAVE to go down there and look for our copy of the book of orc language - while I'm thinking of a reason why I can't go myself. ...",
		"Just kidding, I need to find out just how the trolls got in there before they wreak more havoc. I think there's something bigger behind all this. ...",
		"The vault is likely set on fire - be careful down there, and don't run into open fire, it can and will hurt you. There should be a rune in the vault that can at least weaken fire, just in case. ...",
		"Are you ready to go?",
	},
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
		text = {
			"You can find the vault if you go down the stairs in the northern part of the academy. The book should be in a large blue chest somewhere down there - I hope it's not burnt yet. ...",
			"Make sure you're healthy - if you are wounded, ask Cipfried in the temple for a healing first. Good luck!",
		},
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
	text = {
		"What happened, you say? The book was already burnt to ashes? That's too bad... well, you deserve a reward for your courage anyway. Thanks for at least trying. ...",
		"I was trying to figure out a way to get into the orc fortress by maybe using their language... but that won't work now I fear. ...",
		"We do have to stop the trolls though before taking care of the orcs. I found their tunnel in the northern ruins. Are you prepared for your next mission?",
	},
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
	text = {
		"Great job down there! You do deserve a reward for your courage. Here is a platinum coin for you, worth 100 gold coins. Let me take a look at the book... ...",
		"Argh... the pages are barely readable anymore. I was trying to figure out a way to get into the orc fortress by maybe using their language... but that won't work now I fear. ...",
		"We do have to stop the trolls though before taking care of the orcs. I found their tunnel in the northern ruins. Are you prepared for your next mission?",
	},
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
	text = {
		"Oh, but you have it! <snags it from you> Great job down there! You do deserve a reward for your courage. Here is a platinum coin for you, worth 100 gold coins. Let me take a look at the book... ...",
		"Argh... the pages are barely readable anymore. I was trying to figure out a way to get into the orc fortress by maybe using their language... but that won't work now I fear. ...",
		"We do have to stop the trolls though before taking care of the orcs. I found their tunnel in the northern ruins. Are you prepared for your next mission?",
	},
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
	text = {
		"First things first. I think by now you should have gathered some money, and it's better to play things safely instead of rushing into the trolls' lair. You might have seen the Bank of Rookgaard downstairs. ...",
		"Each Tibian inhabitant has a bank account where you can store your money safely - so in case you die, you won't lose it. ...",
		"You don't have to worry about item loss here on Rookgaard, but as soon as you grow stronger and learn a vocation, it can happen to you that you lose some of your items when dying. ...",
		"It's probably safer to get used to depositing all of your money on your bank account before you leave for a hunt. ...",
		"Go downstairs and talk to Paulie. I'm sure he can explain to you everything you need to know, and he might also give you a small bonus for your account.",
	},
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
	text = {
		"Very well. What I know is the following: somewhere in the northern ruins, the trolls have found a way to dig a tunnel that leads to the library vault. That's how they were able to set fire to it. ...",
		"You need to discover that tunnel and find a way to make it collapse. Maybe you're able to use some of the trolls' tools. Make sure that they can't enter the village via that tunnel anymore! ...",
		"And please don't hurt yourself in the process. You'll probably have to fight them, so bring food and maybe a potion. If you need to buy something, don't forget that you can withdraw money from your bank account. Good luck!",
	},
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
	text = {
		"Now that we got rid of the troll threat, it's about time we get back to the imminent danger coming from the orc side of Rookgaard. The spider web you retrieved was only the first step - I've thought of something else. ...",
		"To infiltrate the orc fortress, we're going to make use of a technique I've learnt on the battlefield - distraction! I'll explain the plan to you when everything's ready, but for now I have a small favour to ask. ...",
		"Please go to the graveyard east of the village, enter the crypt and retrieve a bone. Now I know this is a little morbid, but it would be best if it still had some meat on it. ...",
		"The graveyard hasn't been used by the villagers for a long time. It's cursed - skeletons are roaming around, so be careful. Take this garlic necklace just in case. ...",
		"Undead monsters tend to drain your life - because their own life force is gone. If you wear it, you'll be protected from it. Search around in the coffins in the crypt, one of them should hold a nice fleshy bone. See you soon!",
	},
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
	text = {
		"Please go to the graveyard east of the village, enter the crypt and retrieve a bone. Now I know this is a little morbid, but it would be best if it still had some meat on it. ...",
		"The graveyard hasn't been used by the villagers for a long time. It's cursed - skeletons are roaming around, so be careful. ...",
		"Undead monsters tend to drain your life - because their own life force is gone. If you wear the garlic necklace I gave you, you'll be protected from it. Search around in the coffins in the crypt, one of them should hold a nice fleshy bone. See you soon!",
	},
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
	text = {
		"I'm happy to hear that! <whistles> We already have the paralyse trap and the fleshy bone, and now we need one final ingredient to weaken Kraknaknork so that you stand a chance against him. ...",
		"Wasp poison! There are many toxic creatures - like snakes or poison spiders - but none is as deadly as the wasp. At least none on Rookgaard. If we could poison Kraknaknork with it, I think he won't be able to make use of his spells for quite a while. ...",
		"The only problem is - to get it, you need to get close to a wasp, kill it and extract some poison from its dead body. Wasps are located on the north-western side of Rookgaard, which is quite dangerous. ...",
		"However, I can give you something for protection - a silver amulet. As long as you wear it, poison can't harm you as much as it usually would do. I'll also give you the flask which you have to use on a fresh, dead wasp. Are you prepared for that mission?",
	},
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
	text = {
		"|PLAYERNAME|, I must say I'm impressed. Not everyone would dare go into that region of Rookgaard and face creatures as strong as wasps. Wait, let me give something to you... ...",
		"Here, with a drop of the wasp poison this potion turned into an effective antidote. Should you get poisoned again and are losing a lot of health, use the antidote potion to cure yourself. ...",
		"There is also a rune and a spell to remove poison available once you leave this island and arrive on the mainland. It's always good to protect yourself! ...",
		"And I have a good shield for you, too. Here, can you carry it?",
	},
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
	text = {
		"The air smells like victory today. I've kept the items you brought from your journeys safe - the time has come to use them. ...",
		"Enter the small treasure room under the academy - just down the stairs and to the right, near Paulie - and open the large blue chest to retrieve them. You'll find a rolling pin, the fleshy bone, the wasp poison and a tarantula trap. ...",
		"Now let me explain the plan in detail. Go to the orc fortress - you've already been nearby when hunting for the wasp poison, it's the same way, but I'll mark it on your map just in case. ...",
		"There you will have to find a way to sneak past the guards, they are much too strong for you. The rolling pin might come in handy during that part. Afterwards, the fleshy bone will help to create a distraction to get into the fortress. ...",
		"Once you're inside the fortress, find the orc kitchen and pour the wasp poison into Kraknaknork's soup! The tarantula trap will come in handy if you meet a guard who might seem simply too fast for you. You can use it on him to slow him down. ...",
		"|PLAYERNAME|, take the items and go claim your victory. I know you will do us proud. Good luck!",
	},
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
	text = {
		"You DID kill him indeed! Incredible! This little village can finally live in peace again - and you've grown so strong, too. I'm proud of you, |PLAYERNAME|. My work here is done, and yours too. Thank you for all you've done for us. ...",
		"Now all that is left for you to do here is to talk to the oracle above the academy and travel to the Isle of Destiny. There, you will determine your future - which I'm sure is a bright one. ...",
		"What will become of you? A mighty sorcerer? A fierce knight? A skilled paladin? Or a powerful druid? Only you can decide. ...",
		"Rookgaard will miss you, but the whole world of Tibia is open to you now. Take care, |PLAYERNAME|. It's good to know you.",
	},
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
