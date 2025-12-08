local internalNpcName = "A Dead Bureaucrat"
local npcType = Game.createNpcType("A Dead Bureaucrat (2)")
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

	if MsgContains(message, "287") then
		local player = Player(creature)
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 4 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 5)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form287_grant", "Sure, you can get it from me. Here you are. Bye")
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
