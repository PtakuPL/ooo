local internalNpcName = "Oldrak"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 150
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 57,
	lookHead = 115,
	lookBody = 113,
	lookLegs = 31,
	lookFeet = 38,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
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

-- I18N: Zmigrowane na klucze i18n (proof-of-concept)
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.job" })
keywordHandler:addAliasKeyword({ "visitors" })

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.name" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.monster" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.help" })
keywordHandler:addKeyword({ "goshnar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.goshnar" })
keywordHandler:addKeyword({ "nightmare" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_1" })
keywordHandler:addKeyword({ "extinct" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_2" })
keywordHandler:addKeyword({ "dreamers" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_3" })
keywordHandler:addKeyword({ "dreamwalking" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_4" })
keywordHandler:addKeyword({ "omen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_5" })
keywordHandler:addKeyword({ "schemes of darkness" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_6" })
keywordHandler:addKeyword({ "plan" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_7" })
keywordHandler:addKeyword({ "necromant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_8" })
keywordHandler:addKeyword({ "havok" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_9" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_10" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_11" })
keywordHandler:addKeyword({ "unlife" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_12" })
keywordHandler:addKeyword({ "undead" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_13" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_14" })
keywordHandler:addKeyword({ "yenny the gentle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_15" })
keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_16" })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_17" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_18" })
keywordHandler:addKeyword({ "buy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_19" })
keywordHandler:addKeyword({ "have" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_20" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.oldrak.stdmod_21" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Demon oak quest
	if MsgContains(message, "mission") or MsgContains(message, "demon oak") then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 and player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_2")
		elseif player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.multi_3")
			player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Done, 2)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress, 1)
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_3")
			player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress, 2)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "axe") then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_5")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Progress) == 2 then
			if player:getMoney() + player:getBankBalance() >= 1000 then
				if player:removeItem(3274, 1) and player:removeMoneyBank(1000) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_7")
					player:addItem(919, 1)
					npc:getPosition():sendMagicEffect(CONST_ME_YELLOWENERGY)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_8")
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_9")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_10")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_11")
		npcHandler:setTopic(playerId, 0)
	end

	-- The paradox tower quest
	if MsgContains(message, "hugo") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_12")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "myth") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo) < 1 then
			-- Questlog: The Paradox Tower
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.QuestLine, 1)
			-- Questlog: The Feared Hugo (Zoltan)
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_13")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yenny the gentle") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_14")
		npcHandler:setTopic(playerId, 0)
	end

	if MsgContains(message, "holy") or MsgContains(message, "tible") then
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ChestTible) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_15")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_16")
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		if player:removeMoney(1000) then
			player:addItem(2836, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_17")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.oldrak.say_18")
		end
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.oldrak.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.oldrak.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.oldrak.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
