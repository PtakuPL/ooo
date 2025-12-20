local internalNpcName = "Zerbrus"
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
	{ text = "Are you injured or poisoned? I can help you." },
	{ text = "For Rookgaard! For Tibia!" },
	{ text = "No monster shall go past me." },
	{ text = "The premium side of Rookgaard lies beyond." },
	{ text = "Want to know what monsters are good for you at your level? Just ask me!" },
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
keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "Greetings, |PLAYERNAME|! You're looking really bad. Let me heal your wounds.", i18nKey = "npc.zerbrus.greet_1" }, function(player)
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

keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "<nods> At your service, |PLAYERNAME|, protecting the {village} from {monsters}.", i18nKey = "npc.zerbrus.greet_2" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end)
keywordHandler:addAliasKeyword({ "hello" })

keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, text = "Bye, |PLAYERNAME|.", i18nKey = "npc.zerbrus.farewell_1" })
keywordHandler:addAliasKeyword({ "farewell" })

local function addMonsterKeyword(level, text, marks)
	keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
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
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_1" }, function(player)
	return not player:hasRookgaardShield()
end)

addMonsterKeyword(10, "It looks like you have mastered the drill.")
addMonsterKeyword(8, "Wow, |PLAYERNAME|! You have grown so much. I think there is nothing more I could teach you. Talk to the {oracle} to travel to other places which will pose more of a challenge for you. <bows>")
addMonsterKeyword(7, "Impressive, |PLAYERNAME|. You are almost strong enough to leave this island. Maybe you can take on minotaurs or rotworms now. There are no rotworms on this side of the island, ask Dallheim for their location.")
addMonsterKeyword(6, "Nice job out there,|PLAYERNAME|. If you are looking for a challenge, descend into the troll cave as deep as you can. Or explore the northern side of this island. Talk to {Dallheim} for directions.")
addMonsterKeyword(5, "Nice job out there, |PLAYERNAME|. Are you looking for other monsters than {trolls} or {wolves}? Maybe you'd like to check out {skeletons}. I'll mark them for you so you can find them easily.", { { position = Position(31977, 32228, 7), type = MAPMARK_GREENSOUTH, description = "Skeleton Cave" } })
addMonsterKeyword(4, "You're halfway to leaving this island, well done. {Spiders} or {wolves} are always good to fight, but if you want to move on, why don't you check out trolls? I'll mark you the troll cave on this side.", { { position = Position(32002, 32212, 7), type = MAPMARK_GREENSOUTH, description = "Troll Cave" } })
addMonsterKeyword(3, "Good progress, |PLAYERNAME|. You can still stay with {spiders} or {snakes}, but maybe you'd like to try fighting a {wolf}? I'll mark some of their hills on your map.", { { position = Position(32002, 32225, 7), type = MAPMARK_GREENNORTH, description = "Wolf Hill" }, { position = Position(31989, 32198, 7), type = MAPMARK_GREENNORTH, description = "Wolf Hill" } })
addMonsterKeyword(2, "You've already grown some, |PLAYERNAME|. You can either stay with {rats} or leave town to hunt {spiders} or {snakes}. I'll mark some spawns on your map.", { { position = Position(32001, 32238, 7), type = MAPMARK_GREENSOUTH, description = "Snake Pit" }, { position = Position(32046, 32188, 7), type = MAPMARK_GREENSOUTH, description = "Spider Cave" } })
addMonsterKeyword(1, "You are just beginning your journey, dear |PLAYERNAME|. You can start by helping me fight {rats} in the sewers. I'll mark an entrance on your map.", { { position = Position(32097, 32205, 7), type = MAPMARK_GREENSOUTH, description = "Sewer Entrance" } })

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_4" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_5" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_6" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_7" })
keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_8" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_9" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_10" })
keywordHandler:addKeyword({ "spider" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_11" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_12" })
keywordHandler:addKeyword({ "wolf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_13" })
keywordHandler:addAliasKeyword({ "wolves" })
keywordHandler:addKeyword({ "orc" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_14" })
keywordHandler:addKeyword({ "minotaur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_15" })
keywordHandler:addKeyword({ "bug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_16" })
keywordHandler:addKeyword({ "skeleton" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_17" })
keywordHandler:addKeyword({ "bear" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_18" })
keywordHandler:addKeyword({ "wasp" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_19" })
keywordHandler:addKeyword({ "snake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_20" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_21" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_22" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_23" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_24" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_25" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_26" })
keywordHandler:addKeyword({ "wilderness" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_27" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_28" })
keywordHandler:addKeyword({ "banor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_29" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_30" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_31" })
keywordHandler:addKeyword({ "book" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_32" })

keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_33" })
keywordHandler:addAliasKeyword({ "protect" })

keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_34" })

keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_35" })
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
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_36" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_37" })
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_38" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_39" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_40" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_41" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_42" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_43" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_44" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_45" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_46" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_47" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_48" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_49" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_50" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_51" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_52" })
keywordHandler:addKeyword({ "zerbrus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_53" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_54" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_55" })

-- Healing
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_56" }, function(player)
	return player:getCondition(CONDITION_POISON) ~= nil
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:removeCondition(CONDITION_POISON)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_57" }, function(player)
	return player:getHealth() < 65
end, function(player)
	local health = player:getHealth()
	if health < 65 then
		player:addHealth(65 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.zerbrus.stdmod_58" })

npcHandler:setMessage(MESSAGE_WALKAWAY, "Hm.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
