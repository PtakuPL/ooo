local internalNpcName = "Mazarius"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 1500
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 78,
	lookBody = 76,
	lookLegs = 19,
	lookFeet = 38,
	lookAddons = 1,
	lookMount = 0,
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

	if MsgContains(message, "brings") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_1")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "problems") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "long") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_28")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_29")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_30")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_31")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_32")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_33")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_34")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_35")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_36")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_37")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_38")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_39")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_40")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_41")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "short") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_26")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_27")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 2 and player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Access) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_3")
	elseif MsgContains(message, "demonic essence") or MsgContains(message, "essence") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_4")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 then
		if player:removeItem(6499, 30) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_5")
			player:addItem(22182, 1)
			player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Access, 1)
			player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.FirstDoor, 1)
			player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.MonsterDoor, 1)
			player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.TarbazDoor, 1)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "godbreaker") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_20")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_21")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_22")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_24")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_25")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "Ruthless Seven") or MsgContains(message, "ruthless seven") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_7")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "demi-plane") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_17")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_18")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "ascension") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_15")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_16")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "ferumbras") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_11")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "bozarn") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_8")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "darashia") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_9")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "thais") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_10")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "carlin") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_11")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "kazordoon") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_6")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "ab'dendriel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_4")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "edron") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_12")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "demons") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.multi_2")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "venore") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_13")
		npcHandler:setTopic(playerId, 0)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mazarius.say_14")
		npcHandler:setTopic(playerId, 0)
	end
end
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.mazarius.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.mazarius.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.mazarius.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
