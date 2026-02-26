local internalNpcName = "Jerom"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 76,
	lookBody = 78,
	lookLegs = 78,
	lookFeet = 114,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.jerom.voice_1" },
	{ i18nKey = "npc.jerom.voice_2" },
	{ i18nKey = "npc.jerom.voice_3" },
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
	local mission = Storage.Quest.U8_2.TrollSabotage
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end
	if MsgContains(message, "mission") or MsgContains(message, "quest") then
		if player:getStorageValue(Storage.Quest.U8_2.TrollSabotageQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jerom.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jerom.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jerom.multi_3")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_2.TrollSabotageQuest.Questline) == 2 and player:removeItem(7754, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jerom.say_1")
			player:setStorageValue(Storage.Quest.U8_2.TrollSabotageQuest.Questline, 3)
			player:addItem(646, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jerom.say_2")
			player:setStorageValue(Storage.Quest.U8_2.TrollSabotageQuest.Questline, 1)
		end
	end
	return true
end
-- basic
keywordHandler:addKeyword({ "ankrahmun" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_1" })
keywordHandler:addKeyword({ "bat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_2" })
keywordHandler:addAliasKeyword({ "bug" })
keywordHandler:addAliasKeyword({ "lion" })
keywordHandler:addAliasKeyword({ "wolf" })
keywordHandler:addAliasKeyword({ "deer" })
keywordHandler:addAliasKeyword({ "rotworm" })
keywordHandler:addAliasKeyword({ "slime" })
keywordHandler:addAliasKeyword({ "squirrel" })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_3" })
keywordHandler:addKeyword({ "cat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_4" })
keywordHandler:addKeyword({ "daniel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_5" })
keywordHandler:addAliasKeyword({ "steelsoul" })
keywordHandler:addKeyword({ "dog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_6" })
keywordHandler:addKeyword({ "edron" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_7" })
keywordHandler:addKeyword({ "farm" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_8" })
keywordHandler:addAliasKeyword({ "pet" })
keywordHandler:addAliasKeyword({ "country" })
keywordHandler:addKeyword({ "frog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_9" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_10" })
keywordHandler:addAliasKeyword({ "mood" })
keywordHandler:addAliasKeyword({ "work" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_11" })
keywordHandler:addAliasKeyword({ "tibianus" })
keywordHandler:addKeyword({ "liberty bay" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_12" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_13" })
keywordHandler:addKeyword({ "parrot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_14" })
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_15" })
keywordHandler:addKeyword({ "races" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_16" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_17" })
keywordHandler:addKeyword({ "revenge" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_18" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_19" })
keywordHandler:addKeyword({ "snake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_20" })
keywordHandler:addAliasKeyword({ "spider" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_21" })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_22" })
keywordHandler:addAliasKeyword({ "merchant" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_23" })
keywordHandler:addAliasKeyword({ "rock" })
keywordHandler:addKeyword({ "what" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jerom.stdmod_24" })
keywordHandler:addAliasKeyword({ "happen" })
keywordHandler:addAliasKeyword({ "house" })
keywordHandler:addAliasKeyword({ "accident" })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.jerom.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.jerom.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jerom.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
