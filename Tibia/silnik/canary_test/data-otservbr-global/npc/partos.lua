local internalNpcName = "Partos"
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
	lookHead = 116,
	lookBody = 56,
	lookLegs = 95,
	lookFeet = 121,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "supplies") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.multi_5")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.say_1")
		end
	elseif MsgContains(message, "ankrahmun") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.partos.multi_3")
	end
	return true
end

keywordHandler:addKeyword({ "prison" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.partos.stdmod_1" })
keywordHandler:addKeyword({ "jail" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.partos.stdmod_2" })
keywordHandler:addKeyword({ "cell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.partos.stdmod_3" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.partos.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.partos.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.partos.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
