local internalNpcName = "Omrabas"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 3114,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Typical. Easy come, easy go." },
	{ text = "He will PAY for this... They will ALL pay!" },
	{ text = "<groan>" },
	{ text = "If I ever lay hands on him again..." },
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.QuestStart) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_1")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.QuestStart, 1)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission01) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission02) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission02) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission03) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_3")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission03, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission03) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission04) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_4")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission04) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission05) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission05, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_127")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_128")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_129")
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission06) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission07) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_125")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_126")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission07) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission08) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission08, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_123")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_124")
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission09) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission10) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission10) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission11) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission11, 1)
			player:addItem(19085, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_121")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_122")
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission12) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission13) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_6")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission13) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission14) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_116")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_117")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_118")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_119")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_120")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission15) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission16) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_7")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission16, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission16) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_112")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_113")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_114")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_115")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission18) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_109")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_110")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_111")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission20) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission21) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_107")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_108")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission21, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission21) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission22) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_105")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_106")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission22, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission25) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission26) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission26, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_103")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_104")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission29) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission30) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_101")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_102")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission30, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission33) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission34) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission34, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_99")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_100")
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission42) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_8")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_96")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_97")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_98")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission50) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_9")
			npcHandler:setTopic(playerId, 12)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_93")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_94")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_95")
			player:addItem(19173, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission57) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_10")
			npcHandler:setTopic(playerId, 13)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59) < 1 then
			player:addItem(19148, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_89")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_90")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_91")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_92")
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission64) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission65) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_11")
			player:addItem(19148, 1)
			npcHandler:setTopic(playerId, 14)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission65) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission66) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_83")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_84")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_85")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_86")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_87")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_88")
			player:addItem(19148, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission66, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission72) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission73) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_12")
			npcHandler:setTopic(playerId, 16)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission75) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission76) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_79")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_80")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_81")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_82")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission76, 1)
			player:addItem(19136, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.QuestStart) == 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission01, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_76")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_77")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_78")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission01) == 1 then
			if player:removeItem(11467, 2) then
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission02, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_13")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_14")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission03) == 1 then
			if player:removeItem(9647, 2) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_15")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission04, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_16")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission06) == 1 then
			if player:removeItem(19077, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_17")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission07, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_18")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission09) == 1 then
			if player:removeItem(19078, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_19")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission10, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_20")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission12) == 1 then
			if player:removeItem(19086, 1) then
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission13, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_74")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_75")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_21")
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission22) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission23) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_70")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_71")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_72")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_73")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission23, 1)
		elseif npcHandler:getTopic(playerId) == 9 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission26) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission27) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_66")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_67")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_68")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_69")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission27, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 10 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission34) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission35) < 1 then
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission35, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_63")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_64")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_65")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission42) == 1 then
			if player:removeItem(18933, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_22")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_23")
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_60")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_61")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_62")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44, 1)
		elseif npcHandler:getTopic(playerId) == 12 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission50) == 1 then
			if player:removeItem(18933, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_24")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_25")
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_57")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_58")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_59")
			player:addItem(19173, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52, 1)
		elseif npcHandler:getTopic(playerId) == 13 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission57) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) < 1 then
			if player:removeItem(18933, 1) then
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_55")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_56")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_26")
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59) < 1 then
			player:addItem(19148, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_51")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_52")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_53")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_54")
		elseif npcHandler:getTopic(playerId) == 15 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission68) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission69) < 1 then
			if player:removeItem(18933, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_49")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_50")
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission69, 1)
				npcHandler:setTopic(playerId, 17)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_27")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 17 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission69) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission70) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_43")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_44")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_45")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_46")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_47")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_48")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission70, 1)
		elseif npcHandler:getTopic(playerId) == 18 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission71) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission72) < 1 then
			if player:removeItem(18933, 1) then
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission72, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_39")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_40")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_41")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_42")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_28")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 19 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission73) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission74) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_36")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_37")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_38")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission74, 1)
			player:addItem(18934, 1)
			player:addItem(19160, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "demonic skeletal hands") or MsgContains(message, "demonic skeletal hand") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_29")
	elseif MsgContains(message, "give") and npcHandler:getTopic(playerId) == 4 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission06) == 1 then
		if player:removeItem(19077, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_30")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission07, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_31")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "undertake") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission13) == 1 and npcHandler:getTopic(playerId) == 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_32")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_33")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_34")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_35")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission14, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "ready") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission16) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_28")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_29")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_30")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_31")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17, 1)
	elseif MsgContains(message, "problem") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission17) == 1 and npcHandler:getTopic(playerId) == 8 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_32")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission18, 1)
		player:addItem(19090, 3)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "blood") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission21) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission22) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_26")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_27")
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission22, 1)
	elseif MsgContains(message, "proceed") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission30) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission31) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission31, 1)
		player:addItem(19132, 1)
		player:addItem(19166, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_21")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_22")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_24")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_25")
	elseif MsgContains(message, "scroll") then
		if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission34) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission35) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_20")
			npcHandler:setTopic(playerId, 10)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission42) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_33")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission50) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_34")
			npcHandler:setTopic(playerId, 12)
		elseif npcHandler:getTopic(playerId) == 13 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission57) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) < 1 then
			if player:removeItem(18933, 1) then
				player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_15")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_35")
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission64) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission65) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_36")
			player:addItem(19148, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission68) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission69) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_37")
			npcHandler:setTopic(playerId, 15)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission71) == 2 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission72) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_38")
			npcHandler:setTopic(playerId, 18)
		end
	elseif MsgContains(message, "next") then
		if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission43) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_13")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission44, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission51) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_10")
			player:addItem(19173, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission52, 1)
		elseif player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission58) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59) < 1 then
			player:addItem(19148, 1)
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission59, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_7")
		end
	elseif npcHandler:getTopic(playerId) == 16 and MsgContains(message, "restore") and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission72) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission73) < 1 then
		if player:removeItem(19158, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.multi_3")
			player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission73, 1)
			npcHandler:setTopic(playerId, 19)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_39")
			npcHandler:setTopic(playerId, 0)
		end
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.omrabas.say_40")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "At last, a visitor! Welcome to my... humble abode. {Scroll} or {mission}?")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
