local internalNpcName = "Izsh"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 338,
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

	if MsgContains(message, "mission") then
		if Player(creature):getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 33 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.izsh.multi_10")
		player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 34)
		player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission12, 0) --Questlog, Wrath of the Emperor "Mission 12: Just Rewards"
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.izsh.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
