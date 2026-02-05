local internalNpcName = "A Weakened Forest Fury"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 569,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "distress") or MsgContains(message, "mission") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_10")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_4")
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCage, 1)
			player:addItem(23812, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "seeds") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_1")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "intruders") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "water") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "birds") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "phials") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "cages") and player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCage) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.multi_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_weakened_forest_fury.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_weakened_forest_fury.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

-- Don't forget npcHandler = npcHandler in the parameters. It is required for all StdModule functions!
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_weakened_forest_fury.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_weakened_forest_fury.stdmod_2" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_weakened_forest_fury.stdmod_3" })
keywordHandler:addKeyword({ "forest fury" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_weakened_forest_fury.stdmod_4" })
keywordHandler:addKeyword({ "orclops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_weakened_forest_fury.stdmod_5" })

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
