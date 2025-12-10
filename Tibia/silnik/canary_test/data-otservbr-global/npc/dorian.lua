local internalNpcName = "Dorian"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 22,
	lookBody = 58,
	lookLegs = 77,
	lookFeet = 21,
	lookAddons = 2,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 1 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission01) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission01, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_35")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_36")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission01) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_1")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 2 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_33")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_34")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_2")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 3 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_29")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_3")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 4 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_26")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_4")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 5 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission05) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission05, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_20")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission05) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_5")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 6 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_17")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_6")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 7 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission07) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission07, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_14")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission07) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_7")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) == 8 and player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission08) < 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission08, 1)
			player:addItem(7873, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_12")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission08) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_8")
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_8")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeItem(3044, 10) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission01, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_9")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(227, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02, 3)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(7933, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission03, 3)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 4)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_6")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(7871, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04, 8)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(7369, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission05, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 6)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_12")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(7936, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission06, 4)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 7)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_13")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(7935, 1) then
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission07, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 8)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_4")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission08, 3)
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline, 9)
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Door, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.multi_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "thieves") or MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_14")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "lock pick") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dorian.say_15")
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|! Why do you disturb me?")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "lock pick", clientId = 7889, buy = 50 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
