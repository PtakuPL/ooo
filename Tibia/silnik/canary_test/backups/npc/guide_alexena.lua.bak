local internalNpcName = "Guide Alexena"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 137,
	lookHead = 115,
	lookBody = 94,
	lookLegs = 78,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.guide_alexena.voice_1" },
	{ i18nKey = "npc.guide_alexena.voice_2" },
	{ i18nKey = "npc.guide_alexena.voice_3" },
	{ i18nKey = "npc.guide_alexena.voice_4" },
	{ i18nKey = "npc.guide_alexena.voice_5" },
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
	{ mark = "shops", position = Position(32335, 31803, 7), markId = MAPMARK_BAG, description = "Shops" },
	{ mark = "depot", position = Position(32331, 31782, 7), markId = MAPMARK_LOCK, description = "Depot" },
	{ mark = "temple", position = Position(32360, 31782, 7), markId = MAPMARK_TEMPLE, description = "Temple" },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "map", "marks" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_alexena.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_alexena.say_2")
		local mark
		for i = 1, #configMarks do
			mark = configMarks[i]
			player:addMapMark(mark.position, mark.markId, mark.description)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) >= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_alexena.say_3")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_1" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_2" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_3" })
keywordHandler:addKeyword({ "shops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_4" })
keywordHandler:addKeyword({ "depot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_5" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_6" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_alexena.stdmod_8" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.guide_alexena.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.guide_alexena.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.guide_alexena.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
