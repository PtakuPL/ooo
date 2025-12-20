local internalNpcName = "Mr Morris"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 115,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.mr_morris.voice_1" },
	{ i18nKey = "npc.mr_morris.voice_2" },
	{ i18nKey = "npc.mr_morris.voice_3" },
	{ i18nKey = "npc.mr_morris.voice_4" },
	{
		i18nKey = "npc.mr_morris.voice_5",
	},
	{ i18nKey = "npc.mr_morris.voice_6" },
	{ i18nKey = "npc.mr_morris.voice_7" },
	{ i18nKey = "npc.mr_morris.voice_8" },
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

	if MsgContains(message, "amulet") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_1"}, 10)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet) == 2 and player:getItemCount(21379) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_2"}, 0)
			player:removeItem(21379, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "log book") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TornLogBook) < 1 then
			npcHandler:say(
				"The first log book from the first foray group has been stolen by trolls. \z
				One wonders what for, as they can hardly read! Anyway, we need it back. \z
				Would you go looking for it?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TornLogBook) == 1 and player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook) == 1 and player:getItemCount(21378) == 1 then
			npcHandler:say(
				"Ah, yes, that's it! Torn and gnawed, but, ah well, the information is still retrievable. \z
				Thank you. Here's your reward.",
				npc,
				creature
			)
			player:removeItem(21378, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "herbs") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb) < 1 then
			npcHandler:say(
				"Some of those salamanders have crawled into Oressa's herb garden and munched all her Dawnfire herbs. \z
				Would you get some fresh herbs?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb) == 2 then
			npcHandler:say(
				"Ah, wonderful. Freshly cut and full of potent... whatever it is it does. \z
				Thanks. Here's your reward.",
				npc,
				creature
			)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb, 3)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "key") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) < 1 then
			npcHandler:say(
				"This is an undercover thing - the key to the dormitory has disappeared. \z
				No one wants to own up who has lost it, at least not to me. Maybe they'll talk to you. \z
				I'll reward you if you find it. You in?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_1")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say(
				"Wonderful. I don't believe you will find Dormovo alive, though. \z
				He would not have stayed abroad that long without refilling his inkpot for his research notes. \z
				But at least the amulet should be retrieved.",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheLostAmulet, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:say(
				"Good. The logbook or whatever is left of it is very valuable to my research. \z
				If you return its contents to me, I will reward you accordingly.",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheStolenLogBook, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_3", "npc.mr_morris.say_4"}, 10)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheRareHerb, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.HerbFlower, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_2")
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_3")
			player:removeItem(21392, 1)
			player:addItem(3031, 50)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:say(
				"Good. Killing 20 will teach them a lesson, without provoking desperate retaliation. \z
				Still, take care!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisTrollCount, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			npcHandler:say(
				"Good. Killing 20 will teach them a lesson, without provoking desperate retaliation. \z
				Still, take care!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblinCount, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			npcHandler:say(
				"Good. Killing 20 will teach them a lesson, without provoking desperate retaliation. \z
				Still, take care!",
				npc,
				creature
			)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos, 1)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinosCount, 0)
			npcHandler:setTopic(playerId, 0)
		end
		--End mission
		--Start Task
	elseif MsgContains(message, "trolls") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_5", "npc.mr_morris.say_6"}, 10)
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisTrollCount) >= 20 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_4")
				player:setStorageValue(14898, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorriskTroll, 2)
				player:addItem(3031, 50)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_5")
			end
		end
	elseif MsgContains(message, "goblins") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_7", "npc.mr_morris.say_8"}, 10)
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblinCount) >= 20 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_6")
				player:setStorageValue(14899, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisGoblin, 2)
				player:addItem(3031, 50)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_7")
			end
		end
	elseif MsgContains(message, "minotaur") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.mr_morris.say_9", "npc.mr_morris.say_10"}, 10)
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) == 1 then
			if player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinosCount) >= 20 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_8")
				player:setStorageValue(14900, 1)
				player:setStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos, 2)
				player:addItem(3031, 50)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_9")
			end
		elseif player:getStorageValue(Storage.Quest.U10_55.Dawnport.MorrisMinos) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr_morris.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_1",
})
keywordHandler:addKeyword({ "mission" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_2",
})
keywordHandler:addKeyword({ "fetch" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_3",
})
keywordHandler:addKeyword({ "kill" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_4",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_5",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_6",
})
keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_7",
})
keywordHandler:addKeyword({ "secrets of dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_8",
})
keywordHandler:addKeyword({ "archeological" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_9",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_10",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_11",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_12",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_13",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_14",
})
keywordHandler:addKeyword({ "oressa" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_15",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_16",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_17",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_18",
})
keywordHandler:addKeyword({ "ser tybald" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_19",
})
keywordHandler:addKeyword({ "wentworth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_20",
})
keywordHandler:addKeyword({ "woblin" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.mr_morris.stdmod_21",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.mr_morris.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
