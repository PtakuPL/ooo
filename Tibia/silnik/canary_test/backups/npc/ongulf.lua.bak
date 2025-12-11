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
		text = "Great, another supply ship is due. How is a dwarf supposed to work under these conditions?",
	},
	{
		text = "Ah, there's nothing like the sound of hammers in the morning.",
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
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_60")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_61")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "long") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_48")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_49")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_50")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_52")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_54")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_55")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_56")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_57")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_58")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_59")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "short") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_45")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "mission") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(TheNewFrontier.Questline) < 1 and npcHandler:getTopic(playerId) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_41")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_42")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_43")
				player:setStorageValue(TheNewFrontier.Questline, 1)
				player:setStorageValue(TheNewFrontier.Mission01, 1) -- Questlog, The New Frontier Quest "Mission 01: New Land"
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(TheNewFrontier.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_1")
			player:setStorageValue(TheNewFrontier.Questline, 3)
			player:setStorageValue(TheNewFrontier.Mission01, 3) -- Questlog, The New Frontier Quest "Mission 01: New Land"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_40")
			player:setStorageValue(TheNewFrontier.Questline, 4)
			player:setStorageValue(TheNewFrontier.Mission02[1], 1) -- Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_2")
			player:setStorageValue(TheNewFrontier.Questline, 7)
			player:setStorageValue(TheNewFrontier.Mission02[1], 4) -- Questlog, The New Frontier Quest "Mission 02: From Kazordoon With Love"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_35")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_38")
			player:setStorageValue(TheNewFrontier.Questline, 8)
			player:setStorageValue(TheNewFrontier.Mission03, 1) -- Questlog, The New Frontier Quest "Mission 03: Strangers in the Night"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_34")
			player:setStorageValue(TheNewFrontier.Questline, 10)
			player:setStorageValue(TheNewFrontier.Mission03, 3) -- Questlog, The New Frontier Quest "Mission 03: Strangers in the Night"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_32")
			player:setStorageValue(TheNewFrontier.Questline, 11)
			player:setStorageValue(TheNewFrontier.Mission04, 1) -- Questlog, The New Frontier Quest "Mission 04: The Mine Is Mine"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_3")
			player:setStorageValue(TheNewFrontier.Questline, 13)
			player:setStorageValue(TheNewFrontier.Mission04, 2) -- Questlog, The New Frontier Quest 'Mission 04: The Mine Is Mine'
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_29")
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
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_4")
				player:setStorageValue(TheNewFrontier.Questline, 15)
				player:setStorageValue(TheNewFrontier.Mission05[1], 2) -- Questlog, The New Frontier Quest "Mission 05: Getting Things Busy"
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(TheNewFrontier.Questline) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_14")
			player:setStorageValue(TheNewFrontier.Questline, 16)
			player:setStorageValue(TheNewFrontier.Mission06, 1) -- Questlog, The New Frontier Quest "Mission 06: Days Of Doom"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.say_5")
			player:setStorageValue(TheNewFrontier.Questline, 20)
			player:setStorageValue(TheNewFrontier.Mission06, 5)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_10")
			player:setStorageValue(TheNewFrontier.Questline, 21)
			player:setStorageValue(TheNewFrontier.Mission07[1], 1) -- Questlog, The New Frontier Quest "Mission 07: Messengers Of Peace"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ongulf.multi_7")
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
