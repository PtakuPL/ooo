local internalNpcName = "A Dead Bureaucrat"
local npcType = Game.createNpcType("A Dead Bureaucrat (1)")
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

	if type(fallback) == "function" then
		fallback(player)
	elseif fallback then
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

if npcI18n and npcHandler.setLocalizedMessage then
	npcI18n.setLocalizedGreet(npcHandler, "npc.a_dead_bureaucrat.greet", {
		args = localizedGreetArgs,
		fallback = "Hello traveler, welcome to the atrium of Pumin's Domain.",
	})
	npcI18n.setLocalizedFarewell(npcHandler, "npc.a_dead_bureaucrat.farewell", {
		fallback = "Good bye and don't forget me!",
	})
	npcI18n.setLocalizedWalkaway(npcHandler, "npc.a_dead_bureaucrat.walkaway", {
		fallback = "Good bye and don't forget me!",
	})
else
	npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye and don't forget me!")
	npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye and don't forget me!")
end

local config = {
	[VOCATION.BASE_ID.SORCERER] = "wand",
	[VOCATION.BASE_ID.DRUID] = "rod",
	[VOCATION.BASE_ID.PALADIN] = "bow",
	[VOCATION.BASE_ID.KNIGHT] = "sword",
}

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

	local vocation = player:getVocation()
	local vocationId = vocation:getId()
	local vocationBaseId = vocation:getBaseId()

	if MsgContains(message, "pumin") then
		if npcHandler:getTopic(playerId) == 0 and player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) < 1 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.pumin_intro", function()
				npcHandler:say("Sure, where else. Everyone likes to meet my master, he is a great demon, isn't he? Your name is ...?", npc, creature)
			end)
			npcHandler:setTopic(playerId, 1)
		elseif npcHandler:getTopic(playerId) == 3 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 1)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form356_intro", function()
				npcHandler:say("How very interesting. I need to tell that to my master immediately. Please go to my colleagues and ask for Form 356. You will need it in order to proceed.", npc, creature)
			end)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, player:getName()) then
		if npcHandler:getTopic(playerId) == 1 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.ask_vocation", function(p)
				npcHandler:say("Alright " .. (p and p:getName() or "stranger") .. ". Vocation?", npc, creature)
			end, { player:getName() })
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, Vocation(vocationId):getName()) then
		if npcHandler:getTopic(playerId) == 2 then
			local weapon = config[vocationBaseId] or "weapon"
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.warn_weapon", function()
				npcHandler:say("Huhu, please don't hurt me with your " .. weapon .. "! Reason of your visit?", npc, creature)
			end, { weapon })
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "411") then
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 3 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.need_form287", function()
				npcHandler:say("Form 411? You need Form 287 to get that! Do you have it?", npc, creature)
			end)
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 5 then
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.need_form287", function()
				npcHandler:say("Form 411? You need Form 287 to get that! Do you have it?", npc, creature)
			end)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 4 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 4)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form287_denied", function()
				npcHandler:say("Oh, what a pity. Go see one of my colleagues. I give you the permission to get Form 287. Bye!", npc, creature)
			end)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 6)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form411_granted", function()
				npcHandler:say("Great. Here you are. Form 411. Come back anytime you want to talk. Bye.", npc, creature)
			end)
		end
	elseif MsgContains(message, "356") then
		if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) == 8 then
			player:setStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin, 9)
			sayLocalized(npc, creature, "npc.a_dead_bureaucrat.form356_done", function()
				npcHandler:say("INCREDIBLE, you did it!! Have fun at Pumin's Domain!", npc, creature)
			end)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
