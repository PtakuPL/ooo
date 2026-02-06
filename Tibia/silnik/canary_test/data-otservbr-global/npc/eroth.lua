local internalNpcName = "Eroth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 63,
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

	-- Check if NPC can interact with the creature
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Check if the message contains "mission"
	if MsgContains(message, "mission") then
		-- Check if player is starting the quest
		if player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.Questline) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eroth.say_1")
			npcHandler:setTopic(playerId, 1)
		-- Check if player has completed certain objectives
		elseif player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.Questline) == 2 and player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.DwarvenShield) == 1 and player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.MorningStar) == 1 and player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.BP1) == 1 and player:getStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.BP2) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eroth.say_2")
			player:addItem(3082, 1)
			player:addItem(3035, 10)
			player:setStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.Questline, 3)
			npcHandler:setTopic(playerId, 0)
		end
	-- Check if the player has accepted the mission
	elseif npcHandler:getTopic(playerId) == 1 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eroth.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eroth.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eroth.multi_3")
		player:addItem(3463, 1)
		player:setStorageValue(Storage.Quest.U8_1.ToBlindTheEnemy.Questline, 1)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_1" })
keywordHandler:addKeyword({ "kuridai" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_2" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_3" })
keywordHandler:addKeyword({ "deraisim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_4" })
keywordHandler:addKeyword({ "cenath" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_5" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_6" })
keywordHandler:addKeyword({ "spell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.eroth.stdmod_7" })

-- Greeting message
keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, i18nKey = "npc.eroth.greet_1" })
--Farewell message
keywordHandler:addFarewellKeyword({ "asgha thrazi" }, { npcHandler = npcHandler, i18nKey = "npc.eroth.farewell_1" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.eroth.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.eroth.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.eroth.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
