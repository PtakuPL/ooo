local internalNpcName = "Wyrdin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 76,
	lookBody = 77,
	lookLegs = 79,
	lookFeet = 115,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{
		i18nKey = "npc.wyrdin.voice_1",
	},
	{
		i18nKey = "npc.wyrdin.voice_2",
	},
	{
		i18nKey = "npc.wyrdin.voice_3",
	},
	{
		i18nKey = "npc.wyrdin.voice_4",
	},
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TheWayToYalahar) < 1 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.QuestLine) >= 5 and player:getStorageValue(Storage.Quest.U7_6.ExplorerSociety.JoiningTheExplorers) >= 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_8")
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TheWayToYalahar, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "research") or MsgContains(message, "notes") then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TheWayToYalahar) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(9171, 1) then
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.TheWayToYalahar, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_2")
				player:addMoney(500)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 2 and player:removeItem(10025, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.multi_3")
				player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 1)
				npcHandler:setTopic(playerId, 2)
			end
		end
		-- The New Frontier
	elseif MsgContains(message, "farmine") then
		if player:getStorageValue(TheNewFrontier.Questline) == 14 then
			if player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_3")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_4")
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "plea") and player:getStorageValue(TheNewFrontier.Mission05.WyrdinKeyword) == 1 and player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 1 then
		if npcHandler:getTopic(playerId) == 2 then
			local chance = math.random(1, 3)
			if chance == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_5")
			elseif chance == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_6")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_7")
			end
			player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 3)
		end
	elseif MsgContains(message, "bluff") and player:getStorageValue(TheNewFrontier.Mission05.WyrdinKeyword) == 2 and player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_8")
		player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 3)
	elseif MsgContains(message, "flatter") and player:getStorageValue(TheNewFrontier.Mission05.WyrdinKeyword) == 3 and player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_9")
		player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 3)
	else
		if player:getStorageValue(TheNewFrontier.Questline) == 14 and player:getStorageValue(TheNewFrontier.Mission05.Wyrdin) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wyrdin.say_10")
			player:setStorageValue(TheNewFrontier.Mission05.Wyrdin, 2)
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.wyrdin.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.wyrdin.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
