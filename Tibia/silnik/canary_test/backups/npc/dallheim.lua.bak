local internalNpcName = "Dallheim"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 268,
	lookHead = 76,
	lookBody = 38,
	lookLegs = 76,
	lookFeet = 95,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.dallheim.voice_1" },
	{ i18nKey = "npc.dallheim.voice_2" },
	{ i18nKey = "npc.dallheim.voice_3" },
	{ i18nKey = "npc.dallheim.voice_4" },
	{ i18nKey = "npc.dallheim.voice_5" },
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

-- Greeting and Farewell
keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "Greetings, |PLAYERNAME|! You're looking really bad. Let me heal your wounds.", i18nKey = "npc.dallheim.greet_1" }, function(player)
	return player:getHealth() < 65 or player:getCondition(CONDITION_POISON) ~= nil
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:removeCondition(CONDITION_POISON)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
keywordHandler:addAliasKeyword({ "hello" })

keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "<nods> At your service, |PLAYERNAME|, protecting the {village} from {monsters}.", i18nKey = "npc.dallheim.greet_2" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end)
keywordHandler:addAliasKeyword({ "hello" })

keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, text = "Bye, |PLAYERNAME|.", i18nKey = "npc.dallheim.farewell_1" })
keywordHandler:addAliasKeyword({ "farewell" })

local function addMonsterKeyword(level, text, marks)
	local keyword = keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getLevel() >= level
	end, function(player)
		if marks then
			for i = 1, #marks do
				player:addMapMark(marks[i].position, marks[i].type, marks[i].description)
			end
		end
	end)
end

-- Monster
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_1" }, function(player)
	return not player:hasRookgaardShield()
end)

addMonsterKeyword(10, "It looks like you have mastered the drill.")
addMonsterKeyword(8, "It looks like you have mastered the drill. Talk to the {oracle} to travel to other places and start getting some real battle experience.")
addMonsterKeyword(7, "You are almost strong enough to leave this island. If you'd like to go somewhere new, why don't you try skeletons? I'll mark a cave on your map, but be careful, there are lots of other creatures on the way.", { { position = Position(31972, 32130, 7), type = MAPMARK_GREENSOUTH, description = "Skeleton Cave" } })
addMonsterKeyword(
	6,
	"Nice job out there, |PLAYERNAME|. Have you already explored the whole North Ruin? If you are courageous enough, you could test your skills on wasps. But be careful, they are fast and poisonous! I'll mark them for you.",
	{ { position = Position(32000, 32139, 7), type = MAPMARK_GREENNORTH, description = "Wasps' Nest" }, { position = Position(32000, 32137, 6), type = MAPMARK_GREENNORTH, description = "Wasp Hive" } }
)
addMonsterKeyword(5, "Are you already tired of the North Ruin? You could try some bears, but be careful, they hit hard. I'll mark a cave on your map.", { { position = Position(32146, 32207, 7), type = MAPMARK_GREENSOUTH, description = "Bear Cave" } })
addMonsterKeyword(4, "You're halfway on leaving this island. I guess you might be ready for some stronger monsters such as {trolls} or {orcs}. Check out the North Ruin which I'll mark on your map right now, but don't go too deep.", { { position = Position(32094, 32137, 7), type = MAPMARK_GREENSOUTH, description = "North Ruin" } })
addMonsterKeyword(3, "Well, you can still stay with {spiders} or {snakes}, but maybe you'd like to try fighting a {bug} or even a {wolf}? I'll mark a den that I know on your map right now. Don't forget torch and rope!", { { position = Position(32155, 32122, 7), type = MAPMARK_GREENSOUTH, description = "Wolf Den" } })
addMonsterKeyword(
	2,
	"You still look a little wimpy. If you want to kill something other than {rats}, you may leave town to hunt {spiders} or {snakes}. I'll mark some spawns on your map right now. Don't forget torch and rope!",
	{ { position = Position(32027, 32171, 7), type = MAPMARK_GREENSOUTH, description = "Snake Swamp" }, { position = Position(31967, 32169, 7), type = MAPMARK_GREENSOUTH, description = "Spiderweb Hole" } }
)
addMonsterKeyword(1, "You are much too young and inexperienced to cross the bridge. Stay in the sewers. I'll mark an entrance on your map right now.", { { position = Position(32097, 32205, 7), type = MAPMARK_GREENSOUTH, description = "Sewer Entrance" } })

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_4" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_5" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_6" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_7" })
keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_8" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_9" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_10" })
keywordHandler:addKeyword({ "spider" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_11" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_12" })
keywordHandler:addKeyword({ "wolf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_13" })
keywordHandler:addAliasKeyword({ "wolves" })
keywordHandler:addKeyword({ "orc" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_14" })
keywordHandler:addKeyword({ "minotaur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_15" })
keywordHandler:addKeyword({ "bug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_16" })
keywordHandler:addKeyword({ "skeleton" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_17" })
keywordHandler:addKeyword({ "bear" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_18" })
keywordHandler:addKeyword({ "wasp" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_19" })
keywordHandler:addKeyword({ "snake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_20" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_21" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_22" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_23" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_24" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_25" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_26" })
keywordHandler:addKeyword({ "wilderness" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_27" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_28" })
keywordHandler:addKeyword({ "banor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_29" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_30" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_31" })

keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_32" })
keywordHandler:addAliasKeyword({ "village" })

keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_33" })

keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_34" })
keywordHandler:addAliasKeyword({ "offer" })
keywordHandler:addAliasKeyword({ "stuff" })
keywordHandler:addAliasKeyword({ "wares" })
keywordHandler:addAliasKeyword({ "sell" })
keywordHandler:addAliasKeyword({ "buy" })
keywordHandler:addAliasKeyword({ "sword" })
keywordHandler:addAliasKeyword({ "sabre" })
keywordHandler:addAliasKeyword({ "equip" })
keywordHandler:addAliasKeyword({ "weapon" })
keywordHandler:addAliasKeyword({ "armor" })
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addAliasKeyword({ "food" })
keywordHandler:addAliasKeyword({ "potion" })

-- Names
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_35" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_36" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_37" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_38" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_39" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_40" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_41" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_42" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_43" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_44" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_45" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_46" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_47" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_48" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_49" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_50" })
keywordHandler:addKeyword({ "zerbrus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_51" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_52" })
keywordHandler:addAliasKeyword({ "willie" })

-- Healing
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_53" }, function(player)
	return player:getCondition(CONDITION_POISON) ~= nil
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:removeCondition(CONDITION_POISON)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_54" }, function(player)
	return player:getHealth() < 65
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dallheim.stdmod_55" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dallheim.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
