local internalNpcName = "Barnabas Dee"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 432,
	lookHead = 0,
	lookBody = 95,
	lookLegs = 117,
	lookFeet = 98,
	lookAddons = 1,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_8")
			player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission, 1)
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine) < 1 then
				player:setStorageValue(Storage.Quest.U10_50.OramondQuest.QuestLine, 1)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "seance") and player:getStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission16) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getItemCount(21089) >= 15 then
				if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission15) == 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_3")
					player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission, -1)
					player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission15, 2)
					player:removeItem(21089, 15)
					npcHandler:setTopic(playerId, 2)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_4")
					player:setStorageValue(Storage.Quest.U10_50.OramondQuest.ThePowderOfTheStars.Mission, -1)
					player:removeItem(21089, 15)
					local currentVotingPoints = player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints)
					if currentVotingPoints == -1 then
						player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, 1)
					else
						player:setStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints, currentVotingPoints + 1)
					end
					npcHandler:setTopic(playerId, 0)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_5")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_6")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.multi_6")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_7")
			npcHandler:setTopic(playerId, 5)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.barnabas_dee.say_8")
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission15, 3)
			player:teleportTo(Position(33467, 32048, 8))
			player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.barnabas_dee.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.barnabas_dee.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.barnabas_dee.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
