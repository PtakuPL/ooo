local internalNpcName = "Nilsor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 154,
	lookHead = 41,
	lookBody = 116,
	lookLegs = 95,
	lookFeet = 114,
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

	if MsgContains(message, "svargrond") or MsgContains(message, "passage") then
		npcHandler:say("Do you want to travel to Svargrond?", npc, creature)
		npcHandler:setTopic(playerId, 10)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 10 then
			player:teleportTo(Position(32312, 31074, 7))
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_10")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_7")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 29)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission07, 1) -- Questlog The Ice Islands Quest, The Secret of Helheim
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) > 20 and player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) < 28 then
			npcHandler:say("What for ingredient do you have?", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			npcHandler:say("I have now no mission for you.", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "waterskin") then
		npcHandler:say("Do you want to buy a waterskin for 25 gold?", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "cactus") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 21 then
			npcHandler:say("You will find this kind of cactus at places that are called deserts. Only an ordinary kitchen knife will be precise enough to produce the ingredient weneed. Do you have a part of that cactus with you?", npc, creature)
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "water") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_5")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "sulphur") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 23 then
			npcHandler:say("I need fine sulphur of an inactive lava hole. No other sulphur will do. Use an ordinary kitchen spoon on an inactive lava hole. Do you have fine sulphur with you?", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "herb") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 24 then
			npcHandler:say("The frostbite herb is a local plant but its quite rare. You can find it on mountain peaks. You will need to cut it with a fine kitchen knife. Do you have a frostbite herb with you?", npc, creature)
			npcHandler:setTopic(playerId, 6)
		end
	elseif MsgContains(message, "blossom") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 25 then
			npcHandler:say("The purple kiss is a plant that grows in a place called jungle. You will have to use a kitchen knife to harvest its blossom. Do you have a blossom of a purple kiss with you?", npc, creature)
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "hydra tongue") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 26 then
			npcHandler:say("The hydra tongue is a common pest plant in warmer regions. You might find one in a shop. Do you have a hydra tongue with you?", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "spores") then
		if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) == 27 then
			npcHandler:say("The giant glimmercap mushroom exists in caves and other preferably warm and humid places. Use an ordinary kitchen spoon on a mushroom to collectits spores. Do you have the glimmercap spores?", npc, creature)
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.nilsor.multi_3")
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 21)
			player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 1) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getMoney() + player:getBankBalance() >= 25 then
				player:removeMoneyBank(25)
				npcHandler:say("Here you are. A waterskin!", npc, creature)
				player:addItem(7286, 1)
			else
				npcHandler:say("You don't have enough money.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(7245, 1) then
				npcHandler:say("Thank you for this ingredient. Now bring me Geyser {Water} in a Waterskin. ", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 22)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 2) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(7246, 1) then
				npcHandler:say("Thank you for this ingredient. Now bring me Fine {Sulphur}.", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 23)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 3) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(7247, 1) then
				npcHandler:say("Thank you for this ingredient. Now bring me the Frostbite {Herb}", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 24)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 4) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(7248, 1) then
				npcHandler:say("Thank you for this ingredient Now bring me Purple Kiss {Blossom}.", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 25)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 5) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(7249, 1) then
				npcHandler:say("Thank you for this ingredient. Now bring me the {Hydra Tongue}", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 26)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 6) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient. ", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(7250, 1) then
				npcHandler:say("Thank you for this ingredient. Now bring me {Spores} of a Giant Glimmercap Mushroom.", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 27)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 7) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(7251, 1) then
				npcHandler:say("Thank you for this ingredient. Now you finish your {mission}", npc, creature)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline, 28)
				player:setStorageValue(Storage.Quest.U8_0.TheIceIslands.Mission06, 8) -- Questlog The Ice Islands Quest, Nibelor 5: Cure the Dogs
			else
				npcHandler:say("Come back when you have the ingredient.", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) >= 2 then
			npcHandler:say("Then come back when you have the ingredient.", npc, creature)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, traveller |PLAYERNAME|. Is there anything I can {do for you}?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
