local internalNpcName = "Santiago"
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
	lookHead = 38,
	lookBody = 115,
	lookLegs = 87,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.santiago.voice_1" },
	{ i18nKey = "npc.santiago.voice_2" },
	{ i18nKey = "npc.santiago.voice_3" },
	{ i18nKey = "npc.santiago.voice_4" },
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

local storeTalkCid = {}
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) < 1 then
		player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 1)
		player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 1)
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_1")
		storeTalkCid[playerId] = 0
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_2")
		storeTalkCid[playerId] = 0
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_1")
		Position(32033, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
		return false
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 3 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_3")
		storeTalkCid[playerId] = 2
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_4")
		storeTalkCid[playerId] = 2
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_2")
		return false
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 6 then
		if player:removeItem(7882, 3) then
			NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_5")
			player:addExperience(100, true)
			player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 5)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 7)
			storeTalkCid[playerId] = 4
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_3")
			return false
		end
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 7 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_1")
		storeTalkCid[playerId] = 4
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 8 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_2")
		storeTalkCid[playerId] = 5
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 9 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_3")
		storeTalkCid[playerId] = 6
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 10 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_4")
		storeTalkCid[playerId] = 7
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 11 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_5")
		storeTalkCid[playerId] = 8
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 12 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_6")
		storeTalkCid[playerId] = 9
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 13 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.santiago.greet_msg_6")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "yes", "right", "ok" }, message) then
		if storeTalkCid[playerId] == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_4")
			Position(32033, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			storeTalkCid[playerId] = 1
		elseif storeTalkCid[playerId] == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_5")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 2)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 2)
			player:sendTutorial(3)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif storeTalkCid[playerId] == 2 then
			if player:getItemCount(3562) > 0 then
				local coatSlot = player:getSlotItem(CONST_SLOT_ARMOR)
				if coatSlot then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_6")
					player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 4)
					storeTalkCid[playerId] = 3
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_7")
					player:sendTutorial(5)
					storeTalkCid[playerId] = 2
				end
			else
				player:addItem(3562, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_8")
				storeTalkCid[playerId] = 3
			end
		elseif storeTalkCid[playerId] == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_9")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 5)
			Position(32036, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			player:addItem(3270, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif storeTalkCid[playerId] == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_10")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 8)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 6)
			storeTalkCid[playerId] = 5
		elseif storeTalkCid[playerId] == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_11")
			player:sendTutorial(19)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 9)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 7)
			storeTalkCid[playerId] = 6
		elseif storeTalkCid[playerId] == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_12")
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			npc:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:addHealth(-20, COMBAT_PHYSICALDAMAGE)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 10)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 8)
			player:sendTutorial(19)
			storeTalkCid[playerId] = 7
		elseif storeTalkCid[playerId] == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.multi_2")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 9)
			player:addItem(3578, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 11)
			storeTalkCid[playerId] = 8
		elseif storeTalkCid[playerId] == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_13")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 12)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 10)
			storeTalkCid[playerId] = 9
		elseif storeTalkCid[playerId] == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_14")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 13)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 11)
			player:addMapMark(Position(32045, 32270, 6), MAPMARK_GREENSOUTH, "To Zirella")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "hurt") then
		if storeTalkCid[playerId] == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_15")
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			npc:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:addHealth(-20, COMBAT_PHYSICALDAMAGE)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 8)
			player:sendTutorial(19)
			storeTalkCid[playerId] = 7
		end
	elseif MsgContains(message, "action") then
		if storeTalkCid[playerId] == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_16")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 5)
			Position(32036, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			player:addItem(3270, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "easy") then
		if storeTalkCid[playerId] == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.santiago.say_17")
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 11)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 10)
			storeTalkCid[playerId] = 9
		end
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	storeTalkCid[playerId] = nil
end

npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.santiago.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.santiago.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
