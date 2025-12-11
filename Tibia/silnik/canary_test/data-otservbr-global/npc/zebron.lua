local internalNpcName = "Zebron"
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
	lookHead = 114,
	lookBody = 18,
	lookLegs = 71,
	lookFeet = 128,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.zebron.voice_1" },
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

	if MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_1")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 4 then
			if not player:removeMoneyBank(100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_2")
				npcHandler:setTopic(playerId, 0)
				return false
			end

			npc:getPosition():sendMagicEffect(CONST_ME_CRAPS)
			local realRoll = math.random(30)
			local roll = math.random(5)
			if realRoll < 30 then
				npcHandler:say("Ok, here we go ... " .. roll .. "! You have lost. Bad luck. One more game?", npc, creature)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_4")
				player:addItem(5792, 1)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "game") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "money") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_6")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "dice") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_7")
			npcHandler:setTopic(playerId, 4)
		end
	elseif tonumber(message) then
		local amount = tonumber(message)
		if amount < 1 or amount > 99 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_8")
			npcHandler:setTopic(playerId, 3)
			return false
		end

		if not player:removeMoneyBank(amount) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_9")
			npcHandler:setTopic(playerId, 0)
			return false
		end

		npc:getPosition():sendMagicEffect(CONST_ME_CRAPS)
		local roll = math.random(6)
		if roll < 6 then
			npcHandler:say("Ok, here we go ... " .. roll .. "! You have lost. Bad luck. One more game?", npc, creature)
		else
			npcHandler:say("Ok, here we go ... 6! You have won " .. amount * 5 .. ", congratulations. One more game?", npc, creature)
			player:addMoney(amount * 5)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zebron.say_12")
		npcHandler:setTopic(playerId, 1)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, high roller. So you care for a game, |PLAYERNAME|?")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Hey, you can't leave. Luck is smiling on you. I can feel it!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Hey, you can't leave, |PLAYERNAME|. Luck is smiling on you. I can feel it!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
