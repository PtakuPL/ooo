local internalNpcName = "Cipfried"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 1000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 57,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.cipfried.voice_1" },
	{ i18nKey = "npc.cipfried.voice_2" },
	{ i18nKey = "npc.cipfried.voice_3" },
	{ i18nKey = "npc.cipfried.voice_4" },
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	local player = Player(creature)
	local health = player:getHealth()
	local lowHealth = health < 65
	local poisoned = player:getCondition(CONDITION_POISON)
	if lowHealth or poisoned then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.cipfried.greet_msg_1")
		if lowHealth then
			player:addHealth(65 - health)
		end
		if poisoned then
			player:removeCondition(CONDITION_POISON)
		end
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.cipfried.greet_msg_2")
	end
	return true
end

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_2" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_3" })
keywordHandler:addKeyword({ "monk" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_4" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_5" })
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_6" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_7" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_8" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_9" })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_10" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_11" })
keywordHandler:addKeyword({ "spider" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_12" })
keywordHandler:addKeyword({ "kill" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_13" })
keywordHandler:addKeyword({ "poison" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_14" })
keywordHandler:addKeyword({ "vocation" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_15" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_16" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_17" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_18" })
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_19" })
keywordHandler:addKeyword({ "shop" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_20" })
keywordHandler:addKeyword({ "equip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_21" })
keywordHandler:addKeyword({ "shovel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_22" })
keywordHandler:addKeyword({ "rope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_23" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_24" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_25" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_26" })
keywordHandler:addKeyword({ "ship" }, StdModule.say, { npcHandler = npcHandler, text = { "Ships are a comfortable way of travelling to distant cities. At any harbour, you can board the ship and ask its captain where he sails to.", "Travelling by ship will cost you some gold, though, so be sure to have money with you." } })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_27" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_28" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_29" })
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_30" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_31" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_32" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_33" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_34" })

keywordHandler:addKeyword({ "buy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_35" })
keywordHandler:addAliasKeyword({ "sell" })

keywordHandler:addKeyword({ "shield" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_36" })
keywordHandler:addAliasKeyword({ "armor" })

keywordHandler:addKeyword({ "money" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_37" })
keywordHandler:addAliasKeyword({ "gold" })

keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_38" })
keywordHandler:addAliasKeyword({ "mission" })

keywordHandler:addKeyword({ "wolf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_39" })
keywordHandler:addAliasKeyword({ "wolves" })

keywordHandler:addKeyword({ "adventure" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_40" })
keywordHandler:addAliasKeyword({ "explore" })

keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_41" }, function(player)
	return player:getCondition(CONDITION_POISON)
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:removeCondition(CONDITION_POISON)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_42" }, function(player)
	return player:getHealth() < 185 and player:getHealth() < player:getBaseMaxHealth()
end, function(player)
	local health = player:getHealth()
	player:addHealth(185 - health)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_43" })

-- Names
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_44" })
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_45" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_46" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_47" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_48" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_49" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_50" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_51" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_52" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_53" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_54" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_55" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_56" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_57" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_58" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_59" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_60" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_61" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cipfried.stdmod_62" })
keywordHandler:addAliasKeyword({ "zerbrus" })

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.cipfried.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.cipfried.farewell_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
