local internalNpcName = "Ninev"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1199,
	lookHead = 114,
	lookBody = 86,
	lookLegs = 68,
	lookFeet = 9,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

-- Load NPC helper library
dofile(CORE_DIRECTORY .. "/libs/npc/i18n.lua")

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

-- Wooden Stake Quest
local stakeKeyword = keywordHandler:addKeyword({ "stake" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		NPC_LIB.i18n.get("npc.ninev.stake_intro_1"),
		NPC_LIB.i18n.get("npc.ninev.stake_intro_2"),
		NPC_LIB.i18n.get("npc.ninev.stake_intro_3"),
		NPC_LIB.i18n.get("npc.ninev.stake_intro_4"),
	},
}, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == -1
end)
stakeKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_get_gamon"), reset = true, ungreet = true }, nil, function(player)
	player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
	player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 1)
end)

-- First prayer
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_no_item") }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 1 and player:getItemCount(5941) == 0
end)

local stakeKeyword = keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_prayer_ask") }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 1
end)
stakeKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_prayer_1"), reset = true }, nil, function(player)
	player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 2)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
stakeKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_wait"), reset = true })

keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_visit_tibra") }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 2
end)
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stake_already_done") })

-- Twist of Fate
local blessKeyword = keywordHandler:addKeyword({ "twist of fate" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		NPC_LIB.i18n.get("npc.ninev.twist_intro_1"),
		NPC_LIB.i18n.get("npc.ninev.twist_intro_2"),
		NPC_LIB.i18n.get("npc.ninev.twist_intro_3"),
		NPC_LIB.i18n.get("npc.ninev.twist_intro_4"),
	},
})
blessKeyword:addChildKeyword({ "yes" }, StdModule.bless, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.twist_received"), cost = "|PVPBLESSCOST|", bless = 1 })
blessKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.twist_declined"), reset = true })

-- Adventurer Stone
keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_keep") }, function(player)
	return player:getItemById(16277, true)
end)

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_free_ask") }, function(player)
	return player:getStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Quentin) ~= 1
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_here"), reset = true }, nil, function(player)
	player:addItem(16277, 1)
	player:setStorageValue(Storage.Quest.U9_80.AdventurersGuild.FreeStone.Quentin, 1)
end)
stoneKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_no_problem"), reset = true })

local stoneKeyword = keywordHandler:addKeyword({ "adventurer stone" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_paid_ask") })
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_here"), reset = true }, function(player)
	return player:getMoney() + player:getBankBalance() >= 30
end, function(player)
	if player:removeMoneyBank(30) then
		player:addItem(16277, 1)
	end
end)
stoneKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_no_money"), reset = true })
stoneKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.stone_no_problem"), reset = true })

-- Healing
local function addHealKeyword(text, condition, effect)
	keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getCondition(condition) ~= nil
	end, function(player)
		player:removeCondition(condition)
		player:getPosition():sendMagicEffect(effect)
	end)
end

addHealKeyword(NPC_LIB.i18n.get("npc.ninev.heal_fire"), CONDITION_FIRE, CONST_ME_MAGIC_GREEN)
addHealKeyword(NPC_LIB.i18n.get("npc.ninev.heal_poison"), CONDITION_POISON, CONST_ME_MAGIC_RED)
addHealKeyword(NPC_LIB.i18n.get("npc.ninev.heal_energy"), CONDITION_ENERGY, CONST_ME_MAGIC_GREEN)

keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.heal_wounds") }, function(player)
	return player:getHealth() < 40
end, function(player)
	local health = player:getHealth()
	if health < 40 then
		player:addHealth(40 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.heal_not_needed") })

-- Basic
keywordHandler:addKeyword({ "pilgrimage" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.pilgrimage_info") })
keywordHandler:addKeyword({ "blessings" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.blessings_info") })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_spiritual_has") }, function(player)
	return player:hasBlessing(1)
end)
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_embrace_has") }, function(player)
	return player:hasBlessing(2)
end)
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_suns_has") }, function(player)
	return player:hasBlessing(3)
end)
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_phoenix_has") }, function(player)
	return player:hasBlessing(4)
end)
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_solitude_has") }, function(player)
	return player:hasBlessing(5)
end)
keywordHandler:addAliasKeyword({ "wisdom" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_spiritual_no") })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_embrace_no") })
keywordHandler:addKeyword({ "suns" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_suns_no") })
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_phoenix_no") })
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "solitude" }, StdModule.say, { npcHandler = npcHandler, text = NPC_LIB.i18n.get("npc.ninev.bless_solitude_no") })
keywordHandler:addAliasKeyword({ "wisdom" })

npcHandler:setMessage(MESSAGE_GREET, NPC_LIB.i18n.get("npc.ninev.greet", { "|PLAYERNAME|" }))
npcHandler:setMessage(MESSAGE_WALKAWAY, NPC_LIB.i18n.get("npc.ninev.walkaway"))
npcHandler:setMessage(MESSAGE_FAREWELL, NPC_LIB.i18n.get("npc.ninev.farewell", { "|PLAYERNAME|" }))

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
