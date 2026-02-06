local internalNpcName = "Garamond"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 432,
	lookHead = 0,
	lookBody = 113,
	lookLegs = 109,
	lookFeet = 107,
	lookAddons = 2,
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

-- spells for druid and sorcerer
keywordHandler:addSpellKeyword({ "findperson" }, {
	npcHandler = npcHandler,
	spellName = "Find Person",
	price = 0,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "apprenticesstrike" }, {
	npcHandler = npcHandler,
	spellName = "Apprentice's Strike",
	price = 0,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "lighthealing" }, {
	npcHandler = npcHandler,
	spellName = "Light Healing",
	price = 0,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "light" }, {
	npcHandler = npcHandler,
	spellName = "Light",
	price = 0,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "magicrope" }, {
	npcHandler = npcHandler,
	spellName = "Magic Rope",
	price = 0,
	level = 9,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "curepoison" }, {
	npcHandler = npcHandler,
	spellName = "Cure Poison",
	price = 0,
	level = 10,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "energystrike" }, {
	npcHandler = npcHandler,
	spellName = "Energy Strike",
	price = 0,
	level = 12,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "levitate" }, {
	npcHandler = npcHandler,
	spellName = "Levitate",
	price = 0,
	level = 12,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "greatlight" }, {
	npcHandler = npcHandler,
	spellName = "Great Light",
	price = 0,
	level = 13,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "terrastrike" }, {
	npcHandler = npcHandler,
	spellName = "Terra Strike",
	price = 0,
	level = 13,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "haste" }, {
	npcHandler = npcHandler,
	spellName = "Haste",
	price = 0,
	level = 14,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "flamestrike" }, {
	npcHandler = npcHandler,
	spellName = "Flame Strike",
	price = 0,
	level = 14,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "icestrike" }, {
	npcHandler = npcHandler,
	spellName = "Ice Strike",
	price = 0,
	level = 15,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "poisonfield" }, {
	npcHandler = npcHandler,
	spellName = "Poison Field",
	price = 0,
	level = 14,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "firefield" }, {
	npcHandler = npcHandler,
	spellName = "Fire Field",
	price = 0,
	level = 15,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "lightmagicmissile" }, {
	npcHandler = npcHandler,
	spellName = "Light Magic Missile",
	price = 0,
	level = 15,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
keywordHandler:addSpellKeyword({ "energyfield" }, {
	npcHandler = npcHandler,
	spellName = "Energy Field",
	price = 0,
	level = 18,
	vocation = {
		VOCATION.BASE_ID.SORCERER,
		VOCATION.BASE_ID.DRUID,
	},
})
-- spells for sorcerer
keywordHandler:addSpellKeyword({ "deathstrike" }, {
	npcHandler = npcHandler,
	spellName = "Death Strike",
	price = 0,
	level = 16,
	vocation = VOCATION.BASE_ID.SORCERER,
})
keywordHandler:addSpellKeyword({ "firewave" }, {
	npcHandler = npcHandler,
	spellName = "Fire Wave",
	price = 0,
	level = 18,
	vocation = VOCATION.BASE_ID.SORCERER,
})
-- spells for druid
keywordHandler:addSpellKeyword({ "icewave" }, {
	npcHandler = npcHandler,
	spellName = "Ice Wave",
	price = 0,
	level = 18,
	vocation = VOCATION.BASE_ID.DRUID,
})
keywordHandler:addSpellKeyword({ "physicalstrike" }, {
	npcHandler = npcHandler,
	spellName = "Physical Strike",
	price = 0,
	level = 16,
	vocation = VOCATION.BASE_ID.DRUID,
})
keywordHandler:addSpellKeyword({ "healfriend" }, {
	npcHandler = npcHandler,
	spellName = "Heal Friend",
	price = 0,
	level = 18,
	vocation = VOCATION.BASE_ID.DRUID,
})

keywordHandler:addKeyword({ "healing spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_1",
})
keywordHandler:addKeyword({ "support spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_2",
})
keywordHandler:addKeyword({ "attack spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_3",
})
keywordHandler:addKeyword({ "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_4",
})

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_5",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_6",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_7",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_8",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_9",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_10",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_11",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_12",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_13",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_14",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_15",
})
keywordHandler:addKeyword({ "ser tybald" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_16",
})
keywordHandler:addKeyword({ "wentworth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.garamond.stdmod_17",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "magic") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.garamond.say_1", "npc.garamond.say_2", "npc.garamond.say_3", "npc.garamond.say_4", "npc.garamond.say_5", "npc.garamond.say_6"}, 100)
	elseif MsgContains(message, "mainland") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.garamond.say_7", "npc.garamond.say_8", "npc.garamond.say_9"}, 100)
	elseif MsgContains(message, "tibian") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.garamond.say_10", "npc.garamond.say_11"}, 100)
	elseif MsgContains(message, "vocation") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.garamond.say_12", "npc.garamond.say_13", "npc.garamond.say_14"}, 100)
	elseif MsgContains(message, "oressa") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.garamond.say_15", "npc.garamond.say_16"}, 100)
	end
end

npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.garamond.greet_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
