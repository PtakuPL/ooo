local internalNpcName = "Chief Grarkharok"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 281,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.chief_grarkharok.voice_1" },
	{ i18nKey = "npc.chief_grarkharok.voice_2" },
	{ i18nKey = "npc.chief_grarkharok.voice_3" },
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

local mission = Storage.Quest.U8_2.TrollSabotageQuest
local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "cloak") or MsgContains(message, "feather") or MsgContains(message, "swan") or MsgContains(message, "maiden") then
		if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_1")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_2")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "kill") or MsgContains(message, "hurt") or MsgContains(message, "pain") then
		if player:getStorageValue(Storage.Quest.U8_2.TrollSabotageQuest.Questline) == 1 then
			npcHandler:setTopic(playerId, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_3")
	elseif MsgContains(message, "lady") or MsgContains(message, "queen") or MsgContains(message, "woman") or MsgContains(message, "cave") or MsgContains(message, "house") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_4")
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_5")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_6")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 100 then
			if player:removeItem(5934, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_7")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 101 then
			if player:removeItem(3998, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_9")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_11")
		npcHandler:setTopic(playerId, 0)
		player:setStorageValue(mission.Questline, 2)
		player:addItem(7754, 1)
	elseif MsgContains(message, "frog") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_12")
		npcHandler:setTopic(playerId, 100)
	elseif MsgContains(message, "snake") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_13")
		npcHandler:setTopic(playerId, 101)
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 100 or npcHandler:getTopic(playerId) == 101 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_14")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 101 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chief_grarkharok.say_15")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end
-- basic
keywordHandler:addKeyword({ "tribe" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_1" })
keywordHandler:addAliasKeyword({ "troll" })
keywordHandler:addAliasKeyword({ "other" })

keywordHandler:addKeyword({ "gold" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_2" })
keywordHandler:addAliasKeyword({ "crystal" })
keywordHandler:addAliasKeyword({ "platinum" })
keywordHandler:addAliasKeyword({ "money" })
keywordHandler:addAliasKeyword({ "pay" })
keywordHandler:addKeyword({ "boom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_3" })
keywordHandler:addKeyword({ "bottom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_4" })
keywordHandler:addAliasKeyword({ "butt" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_5" })
keywordHandler:addKeyword({ "chief" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_6" })
keywordHandler:addKeyword({ "fragratosh" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_7" })
keywordHandler:addKeyword({ "necklace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_8" })
keywordHandler:addAliasKeyword({ "do" })
keywordHandler:addAliasKeyword({ "reason" })
keywordHandler:addAliasKeyword({ "why" })
keywordHandler:addKeyword({ "destroy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_9" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_10" })
keywordHandler:addAliasKeyword({ "grarkharok" })
keywordHandler:addKeyword({ "gurak cha rak" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_11" })
keywordHandler:addKeyword({ "item" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_12" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_13" })
keywordHandler:addAliasKeyword({ "nothing" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_14" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.chief_grarkharok.stdmod_15" })
keywordHandler:addAliasKeyword({ "quest" })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.chief_grarkharok.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.chief_grarkharok.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.chief_grarkharok.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
