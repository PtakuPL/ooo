local internalNpcName = "Gareth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 132,
	lookHead = 41,
	lookBody = 0,
	lookLegs = 39,
	lookFeet = 20,
	lookAddons = 2,
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

local function greetCallback(npc, creature)
	local playerId = creature:getId()

	local player = Player(creature)

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) < 1 or player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) > 14 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome to the wonderful and only recently opened Museum of Tibian Arts! Free entrance for everybody, but patrons of the arts are wanted and favoured.")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "The Druid of Crunor has sent you? He seems to know that this new museum shines like a diamond. Enjoy your stay! If you like to {support} this place, talk to me.")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) > 1 and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) < 14 then
		npcHandler:setMessage(MESSAGE_GREET, "How is your {mission} going?")
	elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 14 then
		npcHandler:setMessage(MESSAGE_GREET, "You again? How could you flee from the last floor. The cultists should have 'dealt' with you! That beats me. You have to leave this place right now. There's nothing more to say.")
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local value = 10000

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) < 2 then
		if MsgContains(message, "patrons") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_1")
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "pay") and npcHandler:getTopic(playerId) == 2 then
			if (player:getMoney() + player:getBankBalance()) >= value then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_13")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_14")
				player:removeMoneyBank(value)
				player:addItem(25689, 1)
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 2)
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.AccessDoorInvestigation, 1)
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_2")
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_3")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 4)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_12")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 6)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_4")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 10)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 11 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_9")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 12)
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.AccessDoorGareth, 1)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 8 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_5")
		npcHandler:setTopic(playerId, 0)
	end

	if MsgContains(message, "extension") then
		if player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_7")
			player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, 7)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_6")
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "problem") and npcHandler:getTopic(playerId) == 11 then
		if npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_4")
			npcHandler:setTopic(playerId, 12)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 12 then
		if npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.say_7")
			player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, 2)
			npcHandler:setTopic(playerId, 0)
		end
	end

	if MsgContains(message, "bone") and player:getStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gareth.multi_2")
		player:setStorageValue(Storage.Quest.U11_80.TheSecretLibrary.MoTA.Questline, 5)
		npcHandler:setTopic(playerId, 0)
	end

	return true
end
npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
