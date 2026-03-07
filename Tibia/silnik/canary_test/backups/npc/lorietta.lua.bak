local internalNpcName = "Lorietta"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 270,
	lookHead = 78,
	lookBody = 79,
	lookLegs = 80,
	lookFeet = 77,
	lookAddons = 1,
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

-- Twist of Fate
local blessKeyword = keywordHandler:addKeyword({ "twist of fate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.lorietta.stdmod_25",
})
blessKeyword:addChildKeyword({ "yes" }, StdModule.bless, { npcHandler = npcHandler, i18nKey = "npc.lorietta.keyword_1", cost = "|PVPBLESSCOST|", bless = 1 })
blessKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_1", reset = true })

-- Adventurer Stone
keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_2" }, function(player)
	return player:getItemById(16277, true)
end)

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_3" }, function(player)
	return player:getStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Lorietta) ~= 1
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_4", reset = true }, nil, function(player)
	player:addItem(16277, 1)
	player:setStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Lorietta, 1)
end)
stoneKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_5", reset = true })

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_6" })
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_7", reset = true }, function(player)
	return player:getMoney() + player:getBankBalance() >= 30
end, function(player)
	if player:removeMoneyBank(30) then
		player:addItem(16277, 1)
	end
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_8", reset = true })
stoneKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_9", reset = true })

-- Healing
local function addHealKeyword(text, condition, effect)
	keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getCondition(condition) ~= nil
	end, function(player)
		player:removeCondition(condition)
		player:getPosition():sendMagicEffect(effect)
	end)
end

addHealKeyword("You are burning. Let me quench those flames.", CONDITION_FIRE, CONST_ME_MAGIC_GREEN)
addHealKeyword("You are poisoned. Let me soothe your pain.", CONDITION_POISON, CONST_ME_MAGIC_RED)
addHealKeyword("You are electrified, my child. Let me help you to stop trembling.", CONDITION_ENERGY, CONST_ME_MAGIC_GREEN)

keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_10" }, function(player)
	return player:getHealth() < 40
end, function(player)
	local health = player:getHealth()
	if health < 40 then
		player:addHealth(40 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_11" })

-- Basic
keywordHandler:addKeyword({ "pilgrimage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_12" })
keywordHandler:addKeyword({ "blessings" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_13" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_14" }, function(player)
	return player:hasBlessing(1)
end)
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_15" }, function(player)
	return player:hasBlessing(2)
end)
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_16" }, function(player)
	return player:hasBlessing(3)
end)
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_17" }, function(player)
	return player:hasBlessing(4)
end)
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_18" }, function(player)
	return player:hasBlessing(5)
end)
keywordHandler:addAliasKeyword({ "wisdom" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_19" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_20" })
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_21" })
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_22" })
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lorietta.stdmod_23" })
keywordHandler:addAliasKeyword({ "wisdom" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lorietta.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.lorietta.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.lorietta.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
