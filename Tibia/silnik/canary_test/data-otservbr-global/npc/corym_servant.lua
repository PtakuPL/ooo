local internalNpcName = "Corym Servant"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 533,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 115,
	lookFeet = 0,
	lookAddons = 0,
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

local HiddenThreats = Storage.Quest.U11_50.HiddenThreats
local function greetCallback(npc, creature, message)
	local player = Player(creature)

	if player:getStorageValue(HiddenThreats.QuestLine) == 1 then
		npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.corym_servant.greet_msg_2")
	elseif player:getStorageValue(HiddenThreats.CorymRescueMission) == 8 and player:getStorageValue(HiddenThreats.QuestLine) == 3 then
		npcHandler:setMessage(MESSAGE_GREET, {
			"Well done! The riot progesses! No fight without weapons. In the mine the temperature is quite high, higher as expected in this depth. Therefore we need heat-resistent weapons and armors. ...",
			"This effect can be reached by adding rare earth to the common materials. But this can only be found in the stomaches of stonerefiners. 20 of these should be enough. Well, I see you have already collected enough of them! Would you give it to me?",
		})
		player:setStorageValue(HiddenThreats.QuestLine, 4)
	elseif player:getStorageValue(HiddenThreats.QuestLine) == 4 then
		npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.corym_servant.greet_msg_3")
	elseif player:getStorageValue(HiddenThreats.QuestLine) == 3 then
		npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.corym_servant.greet_msg_4")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.corym_servant.greet_msg_1")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "decreasing resources") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_6")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "defy") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getStorageValue(HiddenThreats.QuestLine) == 1 then
				player:setStorageValue(HiddenThreats.QuestLine, 2)
				player:setStorageValue(HiddenThreats.ServantDoor, 1)
				player:setStorageValue(HiddenThreats.CorymRescueMission, 0)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_4")
			npcHandler:setTopic(playerId, 2)
		end
	elseif (MsgContains(message, "yes")) and player:getStorageValue(HiddenThreats.QuestLine) == 4 then
		if player:removeItem(27301, 20) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.multi_2")
			player:addItem(3040, 2)
			player:setStorageValue(HiddenThreats.QuestLine, 5)
			player:setStorageValue(HiddenThreats.CorymRescueMission, 9)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.corym_servant.say_1")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	end
	return true
end

-- Greeting message
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.corym_servant.farewell_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
