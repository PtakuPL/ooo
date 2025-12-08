local internalNpcName = "A Dead Bureaucrat"
local npcType = Game.createNpcType("A Dead Bureaucrat (3)")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 33,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Now where did I put that form?" },
	{ text = "Hail Pumin. Yes, hail." },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n

local function sayLocalized(npc, creature, key, fallback, args)
	local player = Player(creature)
	if player and npcI18n and key then
		if npcI18n.npcSay(npcHandler, npc, creature, key, args) then
			return true
		end
	end

	if not fallback then
		return true
	end

	if type(fallback) == "function" then
		fallback(player)
	else
		npcHandler:say(fallback, npc, creature)
	end
	return true
end

local function localizedGreetArgs(player)
	if not player then
		return nil
	end

	local descriptor = player:getSex() == PLAYERSEX_FEMALE and "beautiful lady" or "handsome gentleman"
	return { player:getName(), descriptor }
end

if npcI18n and npcHandler.setLocalizedMessage then
	npcI18n.setLocalizedGreet(npcHandler, "npc.a_dead_bureaucrat.greet", {
		args = localizedGreetArgs,
	})
	npcI18n.setLocalizedFarewell(npcHandler, "npc.a_dead_bureaucrat.farewell")
	npcI18n.setLocalizedWalkaway(npcHandler, "npc.a_dead_bureaucrat.walkaway")
else
	npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye and don't forget me!")
	npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye and don't forget me!")
end

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

local function greetCallback(npc, creature)
	if npcI18n and npcHandler.setLocalizedMessage then
		return true
	end

	local player = Player(creature)
	if not player then
		return false
	end

	local descriptor = player:getSex() == PLAYERSEX_FEMALE and "beautiful lady" or "handsome gentleman"
	npcHandler:setMessage(MESSAGE_GREET, "Hello " .. descriptor .. ", welcome to the atrium of Pumin's Domain. We require some information from you before we can let you pass. Where do you want to go?")
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local vocation = Vocation(player:getVocation():getBase():getId())
	local vocationName = vocation:getName()

	if MsgContains(message, "pumin") then
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 2 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form145_intro", "Tell me if you liked it when you come back. What is your name?")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, player:getName()) then
		if npcHandler:getTopic(playerId) == 1 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.ask_vocation", function(p)
				npcHandler:say("Alright " .. (p and p:getName() or "stranger") .. ". Vocation?", npc, creature)
			end, { player:getName() })
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, vocationName) then
		if npcHandler:getTopic(playerId) == 2 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.same_vocation", function()
				npcHandler:say("I was a " .. vocationName .. ", too, before I died!! What do you want from me?", npc, creature)
			end, { vocationName })
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "145") then
		if npcHandler:getTopic(playerId) == 3 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 3)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form145_require_411", "That's right, you can get Form 145 from me. However, I need Form 411 first. Come back when you have it.")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 6 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 7)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form145_granted", "Well done! You have form 411!! Here is Form 145. Have fun with it.")
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
