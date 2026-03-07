local internalNpcName = "Guide Edna"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 276,
	lookHead = 58,
	lookBody = 43,
	lookLegs = 38,
	lookFeet = 76,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.guide_edna.voice_1" },
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
	{ mark = "shops", position = Position(32827, 31239, 7), markId = MAPMARK_BAG, description = "Weapons and Amror" },
	{ mark = "depot", position = Position(32786, 31248, 7), markId = MAPMARK_LOCK, description = "Depot" },
	{ mark = "temple", position = Position(32786, 31276, 7), markId = MAPMARK_TEMPLE, description = "Temple" },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "map", "marks" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_edna.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_edna.say_2")
		local mark
		for i = 1, #configMarks do
			mark = configMarks[i]
			player:addMapMark(mark.position, mark.markId, mark.description)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) >= 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.guide_edna.say_3")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "information" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_1" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_2" })
keywordHandler:addKeyword({ "bank" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_3" })
keywordHandler:addKeyword({ "shops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_4" })
keywordHandler:addKeyword({ "depot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_5" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_6" })
keywordHandler:addKeyword({ "town" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_7" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.guide_edna.stdmod_8" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.guide_edna.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.guide_edna.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.guide_edna.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
