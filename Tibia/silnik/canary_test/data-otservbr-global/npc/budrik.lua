local internalNpcName = "Budrik"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 94,
	lookBody = 95,
	lookLegs = 58,
	lookFeet = 114,
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

	if table.contains({ "mission", "quest" }, message:lower()) then
		if player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_6")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) == 1 then
			if player:removeItem(139, 1) then
				player:setStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline, 2)
				player:addItem(875, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_1")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_2")
			end
		elseif player:getStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline) == 2 and player:getLevel() <= 40 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_4")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.MinotaurCount) >= 5000 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.multi_2")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos, 1)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.FoxCount, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_3")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) == 2 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.FoxCount) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_4")
		elseif player:getLevel() > 40 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_5")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_6")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_7")
			npcHandler:setTopic(playerId, 0)
			if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart) <= 0 then
				player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U8_1.ToOutfoxAFoxQuest.Questline, 1)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_8")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BudrikMinos, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.MinotaurCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurGuardCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurMageCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.MinotaurArcherCount, 0)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_9")
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) > 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.budrik.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

-- Basic
local function sayTimeKeyword(npc, player, message, keywords, parameters, node)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end
	NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.budrik.time_now", { getFormattedWorldTime() })
	return true
end

local function saySheartonKeyword(npc, player, message, keywords, parameters, node)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end
	NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.budrik.kw_shearton_softbeard_1", "npc.budrik.kw_shearton_softbeard_2" }, 100)
	return true
end

keywordHandler:addKeyword({ "disturb" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_1" })
keywordHandler:addAliasKeyword({ "job" })
keywordHandler:addAliasKeyword({ "shop" })
keywordHandler:addKeyword({ "dwarfs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_2" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_3" })
keywordHandler:addKeyword({ "hideout" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_4" })
keywordHandler:addKeyword({ "horned fox" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_5" })
keywordHandler:addKeyword({ "mine" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_6" })
keywordHandler:addAliasKeyword({ "dungeon" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_8" })
keywordHandler:addKeyword({ "time" }, sayTimeKeyword, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "trouble" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_9" })
keywordHandler:addKeyword({ "shearton softbeard" }, saySheartonKeyword, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "grothmok" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_10" })
keywordHandler:addKeyword({ "deeper mines" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.budrik.stdmod_11" })
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.budrik.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.budrik.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.budrik.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
