local internalNpcName = "Ulala"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 154,
	lookHead = 57,
	lookBody = 57,
	lookLegs = 57,
	lookFeet = 57,
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
		if player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_11")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_8")
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 8)
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission04, 1) --Questlog, Unnatural Selection Quest "Mission 4: Bits and Pieces"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_5")
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 10)
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission05, 1) --Questlog, Unnatural Selection Quest "Mission 5: Ray of Light"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_4")
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 12)
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission05, 3) --Questlog, Unnatural Selection Quest "Mission 5: Ray of Light"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.multi_2")
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 13)
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission06, 1) --Questlog, Unnatural Selection Quest "Mission 6: Firewater Burn"
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "krunus") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_5")
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission03, 2) --Questlog, Unnatural Selection Quest "Mission 3: Dance Dance Evolution"
			player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.DanceStatus, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			if player:getItemCount(10196) >= 5 and player:getItemCount(5878) >= 5 and player:getItemCount(5876) >= 5 then
				player:removeItem(10196, 5)
				player:removeItem(5878, 5)
				player:removeItem(5876, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_6")
				player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Questline, 9)
				player:setStorageValue(Storage.Quest.U8_54.UnnaturalSelection.Mission04, 2) --Questlog, Unnatural Selection Quest "Mission 4: Bits and Pieces"
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ulala.say_7")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ulala.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
