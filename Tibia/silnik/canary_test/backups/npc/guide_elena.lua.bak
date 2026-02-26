local internalNpcName = "Guide Elena"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 38,
	lookBody = 8,
	lookLegs = 13,
	lookFeet = 58,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.guide_elena.voice_1" },
	{ i18nKey = "npc.guide_elena.voice_2" },
	{ i18nKey = "npc.guide_elena.voice_3" },
	{ i18nKey = "npc.guide_elena.voice_4" },
	{ i18nKey = "npc.guide_elena.voice_5" },
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

local configMarks = {
	{ mark = "shops1", position = Position(32976, 32083, 6), markId = MAPMARK_BAG, description = "Magic Bazar" },
	{ mark = "depot", position = Position(32919, 32071, 6), markId = MAPMARK_LOCK, description = "Depot" },
	{ mark = "temple", position = Position(32958, 32078, 6), markId = MAPMARK_TEMPLE, description = "Temple" },
	{ mark = "shop2", position = Position(32908, 32123, 6), markId = MAPMARK_TEMPLE, description = "Armors and Weapons" },
	{ mark = "bank", position = Position(33011, 32053, 6), markId = MAPMARK_TEMPLE, description = "Bank" },
	{ mark = "shop3", position = Position(32976, 32045, 6), markId = MAPMARK_TEMPLE, description = "Foods and Plants" },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "map", "marks" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_elena.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_elena.say_2")
		local mark
		for i = 1, #configMarks do
			mark = configMarks[i]
			player:addMapMark(mark.position, mark.markId, mark.description)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) >= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_elena.say_3")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_1" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_2" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_3" })
keywordHandler:addKeyword({ "shops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_4" })
keywordHandler:addKeyword({ "depot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_5" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_6" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_elena.stdmod_8" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.guide_elena.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.guide_elena.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.guide_elena.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
