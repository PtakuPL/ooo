local mType = Game.createMonsterType("Hacker")
local monster = {}

monster.description = "a hacker"
monster.experience = 45
monster.outfit = {
	lookType = 8,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
	lookMount = 0,
}

monster.health = 430
monster.maxHealth = 430
monster.race = "blood"
monster.corpse = 5980
monster.speed = 125
monster.manaCost = 0

monster.changeTarget = {
	interval = 5000,
	chance = 8,
}

monster.strategiesTarget = {
	nearest = 70,
	health = 10,
	damage = 10,
	random = 10,
}

monster.flags = {
	summonable = false,
	attackable = true,
	hostile = true,
	convinceable = false,
	pushable = false,
	rewardBoss = false,
	illusionable = false,
	canPushItems = true,
	canPushCreatures = true,
	staticAttackChance = 90,
	targetDistance = 1,
	runHealth = 429,
	healthHidden = false,
	isBlockable = false,
	canWalkOnEnergy = true,
	canWalkOnFire = true,
	canWalkOnPoison = true,
}

monster.light = {
	level = 0,
	color = 0,
}

monster.voices = {
	interval = 5000,
	chance = 10,
	{ text = "Feel the wrath of me dos attack!", yell = false , i18nKey = "monster.hacker.voice_1"},
	{ text = "You're next!", yell = false , i18nKey = "monster.hacker.voice_2"},
	{ text = "Gimme free gold!", yell = false , i18nKey = "monster.hacker.voice_3"},
	{ text = "Me sooo smart!", yell = false , i18nKey = "monster.hacker.voice_4"},
	{ text = "Me have a cheating link for you!", yell = false , i18nKey = "monster.hacker.voice_5"},
	{ text = "Me is GM!", yell = false , i18nKey = "monster.hacker.voice_6"},
	{ text = "Gimme your password!", yell = false , i18nKey = "monster.hacker.voice_7"},
	{ text = "Me just need the code!", yell = false , i18nKey = "monster.hacker.voice_8"},
	{ text = "Me not stink!", yell = false , i18nKey = "monster.hacker.voice_9"},
	{ text = "Me other char is highlevel!", yell = false , i18nKey = "monster.hacker.voice_10"},
}

monster.loot = {
	{ id = 2914, chance = 6666 }, -- lamp
	{ name = "gold coin", chance = 100000, maxCount = 12 },
	{ name = "battle axe", chance = 5000 },
	{ name = "halberd", chance = 10000 },
	{ name = "axe", chance = 10000 },
	{ name = "war hammer", chance = 5000 },
	{ name = "ham", chance = 50000 },
	{ id = 6570, chance = 5538 }, -- surprise bag
	{ id = 6571, chance = 1538 }, -- surprise bag
}

monster.attacks = {
	{ name = "melee", interval = 1000, chance = 100, minDamage = 0, maxDamage = -83 },
}

monster.defenses = {
	defense = 12,
	armor = 15,
	mitigation = 0.36,
	{ name = "speed", interval = 1000, chance = 15, speedChange = 290, effect = CONST_ME_MAGIC_RED, target = false, duration = 6000 },
	{ name = "outfit", interval = 10000, chance = 15, effect = CONST_ME_MAGIC_RED, target = false, duration = 500, outfitMonster = "pig" },
}

monster.elements = {
	{ type = COMBAT_PHYSICALDAMAGE, percent = 0 },
	{ type = COMBAT_ENERGYDAMAGE, percent = 0 },
	{ type = COMBAT_EARTHDAMAGE, percent = 0 },
	{ type = COMBAT_FIREDAMAGE, percent = 100 },
	{ type = COMBAT_LIFEDRAIN, percent = 0 },
	{ type = COMBAT_MANADRAIN, percent = 0 },
	{ type = COMBAT_DROWNDAMAGE, percent = 0 },
	{ type = COMBAT_ICEDAMAGE, percent = 0 },
	{ type = COMBAT_HOLYDAMAGE, percent = 0 },
	{ type = COMBAT_DEATHDAMAGE, percent = 0 },
}

monster.immunities = {
	{ type = "paralyze", condition = false },
	{ type = "outfit", condition = false },
	{ type = "invisible", condition = false },
	{ type = "bleed", condition = false },
}

mType:register(monster)
