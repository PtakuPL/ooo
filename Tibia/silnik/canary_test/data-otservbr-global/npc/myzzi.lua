local internalNpcName = "Myzzi"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 982,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.myzzi.voice_1" },
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

	if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.Questline) < 1 then
		if MsgContains(message, "good") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.myzzi.say_7")
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "help") and npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.myzzi.say_8")
			npcHandler:setTopic(playerId, 3)
		elseif MsgContains(message, "threat") and npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.myzzi.say_9", "npc.myzzi.say_10" })
			npcHandler:setTopic(playerId, 4)
		elseif MsgContains(message, "courts") and npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.myzzi.say_11", "npc.myzzi.say_12" })
			npcHandler:setTopic(playerId, 5)
		elseif MsgContains(message, "entrances") and npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.myzzi.say_13")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			if MsgContains(message, "yes") then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.myzzi.say_14" })
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.Questline, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.myzzi.say_15")
			end
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello adventurer. It is {good} to see you.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Well, bye then.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
