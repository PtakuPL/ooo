local internalNpcName = "Ser Tybald"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 134,
	lookHead = 97,
	lookBody = 19,
	lookLegs = 60,
	lookFeet = 115,
	lookAddons = 3,
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

-- spells for knight and paladin
keywordHandler:addSpellKeyword({ "findperson" }, {
	npcHandler = npcHandler,
	spellName = "Find Person",
	price = 80,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "light" }, {
	npcHandler = npcHandler,
	spellName = "Light",
	price = 0,
	level = 8,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "magicrope" }, {
	npcHandler = npcHandler,
	spellName = "Magic Rope",
	price = 200,
	level = 9,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "curepoison" }, {
	npcHandler = npcHandler,
	spellName = "Cure Poison",
	price = 150,
	level = 10,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "levitate" }, {
	npcHandler = npcHandler,
	spellName = "Levitate",
	price = 500,
	level = 12,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "haste" }, {
	npcHandler = npcHandler,
	spellName = "Haste",
	price = 600,
	level = 14,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
keywordHandler:addSpellKeyword({ "greatlight" }, {
	npcHandler = npcHandler,
	spellName = "Great Light",
	price = 500,
	level = 13,
	vocation = {
		VOCATION.BASE_ID.PALADIN,
		VOCATION.BASE_ID.KNIGHT,
	},
})
--spells for paladin
keywordHandler:addSpellKeyword({ "conjurebolt" }, {
	npcHandler = npcHandler,
	spellName = "Conjure Bolt",
	price = 750,
	level = 17,
	vocation = VOCATION.BASE_ID.PALADIN,
})
keywordHandler:addSpellKeyword({ "conjurepoisonedarrow" }, {
	npcHandler = npcHandler,
	spellName = "Conjure Poisoned Arrow",
	price = 700,
	level = 16,
	vocation = VOCATION.BASE_ID.PALADIN,
})
keywordHandler:addSpellKeyword({ "conjurearrow" }, {
	npcHandler = npcHandler,
	spellName = "Conjure Arrow",
	price = 450,
	level = 13,
	vocation = VOCATION.BASE_ID.PALADIN,
})
keywordHandler:addSpellKeyword({ "lighthealing" }, {
	npcHandler = npcHandler,
	spellName = "Light Healing",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.PALADIN,
})
-- spells for knight
keywordHandler:addSpellKeyword({ "brutalstrike" }, {
	npcHandler = npcHandler,
	spellName = "Brutal Strike",
	price = 1000,
	level = 16,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "woundcleansing" }, {
	npcHandler = npcHandler,
	spellName = "Wound Cleansing",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})

keywordHandler:addKeyword({ "healing spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_1",
})
keywordHandler:addKeyword({ "support spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_2",
})
keywordHandler:addKeyword({ "attack spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_3",
})
keywordHandler:addKeyword({ "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_4",
})

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_5",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_6",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_7",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_8",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_9",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_10",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_11",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_12",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_13",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_14",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_15",
})
keywordHandler:addKeyword({ "ser tybald" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_16",
})
keywordHandler:addKeyword({ "wentworth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.ser_tybald.stdmod_17",
})

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "magic") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.ser_tybald.say_1", "npc.ser_tybald.say_2", "npc.ser_tybald.say_3", "npc.ser_tybald.say_4", "npc.ser_tybald.say_5", "npc.ser_tybald.say_6"}, 100)
	elseif MsgContains(message, "mainland") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.ser_tybald.say_7", "npc.ser_tybald.say_8", "npc.ser_tybald.say_9"}, 100)
	elseif MsgContains(message, "tibian") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.ser_tybald.say_10", "npc.ser_tybald.say_11"}, 100)
	elseif MsgContains(message, "vocation") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.ser_tybald.say_12", "npc.ser_tybald.say_13", "npc.ser_tybald.say_14"}, 100)
	elseif MsgContains(message, "oressa") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.ser_tybald.say_15", "npc.ser_tybald.say_16"}, 100)
	end
end

npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.ser_tybald.greet_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
