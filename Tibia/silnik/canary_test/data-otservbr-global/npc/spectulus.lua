local internalNpcName = "Spectulus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 0,
	lookBody = 77,
	lookLegs = 78,
	lookFeet = 97,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.spectulus.voice_1" },
	{ i18nKey = "npc.spectulus.voice_2" },
	{ i18nKey = "npc.spectulus.voice_3" },
	{ i18nKey = "npc.spectulus.voice_4" },
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

	if player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) < 10 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.spectulus.greet_msg_1")
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.spectulus.greet_msg_2")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "research") and player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 11 then
		local qStorage = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01)
		local tombsStorage = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.TombUse)
		if qStorage == -1 then
			if npcHandler:getTopic(playerId) == 17 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_82")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_83")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_84")
				npcHandler:setTopic(playerId, 18)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_80")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_81")
				npcHandler:setTopic(playerId, 12)
			end
		elseif qStorage == 1 and tombsStorage >= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_1")
			npcHandler:setTopic(playerId, 19)
		elseif qStorage == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_78")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_79")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_3")
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 2 then
			if not player:removeItem(9696, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_4")
				return true
			end

			player:addExperience(400, true)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 3)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission1, 3)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.StudyTimer, os.time() + 1800)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 3 then
			local timeStorage = player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.StudyTimer)
			if timeStorage > os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_6")
			elseif timeStorage > 0 and timeStorage < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_7")
				npcHandler:setTopic(playerId, 2)
			end
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_8")
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 5 then
			if player:getItemCount(9697) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_9")
				return true
			end
			player:addExperience(500, true)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission2, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_76")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_77")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_10")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_11")
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_12")
		elseif player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 9 then
			if player:getItemCount(9699) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_13")
				return true
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_14")
			npcHandler:setTopic(playerId, 7)
		elseif (player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) == 10) and (player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) < 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_15")
			npcHandler:setTopic(playerId, 27)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_16")
			npcHandler:setTopic(playerId, 30)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_17")
			npcHandler:setTopic(playerId, 32)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_18")
			npcHandler:setTopic(playerId, 33)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_19")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_68")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_69")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_70")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_71")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_72")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_73")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_74")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_75")
			player:addExperience(6000, true)
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 10)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline) < 1 then
			player:addExperience(100, true)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission1, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_66")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_67")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_20")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_21")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 4)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission1, 4)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission2, 1)
			player:addMapMark(Position(33103, 31811, 7), MAPMARK_CROSS, "Lost Mines")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_64")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_65")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_22")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 7)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission3, 1)
			player:addItem(9698, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_23")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if not player:removeItem(9699, 1) then
				-- Original was empty say("") - NPC says nothing
				npcHandler:setTopic(playerId, 0)
				return true
			end
			player:addItem(3028, 10)
			player:addItem(3037, 1)
			player:addExperience(1000, true)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission3, 4)
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 10)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_58")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_59")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_60")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_61")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_62")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_63")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_24")
			npcHandler:setTopic(playerId, 13)
		elseif npcHandler:getTopic(playerId) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_25")
			npcHandler:setTopic(playerId, 14)
		elseif npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_56")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_57")
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_54")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_55")
			npcHandler:setTopic(playerId, 17)
		elseif npcHandler:getTopic(playerId) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_26")
			player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 1)
			player:addItem(4049, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_27")
			player:addExperience(500, true)
			player:addItem(3035, 5)
			player:setStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01, 2)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_48")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_49")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_50")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_52")
			npcHandler:setTopic(playerId, 28)
		elseif npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_39")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_40")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_41")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_42")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_43")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_45")
			npcHandler:setTopic(playerId, 29)
		elseif npcHandler:getTopic(playerId) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_38")
			player:setStorageValue(Storage.Quest.U8_54.SeaOfLight.Questline, 11)
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_28")
			npcHandler:setTopic(playerId, 31)
		elseif npcHandler:getTopic(playerId) == 31 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_35")
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 3)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_32")
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_28")
			player:setStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine, 7)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "jack") then
		if player:getStorageValue(Storage.Quest.U8_7.JackFutureQuest.QuestLine) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_25")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "collective apparitions") then
		local qStorage = player:getStorageValue(Storage.Quest.U8_7.SpiritHunters.Mission01)
		if qStorage == -1 then
			if npcHandler:getTopic(playerId) == 15 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_29")
				npcHandler:setTopic(playerId, 16)
			end
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_30")
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_31")
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_32")
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_33")
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_34")
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_35")
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_36")
		end
		npcHandler:setTopic(playerId, 0)
	end

	if MsgContains(message, "machine") and player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_20")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_21")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_22")
		npcHandler:setTopic(playerId, 21)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 21 and player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
		if player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_18")
			npcHandler:setTopic(playerId, 22)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 22 and player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
		if player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_12")
			npcHandler:setTopic(playerId, 23)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 23 and player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
		if player:getStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_37")
			player:setStorageValue(Storage.Quest.U9_4.LiquidBlackQuest.Visitor, 4)
			npcHandler:setTopic(playerId, 24)
		end
	elseif MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U8_54.SeaOfLight.Mission3) == 4 then
		end
	end

	if MsgContains(message, "rumours") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_8")
		npcHandler:setTopic(playerId, 25)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_38")
			if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline) < 1 then
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline, 1)
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "njey") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_5")
		npcHandler:setTopic(playerId, 26)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.multi_3")
			npcHandler:setTopic(playerId, 34)
		elseif npcHandler:getTopic(playerId) == 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.spectulus.say_39")
			if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline) < 4 then
				player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.LiquidDeath.Questline, 4)
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

keywordHandler:addKeyword({ "device" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_1",
})
keywordHandler:addKeyword({ "lightboat" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_2",
})
keywordHandler:addKeyword({ "magic device" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_3",
})
keywordHandler:addKeyword({ "sea of light" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_4",
})
keywordHandler:addKeyword({ "mirror crystal" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_5",
})
keywordHandler:addKeyword({ "lost mines" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_6",
})
keywordHandler:addKeyword({ "collector" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.spectulus.stdmod_7",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.spectulus.greet_msg_3")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.spectulus.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.spectulus.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
