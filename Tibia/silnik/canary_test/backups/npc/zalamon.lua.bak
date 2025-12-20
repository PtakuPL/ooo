local internalNpcName = "Zalamon"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 115,
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

local marks = {
	ChildrenOfTheRevolution = {
		{ position = Position(33235, 31177, 7), type = 4, description = "entrance of the camp" },
		{ position = Position(33257, 31172, 7), type = 3, description = "building 1 which you have to spy" },
		{ position = Position(33227, 31163, 7), type = 3, description = "building 2 which you have to spy" },
		{ position = Position(33230, 31156, 7), type = 3, description = "building 3 which you have to spy" },
	},
	WrathOfTheEmperor = {
		{ position = Position(33356, 31180, 7), description = "tunnel to hideout" },
		{ position = Position(33173, 31076, 7), description = "the rebel hideout" },
	},
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		-- CHILDREN OF REVOLUTION QUEST
		if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_98")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_99")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_1")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_94")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_95")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_96")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_97")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_91")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_92")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_93")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission01, 3) --Questlog, Children of the Revolution "Mission 1: Corruption"
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_86")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_87")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_88")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_89")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_90")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 7 then
			if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding01) == 1 and player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding02) == 1 and player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.SpyBuilding03) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_84")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_85")
				player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 8)
				player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission02, 5) --Questlog, Children of the Revolution "Mission 2: Imperial Zzecret Weaponzz"
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_81")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_82")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_83")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_79")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_80")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 12)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission03, 3) --Questlog, Children of the Revolution "Mission 3: Zee Killing Fieldzz"
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_77")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_78")
			npcHandler:setTopic(playerId, 10)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_75")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_76")
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_72")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_73")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_74")
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_67")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_68")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_69")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_70")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_71")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 21)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission05, 3) --Questlog, Children of the Revolution "Mission 5: Phantom Army"
			player:addItem(10199, 1)
			player:addExperience(10000, true)
			npcHandler:setTopic(playerId, 0)
			-- CHILDREN OF REVOLUTION QUEST

			-- WRATH OF THE EMPEROR QUEST
		elseif player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 21 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_65")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_66")
			npcHandler:setTopic(playerId, 14)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_2")
			npcHandler:setTopic(playerId, 16)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_60")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_61")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_62")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_63")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_64")
			npcHandler:setTopic(playerId, 19)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_3")
			npcHandler:setTopic(playerId, 20)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_50")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_52")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_54")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_55")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_56")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_57")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_58")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_59")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 10)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission04, 1) --Questlog, Wrath of the Emperor "Mission 04: Sacrament of the Snake"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_4")
			npcHandler:setTopic(playerId, 21)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_45")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_48")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_49")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 13)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission05, 1) --Questlog, Wrath of the Emperor "Mission 05: New in Town"
			npcHandler:setTopic(playerId, 0)
			-- WRATH OF THE EMPEROR QUEST
		end

		-- WRATH OF THE EMPEROR QUEST
	elseif MsgContains(message, "crate") then
		if npcHandler:getTopic(playerId) == 17 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_5")
			npcHandler:setTopic(playerId, 18)
		end
		-- WRATH OF THE EMPEROR QUEST

		-- CHILDREN OF REVOLUTION QUEST
	elseif MsgContains(message, "symbols") then
		if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.StrangeSymbols) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_43")
			npcHandler:setTopic(playerId, 11)
		end
		-- CHILDREN OF REVOLUTION QUEST
	elseif MsgContains(message, "poison") or MsgContains(message, "poizzon") then
		if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_6")
			npcHandler:setTopic(playerId, 0)
		end
		-- CHILDREN OF REVOLUTION QUEST
	elseif MsgContains(message, "yes") then
		-- CHILDREN OF REVOLUTION QUEST
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_38")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_40")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_41")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_7")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission00, 1) --Questlog, Children of the Revolution "Prove Your Worzz!"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_8")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(637, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_34")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_35")
				player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 3)
				player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission00, 2) --Questlog, Children of the Revolution "Prove Your Worzz!"
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_9")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 4)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission01, 1) --Questlog, Children of the Revolution "Mission 1: Corruption"
			player:addMapMark(Position(33177, 31193, 7), 5, "Temple of Equilibrium")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_33")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 7)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission02, 1) --Questlog, Children of the Revolution "Mission 2: Imperial Zzecret Weaponzz"
			for i = 1, #marks.ChildrenOfTheRevolution do
				local mark = marks.ChildrenOfTheRevolution[i]
				player:addMapMark(mark.position, mark.type, mark.description)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_31")
			npcHandler:setTopic(playerId, 8)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_28")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 9)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission03, 1) --Questlog, Children of the Revolution "Mission 3: Zee Killing Fieldzz"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_26")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 13)
			if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission04) <= 1 then
				player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission04, 1) --Questlog, Children of the Revolution "Mission 4: Zze Way of Zztonezz"
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_24")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.StrangeSymbols, 2)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission04, 3) --Questlog, Children of the Revolution "Mission 4: Zze Way of Zztonezz"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_21")
			player:addItem(10217, 1)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 18)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission04, 6) --Questlog, Children of the Revolution "Mission 4: Zze Way of Zztonezz"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_18")
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.teleportAccess, 1)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 19)
			player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Mission05, 1) --Questlog, Children of the Revolution "Mission 5: Phantom Army"
			npcHandler:setTopic(playerId, 0)
			-- CHILDREN OF REVOLUTION QUEST

			-- WRATH OF THE EMPEROR QUEST
		elseif npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_16")
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_12")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission01, 1) --Questlog, Wrath of the Emperor "Mission 01: Catering the Lions Den"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_9")
			npcHandler:setTopic(playerId, 17)
		elseif npcHandler:getTopic(playerId) == 18 then
			if player:getItemCount(953) >= 3 and player:getItemCount(5901) >= 1 then
				player:removeItem(5901, 1)
				player:removeItem(953, 3)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 2)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission01, 2) --Questlog, Wrath of the Emperor "Mission 01: Catering the Lions Den"
				player:addItem(11328, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_7")
				for i = 1, #marks.WrathOfTheEmperor do
					local mark = marks.WrathOfTheEmperor[i]
					player:addMapMark(mark.position, 19, mark.description)
				end
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.multi_2")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 7)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission03, 1) --Questlog, Wrath of the Emperor "Mission 03: The Keeper"
			player:addItem(11364, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 20 then
			if player:removeItem(11367, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_10")
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 9)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission03, 3) --Questlog, Wrath of the Emperor "Mission 03: The Keeper"
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 21 then
			if player:removeItem(11371, 1) then
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 12)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission04, 3) --Questlog, Wrath of the Emperor "Mission 04: Sacrament of the Snake"
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zalamon.say_11")
				npcHandler:setTopic(playerId, 0)
			end
			-- WRATH OF THE EMPEROR QUEST
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Not many travellerzz zzezze dayzz. I hope you bring good newzz.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
