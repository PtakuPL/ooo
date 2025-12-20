local internalNpcName = "Julius"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 114,
	lookBody = 114,
	lookLegs = 114,
	lookFeet = 113,
	lookAddons = 3,
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

local BloodBrothers = Storage.Quest.U8_4.BloodBrothers
local function greetCallback(npc, creature)
	local player = Player(creature)

	if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.QuestLine) < 0 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.julius.greet_msg_1")
	elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.QuestLine) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.julius.greet_msg_2")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if table.contains({ "mission", "note", "vampire" }, message:lower()) then
		if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.QuestLine) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01) == 1 then
			if player:getSlotItem(CONST_SLOT_NECKLACE) then
				if player:getSlotItem(CONST_SLOT_NECKLACE).itemid == 3083 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_2")
					player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01, 2)
					npcHandler:setTopic(playerId, 2)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_3")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_4")
			end
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_5")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01) == 4 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_6")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_7")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02) == 2 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_15")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_8")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03) == 3 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission04) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_13")
			npcHandler:setTopic(playerId, 12)
		end
	elseif message == "yes" then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_9")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.QuestLine, 1)
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_10")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01, 3)
		elseif npcHandler:getTopic(playerId) == 5 and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_9")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_11")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02, 1)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_12")
			npcHandler:setTopic(playerId, 8)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_5")
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.multi_2")
			player:addItem(8200)
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission04, 1)
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.VengothAccess, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "garlic bread") or message == "no" then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_13")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 8 then
			if
				player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin) == 2
				and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Lisander) == 2
				and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus) == 2
				and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris) == 2
				and player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Armenius) == 2
			then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_14")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission02, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "aaah") then
		if npcHandler:getTopic(playerId) == 4 and player:removeItem(8194, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_16")
			player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission01, 4)
			npcHandler:setTopic(playerId, 5)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_17")
		end
	elseif table.contains({ "maris", "ortheus", "serafin", "lisander", "armenius" }, message:lower()) and npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "maris") then
			if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_18")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris, 2)
			elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Maris) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_19")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_20")
			end
		elseif MsgContains(message, "ortheus") then
			if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_21")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus, 2)
			elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Ortheus) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_22")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_23")
			end
		elseif MsgContains(message, "serafin") then
			if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_24")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin, 2)
			elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Serafin) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_25")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_26")
			end
		elseif MsgContains(message, "lisander") then
			if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Lisander) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_27")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Lisander, 2)
			elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Lisander) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_28")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_29")
			end
		elseif MsgContains(message, "armenius") then
			if player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Armenius) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_30")
				player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Armenius, 2)
			elseif player:getStorageValue(Storage.Quest.U8_4.BloodBrothers.Cookies.Armenius) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_31")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_32")
			end
		end
	elseif npcHandler:getTopic(playerId) == 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_33")
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 8 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_34")
	elseif message:lower() == "alori mort" and npcHandler:getTopic(playerId) == 10 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_35")
		player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "armenius") and npcHandler:getTopic(playerId) == 11 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_36")
		player:setStorageValue(Storage.Quest.U8_4.BloodBrothers.Mission03, 3)
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.julius.say_37")
		npcHandler:setTopic(playerId, 0)
	end
end
--Basic
keywordHandler:addKeyword({ "distracted" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_1" })
keywordHandler:addAliasKeyword({ "job" })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_2" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_3" })
keywordHandler:addKeyword({ "storkus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_4" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_5" })
keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_6" })
keywordHandler:addKeyword({ "thank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.julius.stdmod_7" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.julius.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.julius.sendtrade_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "blood preservation", clientId = 11449, sell = 320 },
	{ itemName = "vampire teeth", clientId = 9685, sell = 275 },
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
