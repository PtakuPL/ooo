local internalNpcName = "Aneus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 38,
	lookBody = 50,
	lookLegs = 58,
	lookFeet = 116,
	lookAddons = 0,
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

keywordHandler:addKeyword({ "soldiers" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.aneus.stdmod_1" })
keywordHandler:addKeyword({ "orcs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.aneus.stdmod_2" })
keywordHandler:addKeyword({ "cruelty" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.aneus.stdmod_3" })
keywordHandler:addKeyword({ "island" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.aneus.stdmod_4" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "story") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_29")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_30")
	elseif MsgContains(message, "city") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_27")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_28")
	elseif MsgContains(message, "works") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_25")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_26")
	elseif MsgContains(message, "rebel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_24")
	elseif MsgContains(message, "friends") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_21")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_22")
	elseif MsgContains(message, "plan") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_19")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_20")
	elseif MsgContains(message, "stroke") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_16")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_17")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_18")
	elseif MsgContains(message, "walked back") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_13")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_14")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_15")
	elseif MsgContains(message, "help") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_9")
	elseif MsgContains(message, "destruction") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.aneus.multi_6")
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.aneus.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.aneus.farewell_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
