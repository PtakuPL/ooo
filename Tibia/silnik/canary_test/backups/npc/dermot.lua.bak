local internalNpcName = "Dermot"
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
	lookHead = 57,
	lookBody = 49,
	lookLegs = 19,
	lookFeet = 95,
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

	if MsgContains(message, "present") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dermot.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "key") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dermot.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(3218, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dermot.say_3")
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission05, 3)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeMoneyBank(2000) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dermot.say_4")
				local key = player:addItem(2968, 1)
				if key then
					key:setActionId(3940)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.dermot.say_5")
			end
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_1" })
keywordHandler:addKeyword({ "magistrate" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_2" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_4" })
keywordHandler:addKeyword({ "fibula" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_5" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_6" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.dermot.stdmod_7" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.dermot.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.dermot.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.dermot.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
