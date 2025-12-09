local internalNpcName = "Navigator"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 463,
	lookHead = 94,
	lookBody = 123,
	lookLegs = 116,
	lookFeet = 123,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "flou") then
		if getPlayerStorageValue(creature, Storage.Navigator) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "explain") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.say_2")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "helmet") then
		if npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_26")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_22")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_11")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_7")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.multi_3")
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.navigator.say_4")
			player:addOutfitAddon(464, 2)
			player:addOutfitAddon(463, 2)
			setPlayerStorageValue(creature, Storage.Navigator, 4)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
