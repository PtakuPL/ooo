local internalNpcName = "Seymour"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 115,
	lookBody = 69,
	lookLegs = 87,
	lookFeet = 116,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.seymour.voice_1" },
	{ i18nKey = "npc.seymour.voice_2" },
	{ i18nKey = "npc.seymour.voice_3" },
	{ i18nKey = "npc.seymour.voice_4" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
npcHandler.rats = {}

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

-- Greeting and Farewell
local hiKeyword = keywordHandler:addGreetKeyword({ "hi" }, { npcHandler = npcHandler, text = "Hello, |PLAYERNAME|. Welcome to the Academy of Rookgaard. May I sign you up as a {student}?", i18nKey = "npc.seymour.greet_1" })
hiKeyword:addChildKeyword({ "student" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_1", reset = true })
hiKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_2", reset = true })
hiKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_3", reset = true })
keywordHandler:addAliasKeyword({ "hello" })

keywordHandler:addFarewellKeyword({ "bye" }, { npcHandler = npcHandler, text = "Good bye, |PLAYERNAME|! And remember: No running up and down in the academy!", i18nKey = "npc.seymour.farewell_1" })
keywordHandler:addAliasKeyword({ "farewell" })

-- Rats
local ratsKeyword = keywordHandler:addKeyword({ "%d+", "dead", "rat" }, StdModule.say, { npcHandler = npcHandler }, function(player, data)
	npcHandler.rats[player.uid] = data[1]
	return data[1] and data[1] > 0 and data[1] < 0xFFFFFFFF
end, function(player)
	npcHandler:say(string.format("Have you brought %d dead rats to me to pick up your reward?", npcHandler.rats[player.uid]), player.uid)
end)
ratsKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_4", reset = true }, function(player)
	return player:getItemCount(3994) >= npcHandler.rats[player.uid]
end, function(player)
	player:removeItem(3994, npcHandler.rats[player.uid])
	player:addMoney(2 * npcHandler.rats[player.uid])
end)
ratsKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_5", reset = true })
ratsKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_6", reset = true })

local ratKeyword = keywordHandler:addKeyword({ "dead", "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_7" })
ratKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_8", reset = true }, function(player)
	return player:getItemCount(3994) > 0
end, function(player)
	player:removeItem(3994, 1)
	player:addMoney(2)
end)
ratKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_9", reset = true })
ratKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_10", reset = true })

-- Quest
local boxKeyword = keywordHandler:addKeyword({ "box" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_11" })
boxKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_12", reset = true }, function(player)
	return player:getItemCount(2856) > 0
end, function(player)
	player:removeItem(2856, 1)
	player:addItem(3374, 1)
end)
boxKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_13", reset = true })

keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_14" }, function(player)
	return player:getLevel() >= 4
end)
keywordHandler:addAliasKeyword({ "quest" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_15" })
keywordHandler:addAliasKeyword({ "quest" })

keywordHandler:addKeyword({ "fuck" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_16" }, function(player)
	return player:getSex() == PLAYERSEX_FEMALE
end, function(player)
	player:getPosition():sendMagicEffect(CONST_ME_YELLOW_RINGS)
end)
keywordHandler:addKeyword({ "fuck" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_17" }, nil, function(player)
	player:getPosition():sendMagicEffect(CONST_ME_YELLOW_RINGS)
end)

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "island", "of", "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_18" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_19" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_20" })
keywordHandler:addKeyword({ "sir" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_21" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_22" })
keywordHandler:addKeyword({ "lesson" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_23" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_24" })
keywordHandler:addKeyword({ "deposit" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_25" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_26" })
keywordHandler:addKeyword({ "citizen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_27" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_28" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_29" })
keywordHandler:addKeyword({ "guard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_30" })
keywordHandler:addKeyword({ "vocation" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_31" })
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_32" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_33" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_34" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_35" })
keywordHandler:addKeyword({ "shop" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_36" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_37" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_38" })
keywordHandler:addKeyword({ "health" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_39" })
keywordHandler:addKeyword({ "death" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_40" })
keywordHandler:addKeyword({ "experience" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_41" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_42" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_43" })
keywordHandler:addKeyword({ "academy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_44" })
keywordHandler:addKeyword({ "library" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_45" })
keywordHandler:addKeyword({ "equip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_46" })
keywordHandler:addKeyword({ "money" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_47" })
keywordHandler:addKeyword({ "loot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_48" })
keywordHandler:addKeyword({ "corpse" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_49" })
keywordHandler:addKeyword({ "rope" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_50" })
keywordHandler:addKeyword({ "shovel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_51" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_52" })
keywordHandler:addKeyword({ "torch" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_53" })
keywordHandler:addKeyword({ "student" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_54" })
keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_55" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_56" })
keywordHandler:addKeyword({ "helmet" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_57" })
keywordHandler:addKeyword({ "shield" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_58" })
keywordHandler:addKeyword({ "shoe" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_59" })
keywordHandler:addKeyword({ "leg" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_60" })
keywordHandler:addKeyword({ "food" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_61" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_62" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_63" })
keywordHandler:addKeyword({ "potion" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_64" })
keywordHandler:addKeyword({ "antidote" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_65" })
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_66" })
keywordHandler:addKeyword({ "island" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_67" })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_68" })
keywordHandler:addKeyword({ "village" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_69" })
keywordHandler:addKeyword({ "bridge" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_70" })
keywordHandler:addKeyword({ "main" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_71" })
keywordHandler:addKeyword({ "fighting" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_72" })
keywordHandler:addKeyword({ "skill" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_73" })
keywordHandler:addKeyword({ "level" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_74" })
keywordHandler:addKeyword({ "farm" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_75" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_76" })
keywordHandler:addKeyword({ "trade" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_77" })

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_78" })
keywordHandler:addAliasKeyword({ "information" })

local destinyKeyword = keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_79" }, function(player)
	return player:getStorageValue(Storage.RookgaardDestiny) == -1
end)
destinyKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, reset = true }, nil, function(player)
	local destiny = math.random(1, 4)
	if destiny == 1 then
		npcHandler:say("Hmmm, let me look at you. You got that intelligent sparkle in your eyes and you'd love to handle great power - that must be a future sorcerer!", player.uid)
	elseif destiny == 2 then
		npcHandler:say("Hmmm, let me look at you. You have an aura of great wisdom and may have healing hands as well as a sense for the powers of nature - I think you're a natural born druid!", player.uid)
	elseif destiny == 3 then
		npcHandler:say("Hmmm, let me look at you. <missing message, destiny for paladin>!", player.uid)
	elseif destiny == 4 then
		npcHandler:say("Hmmm, let me look at you. Strong and sturdy, with a determined look in your eyes - no doubt the knight profession would be suited for you!", player.uid)
	end
	player:setStorageValue(Storage.RookgaardDestiny, destiny)
end)

keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_80" }, function(player)
	return player:getStorageValue(Storage.RookgaardDestiny) == 1
end)
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_81" }, function(player)
	return player:getStorageValue(Storage.RookgaardDestiny) == 2
end)
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_82" }, function(player)
	return player:getStorageValue(Storage.RookgaardDestiny) == 3
end)
keywordHandler:addKeyword({ "destiny" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_83" }, function(player)
	return player:getStorageValue(Storage.RookgaardDestiny) == 4
end)

-- Names
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_84" })
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_85" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_86" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_87" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_88" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_89" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_90" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_91" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_92" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_93" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_94" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_95" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_96" })
keywordHandler:addKeyword({ "lily" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_97" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_98" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_99" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_100" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_101" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_102" })
keywordHandler:addKeyword({ "zerbrus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.seymour.stdmod_103" })

npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye! And remember: No running up and down in the academy!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
