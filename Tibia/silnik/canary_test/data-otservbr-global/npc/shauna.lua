local internalNpcName = "Shauna"
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
	lookHead = 78,
	lookBody = 95,
	lookLegs = 38,
	lookFeet = 58,
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

	-- Mission 1 - The Supply Thief
	if MsgContains(message, "job") then
		if Player(creature):getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "water pipe") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_7")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "prisoner") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.shauna.multi_5")
			Player(creature):setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01, 3)
			npcHandler:setTopic(playerId, 0)
		end
	end
	-- Mission 1 - The Supply Thief
	return true
end

keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_1" })
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_2" })
keywordHandler:addKeyword({ "leader" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_3" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_4" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_5" })
keywordHandler:addKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_6" })
keywordHandler:addKeyword({ "army" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_7" })
keywordHandler:addKeyword({ "guard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_8" })
keywordHandler:addKeyword({ "general" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_9" })
keywordHandler:addKeyword({ "bonecrusher" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_10" })
keywordHandler:addKeyword({ "enemies" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_11" })
keywordHandler:addKeyword({ "enemy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_12" })
keywordHandler:addKeyword({ "criminal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_13" })
keywordHandler:addKeyword({ "murderer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_14" })
keywordHandler:addKeyword({ "castle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_15" })
keywordHandler:addKeyword({ "subject" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_16" })
keywordHandler:addKeyword({ "tbi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_17" })
keywordHandler:addKeyword({ "todd" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_18" })
keywordHandler:addKeyword({ "city" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_19" })
keywordHandler:addKeyword({ "hain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_20" })
keywordHandler:addKeyword({ "rowenna" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_21" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_22" })
keywordHandler:addKeyword({ "cornelia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_23" })
keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_24" })
keywordHandler:addKeyword({ "legola" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_25" })
keywordHandler:addKeyword({ "padreia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_26" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_27" })
keywordHandler:addKeyword({ "banor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_28" })
keywordHandler:addKeyword({ "zathroth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_29" })
keywordHandler:addKeyword({ "brog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_30" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_31" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_32" })
keywordHandler:addKeyword({ "rebellion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_33" })
keywordHandler:addKeyword({ "alcohol" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.shauna.stdmod_34" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Howdy, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "LONG LIVE THE QUEEN!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "LONG LIVE THE QUEEN!")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
