local internalNpcName = "The Orc King"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 238,
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

local creatures = { "Slime", "Slime", "Slime", "Orc Warlord", "Orc Warlord", "Orc Leader", "Orc Leader", "Orc Leader" }
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.OrcKingGreeting) ~= 1 then
		player:setStorageValue(Storage.OrcKingGreeting, 1)
		for i = 1, #creatures do
			Game.createMonster(creatures[i], npc:getPosition())
		end
		npcHandler:say("Arrrrgh! A dirty paleskin! To me my children! Kill them my guards!", npc, creature, 1000, TALKTYPE_SAY)
		return false
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.the_orc_king.greet_msg_1")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local efreet, marid = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03), player:getStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03)
	-- Mission 3 - Orc Fortress
	if MsgContains(message, "lamp") then
		if efreet == 1 or marid == 1 then
			if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.RecievedLamp) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.multi_2")
				npcHandler:setTopic(playerId, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_2")
			end
		end
	elseif MsgContains(message, "cookie") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 31 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.OrcKing) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_3")
			npcHandler:setTopic(playerId, 2)
		end

		-- Mission 3 - Orc Fortress
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "malor") then
			if efreet == 1 then
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.DoorToLamp, 1)
			elseif marid == 1 then
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.MaridFaction.DoorToLamp, 1)
			end

			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.RecievedLamp, 1)
			player:addItem(3231, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_4")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_5")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if not player:removeItem(130, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_6")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.CookieDelivery.OrcKing, 1)
			if player:getCookiesDelivered() == 10 then
				player:addAchievement("Allow Cookies?")
			end

			npc:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_7")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.the_orc_king.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword({ "immortal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_1" })
keywordHandler:addKeyword({ "orcs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_2" })
keywordHandler:addKeyword({ "divine" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_3" })
keywordHandler:addKeyword({ "hive" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_4" })
keywordHandler:addKeyword({ "minions" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_5" })
keywordHandler:addKeyword({ "hate" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_6" })
keywordHandler:addKeyword({ "blog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_7" })
keywordHandler:addKeyword({ "direction" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_8" })
keywordHandler:addKeyword({ "world" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_9" })
keywordHandler:addKeyword({ "slime" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_10" })
keywordHandler:addKeyword({ "djinn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_11" })
keywordHandler:addKeyword({ "cheated" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_12" })
keywordHandler:addKeyword({ "wishes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_13" })
keywordHandler:addKeyword({ "third" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_14" })
keywordHandler:addKeyword({ "deathwish" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_15" })
keywordHandler:addKeyword({ "good djinn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_16" })
keywordHandler:addKeyword({ "paleskins" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_17" })
keywordHandler:addKeyword({ "malor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.the_orc_king.stdmod_18" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_4.DjinnWar.RecievedLamp) == 1
end)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
