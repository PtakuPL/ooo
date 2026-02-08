local internalNpcName = "Bunny Bonecrusher"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 139,
	lookHead = 96,
	lookBody = 0,
	lookLegs = 79,
	lookFeet = 115,
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

	-- Check if NPC can interact with the creature
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Check if the message contains "mission"
	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.TowerDefenceQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bunny_bonecrusher.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bunny_bonecrusher.multi_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_1.TowerDefenceQuest.Questline) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bunny_bonecrusher.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 1 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bunny_bonecrusher.say_2")
		player:addItem(140, 1)
		player:setStorageValue(Storage.Quest.U8_1.TowerDefenceQuest.Questline, 1)
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "password*") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bunny_bonecrusher.say_3")
		player:addItem(762, 50)
		player:addItem(774, 50)
		player:addItem(763, 50)
		player:addItem(761, 50)
		player:setStorageValue(Storage.Quest.U8_1.TowerDefenceQuest.Questline, 5)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

keywordHandler:addKeyword({ "hail general" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_1" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_3" })
keywordHandler:addKeyword({ "bonecrusher" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_4" })
keywordHandler:addKeyword({ "sister" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_5" })
keywordHandler:addKeyword({ "family" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_6" })
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_7" })
keywordHandler:addKeyword({ "leader" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_8" })
keywordHandler:addKeyword({ "army" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_9" })
keywordHandler:addKeyword({ "city" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_10" })
keywordHandler:addKeyword({ "druids" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_11" })
keywordHandler:addKeyword({ "tactics" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_12" })
keywordHandler:addKeyword({ "kiss" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_13" })
keywordHandler:addKeyword({ "green ferrets" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_14" })
keywordHandler:addKeyword({ "join" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_15" })
keywordHandler:addKeyword({ "join army" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bunny_bonecrusher.stdmod_16" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.bunny_bonecrusher.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.bunny_bonecrusher.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.bunny_bonecrusher.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
