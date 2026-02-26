local internalNpcName = "Lothar"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 114,
	lookBody = 113,
	lookLegs = 132,
	lookFeet = 132,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.lothar.voice_1" },
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

keywordHandler:addKeyword({ "here" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_2" })
keywordHandler:addKeyword({ "animal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_3" })
keywordHandler:addKeyword({ "stable" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_4" })
keywordHandler:addKeyword({ "tamed" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_5" })
keywordHandler:addKeyword({ "item" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_6" })
keywordHandler:addKeyword({ "bag of apple slices" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_7" })
keywordHandler:addKeyword({ "bamboo leaves" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_8" })
keywordHandler:addKeyword({ "carrot on a stick" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_9" })
keywordHandler:addKeyword({ "decorative ribbon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_10" })
keywordHandler:addKeyword({ "diapason" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_11" })
keywordHandler:addKeyword({ "fist on a stick" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_12" })
keywordHandler:addKeyword({ "four-leaf clover" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_13" })
keywordHandler:addKeyword({ "foxtail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_14" })
keywordHandler:addKeyword({ "golem wrench" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_15" })
keywordHandler:addKeyword({ "giant shrimp" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_16" })
keywordHandler:addKeyword({ "glow wine" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_17" })
keywordHandler:addKeyword({ "golden can of oil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_18" })
keywordHandler:addKeyword({ "harness" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_19" })
keywordHandler:addKeyword({ "hunting horn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_20" })
keywordHandler:addKeyword({ "iron loadstone" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_21" })
keywordHandler:addKeyword({ "leather whip" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_22" })
keywordHandler:addKeyword({ "leech" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_23" })
keywordHandler:addKeyword({ "maxilla maximus" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_24" })
keywordHandler:addKeyword({ "music box" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_25" })
keywordHandler:addKeyword({ "nail case" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_26" })
keywordHandler:addKeyword({ "nightmare horn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_27" })
keywordHandler:addKeyword({ "reins" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_28" })
keywordHandler:addKeyword({ "scorpion sceptre" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_29" })
keywordHandler:addKeyword({ "slingshot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_30" })
keywordHandler:addKeyword({ "slug drug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_31" })
keywordHandler:addKeyword({ "sugar oat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_32" })
keywordHandler:addKeyword({ "sweet smelling bait" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_33" })
keywordHandler:addKeyword({ "tin key" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_34" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lothar.stdmod_35" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "control unit") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_9")
	elseif MsgContains(message, "golden fir cone") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_7")
	elseif MsgContains(message, "melting horn") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_5")
	elseif table.contains({ "arkarra", "stampor" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lothar.multi_2")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lothar.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.lothar.farewell_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
