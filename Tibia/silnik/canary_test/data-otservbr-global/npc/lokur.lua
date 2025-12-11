local internalNpcName = "Lokur"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 57,
	lookBody = 79,
	lookLegs = 79,
	lookFeet = 95,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.lokur.voice_1", yell = false },
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

	-- Parse bank
	npc:parseBank(message, npc, creature, npcHandler)
	-- Parse guild bank
	npc:parseGuildBank(message, npc, creature, playerId, npcHandler)
	-- Normal messages
	npc:parseBankMessages(message, npc, creature, npcHandler)

	if MsgContains(message, "ticket") then
		if Player(creature):getStorageValue(Storage.WagonTicket) >= os.time() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_1")
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_2")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) > 0 then
		local player = Player(creature)
		if npcHandler:getTopic(playerId) == 9 then
			if not player:removeMoneyBank(250) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.WagonTicket, os.time() + 7 * 24 * 60 * 60)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_4")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_5")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "measurements") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) >= 6 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.MeasurementsKroox) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lokur.say_6")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) + 1)
		else
			npcHandler:say("...", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Yes? What may I do for you, |PLAYERNAME|? Bank business, perhaps?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Have a nice day.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Have a nice day.")
npcHandler:setCallback(CALLBACK_GREET, NpcBankGreetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
