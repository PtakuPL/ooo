local internalNpcName = "Amanda"
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
	lookHead = 96,
	lookBody = 95,
	lookLegs = 0,
	lookFeet = 114,
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

-- Mission (Tibia Tales: Rest In Hallowed Ground)
local startMissionKeyword = keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_1" }, function(player)
	return player:getStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline) == -1
end)
startMissionKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_2", reset = true }, nil, function(player)
	player:setStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline, 1)
end)
startMissionKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_3", reset = true })

local function addMissionKeyword(text, value, newValue, addItem)
	keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline) == value
	end, function(player)
		if newValue then
			player:setStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline, newValue)
		end

		if addItem then
			player:addItem(268, 5)
			player:addItem(266, 5)
		end
	end)
end

addMissionKeyword("First of all, you have to find a way to enter the Isle of the Kings and get some holy water from the White Raven Monastery.", 1)
addMissionKeyword("Have you heard about the unholy graveyard north of Edron? Go there and spill some holy water on every grave. Once you are done, come back to me.", 2, 3)
addMissionKeyword("I feel that the spirits have not come to a rest yet. There must still be some graves left to sanctify.", 3)
addMissionKeyword("I appreciate your help. May Banor be always on your side. Here, your reward is this package which contains five mana and five health potions.", 4, 5, true)

keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_4" })

-- Twist of Fate
local blessKeyword = keywordHandler:addKeyword({ "twist of fate" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"This is a special blessing I can bestow upon you once you have obtained at least one of the other blessings and which functions a bit differently. ...",
		"It only works when you're killed by other adventurers, which means that at least half of the damage leading to your death was caused by others, not by monsters or the environment. ...",
		"The {twist of fate} will not reduce the death penalty like the other blessings, but instead prevent you from losing your other blessings as well as the amulet of loss, should you wear one. It costs the same as the other blessings. ...",
		"Would you like to receive that protection for a sacrifice of |PVPBLESSCOST| gold, child?",
	},
})
blessKeyword:addChildKeyword({ "yes" }, StdModule.bless, { npcHandler = npcHandler, i18nKey = "npc.amanda.keyword_1", cost = "|PVPBLESSCOST|", bless = 1 })
blessKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_5", reset = true })

-- Adventurer Stone
keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_6" }, function(player)
	return player:getItemById(16277, true)
end)

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_7" }, function(player)
	return player:getStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Amanda) ~= 1
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_8", reset = true }, nil, function(player)
	player:addItem(16277, 1)
	player:setStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Amanda, 1)
end)

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_9" })
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_10", reset = true }, function(player)
	return player:getMoney() + player:getBankBalance() >= 30
end, function(player)
	if player:removeMoneyBank(30) then
		player:addItem(16277, 1)
	end
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_11", reset = true })
stoneKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_12", reset = true })

-- Wooden Stake
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_13" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 6 and player:getItemCount(5941) == 0
end)

local stakeKeyword = keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_14" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 6
end)
stakeKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_15", reset = true }, nil, function(player)
	player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 7)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
stakeKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_16", reset = true })

keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_17" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 7
end)
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_18" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) > 7
end)
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_19" })

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

keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_20" }, function(player)
	return player:getHealth() < 40
end, function(player)
	local health = player:getHealth()
	if health < 40 then
		player:addHealth(40 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_21" })

-- Basic
keywordHandler:addKeyword({ "pilgrimage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_22" })
keywordHandler:addKeyword({ "blessings" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_23" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_24" }, function(player)
	return player:hasBlessing(1)
end)
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_25" }, function(player)
	return player:hasBlessing(2)
end)
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_26" }, function(player)
	return player:hasBlessing(3)
end)
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_27" }, function(player)
	return player:hasBlessing(4)
end)
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_28" }, function(player)
	return player:hasBlessing(5)
end)
keywordHandler:addAliasKeyword({ "wisdom" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_29" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_30" })
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_31" })
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_32" })
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.amanda.stdmod_33" })
keywordHandler:addAliasKeyword({ "wisdom" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.amanda.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.amanda.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.amanda.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
