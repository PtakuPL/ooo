local internalNpcName = "Cerdras"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 144,
	lookHead = 20,
	lookBody = 96,
	lookLegs = 41,
	lookFeet = 22,
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

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cerdras.stdmod_1" })
keywordHandler:addKeyword({ "nature" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.cerdras.stdmod_2" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "elements") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_10")
	elseif MsgContains(message, "song") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.cerdras.multi_6")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.cerdras.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.cerdras.farewell_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
