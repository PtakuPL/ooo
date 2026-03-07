local internalNpcName = "Ivalisse"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 138,
	lookHead = 2,
	lookBody = 19,
	lookLegs = 28,
	lookFeet = 76,
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

	if MsgContains(message, "temple") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "imbuing") or MsgContains(message, "imbuements") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_15")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_16")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_17")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_18")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_20")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "father") and npcHandler:getTopic(playerId) == 1 then
		if player:getStorageValue(Storage.Quest.U8_54.TheNewFrontier.Questline) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_13")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Ivalisse) == 1 or player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Chalice) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.DragonkingKilled) >= 1 and player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Ivalisse) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_9")
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Ivalisse, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.multi_6")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.say_4")
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.AccessFire, 1)
			player:setStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.Chalice, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ivalisse.say_5")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ivalisse.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.ivalisse.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

-- Don't forget npcHandler = npcHandler in the parameters. It is required for all StdModule functions!
keywordHandler:addKeyword({ "silus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_1" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_2" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_5" })
keywordHandler:addKeyword({ "duties" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_6" })
keywordHandler:addKeyword({ "duties" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.ivalisse.stdmod_7" })

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
