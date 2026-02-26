local internalNpcName = "Karith"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 159,
	lookHead = 79,
	lookBody = 3,
	lookLegs = 93,
	lookFeet = 12,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.karith.voice_1" },
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) == -1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.karith.greet_msg_1")
		player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, 0)
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.karith.greet_msg_2")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "passage") or MsgContains(message, "sail") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_19")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_16")
			npcHandler:setTopic(playerId, 0)
		else
			return false
		end
	elseif MsgContains(message, "Ab'Dendriel") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.AbDendriel) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_15")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.AbDendriel) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_14")
			npcHandler:setTopic(playerId, 11)
		else
			return false
		end
	elseif MsgContains(message, "Darashia") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Darashia) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_13")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Darashia) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_12")
			npcHandler:setTopic(playerId, 12)
		else
			return false
		end
	elseif MsgContains(message, "Venore") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Venore) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_11")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Venore) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_1")
			npcHandler:setTopic(playerId, 13)
		else
			return false
		end
	elseif MsgContains(message, "Ankrahmun") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Ankrahmun) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_10")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Ankrahmun) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_9")
			npcHandler:setTopic(playerId, 14)
		else
			return false
		end
	elseif MsgContains(message, "Port Hope") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.PortHope) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_8")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.PortHope) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_7")
			npcHandler:setTopic(playerId, 15)
		else
			return false
		end
	elseif MsgContains(message, "Thais") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Thais) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_6")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Thais) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_5")
			npcHandler:setTopic(playerId, 16)
		else
			return false
		end
	elseif MsgContains(message, "Liberty Bay") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.LibertyBay) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_4")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.LibertyBay) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_3")
			npcHandler:setTopic(playerId, 17)
		else
			return false
		end
	elseif MsgContains(message, "Carlin") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Carlin) ~= 1 and player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_2")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Carlin) == 1 or player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.multi_1")
			npcHandler:setTopic(playerId, 18)
		else
			return false
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 and player:removeItem(8758, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_2")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.AbDendriel, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 and player:removeItem(8760, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_3")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Darashia, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 and player:removeItem(8759, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_4")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Venore, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 and player:removeItem(8761, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_5")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Ankrahmun, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 and player:removeItem(3044, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_6")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.PortHope, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 and player:removeItem(8762, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_7")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Thais, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 and player:removeItem(5552, 1, 13) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_8")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.LibertyBay, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 and player:removeItem(8763, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_9")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.Carlin, 1)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter, player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.SearoutesAroundYalahar.TownsCounter) + 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			if player:removeMoneyBank(160) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_10")
				doTeleportThing(creature, Position(32734, 31668, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:removeMoneyBank(210) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_12")
				doTeleportThing(creature, Position(33289, 32480, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_13")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeMoneyBank(185) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_14")
				doTeleportThing(creature, Position(32954, 32022, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 14 then
			if player:removeMoneyBank(230) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_16")
				doTeleportThing(creature, Position(33092, 32883, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_17")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 15 then
			if player:removeMoneyBank(260) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_18")
				doTeleportThing(creature, Position(32527, 32784, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_19")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 16 then
			if player:removeMoneyBank(200) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_20")
				doTeleportThing(creature, Position(32310, 32210, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_21")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 17 then
			if player:removeMoneyBank(275) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_22")
				doTeleportThing(creature, Position(32285, 32892, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_23")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 18 then
			if player:removeMoneyBank(185) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_24")
				doTeleportThing(creature, Position(32387, 31820, 6))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_25")
				npcHandler:setTopic(playerId, 0)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_26")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.karith.say_27")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

-- Kick
keywordHandler:addKeyword({ "kick" }, StdModule.kick, { npcHandler = npcHandler, destination = { Position(32811, 31267, 6), Position(32811, 31270, 6), Position(32811, 31273, 6) } })

-- Basic
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.karith.stdmod_1" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.karith.stdmod_2" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.karith.stdmod_3" })
keywordHandler:addKeyword({ "yalahar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.karith.stdmod_4" })

-- Greeting message
keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, i18nKey = "npc.karith.greet_1" })
--Farewell message
keywordHandler:addFarewellKeyword({ "asgha thrazi" }, { npcHandler = npcHandler, i18nKey = "npc.karith.farewell_1" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.karith.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.karith.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
