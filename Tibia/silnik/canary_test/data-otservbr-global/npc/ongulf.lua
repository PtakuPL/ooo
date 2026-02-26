local internalNpcName = "Ongulf"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 70,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{
		i18nKey = "npc.ongulf.voice_1",
	},
	{
		i18nKey = "npc.ongulf.voice_2",
	},
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "project") and player:getStorageValue(TheNewFrontier.Questline) < 1 then
		if npcHandler:getTopic(playerId) == 0 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_6", "npc.ongulf.say_7" })
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "long") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_8", "npc.ongulf.say_9", "npc.ongulf.say_10", "npc.ongulf.say_11", "npc.ongulf.say_12", "npc.ongulf.say_13", "npc.ongulf.say_14", "npc.ongulf.say_15", "npc.ongulf.say_16", "npc.ongulf.say_17", "npc.ongulf.say_18", "npc.ongulf.say_19", "npc.ongulf.say_20", "npc.ongulf.say_21" })
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "short") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_22", "npc.ongulf.say_23" })
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "mission") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(TheNewFrontier.Questline) < 1 and npcHandler:getTopic(playerId) == 2 then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_24", "npc.ongulf.say_25", "npc.ongulf.say_26" })
				player:setStorageValue(TheNewFrontier.Questline, 1)
				player:setStorageValue(TheNewFrontier.Mission01, 1) -- Questlog, The New Frontier Quest "Mission 01: New Land"
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(TheNewFrontier.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_27")
			player:setStorageValue(TheNewFrontier.Questline, 3)
			player:setStorageValue(TheNewFrontier.Mission01, 3) -- Questlog, The New Frontier Quest "Mission 01: New Land"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_28", "npc.ongulf.say_29" })
			player:setStorageValue(TheNewFrontier.Questline, 4)
			player:setStorageValue(TheNewFrontier.Mission02[1], 1) -- Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_30")
			player:setStorageValue(TheNewFrontier.Questline, 7)
			player:setStorageValue(TheNewFrontier.Mission02[1], 4) -- Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 7 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_31", "npc.ongulf.say_32", "npc.ongulf.say_33", "npc.ongulf.say_34" })
			player:setStorageValue(TheNewFrontier.Questline, 8)
			player:setStorageValue(TheNewFrontier.Mission03, 1) -- Questlog, The New Frontier Quest "Mission 03: Strangers in the Night"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 9 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_35", "npc.ongulf.say_36" })
			player:setStorageValue(TheNewFrontier.Questline, 10)
			player:setStorageValue(TheNewFrontier.Mission03, 3) -- Questlog, The New Frontier Quest "Mission 03: Strangers in the Night"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 10 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_37", "npc.ongulf.say_38", "npc.ongulf.say_39" })
			player:setStorageValue(TheNewFrontier.Questline, 11)
			player:setStorageValue(TheNewFrontier.Mission04, 1) -- Questlog, The New Frontier Quest "Mission 04: The Mine Is Mine"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_40")
			player:setStorageValue(TheNewFrontier.Questline, 13)
			player:setStorageValue(TheNewFrontier.Mission04, 2) -- Questlog, The New Frontier Quest 'Mission 04: The Mine Is Mine'
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 13 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_41", "npc.ongulf.say_42", "npc.ongulf.say_43", "npc.ongulf.say_44", "npc.ongulf.say_45", "npc.ongulf.say_46", "npc.ongulf.say_47", "npc.ongulf.say_48", "npc.ongulf.say_49", "npc.ongulf.say_50", "npc.ongulf.say_51", "npc.ongulf.say_52", "npc.ongulf.say_53", "npc.ongulf.say_54", "npc.ongulf.say_55" })
			player:setStorageValue(TheNewFrontier.Questline, 14)
			player:setStorageValue(TheNewFrontier.Mission05[1], 1) -- Questlog, The New Frontier Quest "Mission 05: Getting Things Busy"
			player:setStorageValue(TheNewFrontier.Mission05.KingTibianus, 1) -- Questlog, The New Frontier Quest "Mission 5-1"
			player:setStorageValue(TheNewFrontier.Mission05.Leeland, 1) -- Questlog, The New Frontier Quest "Mission 5-2"
			player:setStorageValue(TheNewFrontier.Mission05.Angus, 1) -- Questlog, The New Frontier Quest "Mission 5-3"
			player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 1) -- Questlog, The New Frontier Quest "Mission 5-4"
			player:setStorageValue(TheNewFrontier.Mission05.Telas, 1) -- Questlog, The New Frontier Quest "Mission 5-5"
			player:setStorageValue(TheNewFrontier.Mission05.Humgolf, 1) -- Questlog, The New Frontier Quest "Mission 5-6"
			-- Setting a keyword for each NPC
			player:setStorageValue(TheNewFrontier.Mission05.LeelandKeyword, math.random(1, 2)) -- The New Frontier Quest "Mission 5-2"
			player:setStorageValue(TheNewFrontier.Mission05.AngusKeyword, math.random(1, 2)) -- The New Frontier Quest "Mission 5-3"
			player:setStorageValue(TheNewFrontier.Mission05.WyrdinKeyword, math.random(1, 4)) -- The New Frontier Quest "Mission 5-4"
			player:setStorageValue(TheNewFrontier.Mission05.TelasKeyword, math.random(1, 2)) -- The New Frontier Quest "Mission 5-5"
			player:setStorageValue(TheNewFrontier.Mission05.HumgolfKeyword, math.random(1, 2)) -- The New Frontier Quest "Mission 5-6"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 14 then
			if
				player:getStorageValue(TheNewFrontier.Mission05.KingTibianus) == 3
				and player:getStorageValue(TheNewFrontier.Mission05.Leeland) == 3
				and player:getStorageValue(TheNewFrontier.Mission05.Angus) == 3
				and player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 3
				and player:getStorageValue(TheNewFrontier.Mission05.Telas) == 3
				and player:getStorageValue(TheNewFrontier.Mission05.Humgolf) == 3
			then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_56")
				player:setStorageValue(TheNewFrontier.Questline, 15)
				player:setStorageValue(TheNewFrontier.Mission05[1], 2) -- Questlog, The New Frontier Quest "Mission 05: Getting Things Busy"
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(TheNewFrontier.Questline) == 15 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_57", "npc.ongulf.say_58", "npc.ongulf.say_59", "npc.ongulf.say_60" })
			player:setStorageValue(TheNewFrontier.Questline, 16)
			player:setStorageValue(TheNewFrontier.Mission06, 1) -- Questlog, The New Frontier Quest "Mission 06: Days Of Doom"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 19 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_61", "npc.ongulf.say_62" })
			player:setStorageValue(TheNewFrontier.Questline, 20)
			player:setStorageValue(TheNewFrontier.Mission06, 5)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 20 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_63", "npc.ongulf.say_64", "npc.ongulf.say_65" })
			player:setStorageValue(TheNewFrontier.Questline, 21)
			player:setStorageValue(TheNewFrontier.Mission07[1], 1) -- Questlog, The New Frontier Quest "Mission 07: Messengers Of Peace"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 28 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.ongulf.say_66", "npc.ongulf.say_67", "npc.ongulf.say_68", "npc.ongulf.say_69", "npc.ongulf.say_70", "npc.ongulf.say_71", "npc.ongulf.say_72" })
			player:addExperience(8000, true)
			player:setStorageValue(TheNewFrontier.Questline, 29)
			player:setStorageValue(TheNewFrontier.Mission10[1], 2) -- Questlog, "Mission 10: New Horizons"
			player:setStorageValue(TheNewFrontier.Mission10.MagicCarpetDoor, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello, |PLAYERNAME|. You've come at a good time for our {project}.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
