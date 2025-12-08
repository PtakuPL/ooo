local internalNpcName = "Costello"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 57,
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

	if MsgContains(message, "fugio") then
		if player:getStorageValue(Storage.Quest.U7_24.FamilyBrooch.Brooch) == 1 then
			npcHandler:say(
				"To be honest, I fear the omen in my dreams may be true. \z
					Perhaps Fugio is unable to see the danger down there. \z
					Perhaps ... you are willing to investigate this matter?",
				npc,
				creature
			)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "diary") then
		if player:getStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Diary) == 1 then
			npcHandler:sayLocalized("npc.costello.do_you_want_1", npc, creature)
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "holy water") then
		local cStorage = player:getStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline)
		if cStorage == 1 then
			npcHandler:sayLocalized("npc.costello.who_are_you_2", npc, creature)
			npcHandler:setTopic(playerId, 3)
		elseif cStorage == 2 then
			npcHandler:sayLocalized("npc.costello.i_already_filled_3", npc, creature)
		end
	elseif MsgContains(message, "amanda") and npcHandler:getTopic(playerId) == 0 then
		if player:getStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline) == 1 then
			npcHandler:sayLocalized("npc.costello.ahh_amanda_from_4", npc, creature)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.costello.thank_you_very_5", npc, creature)
			player:setStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Diary, 1)
			player:setStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Door, 1)
		elseif npcHandler:getTopic(playerId) == 2 then
			if not player:removeItem(3212, 1) then
				npcHandler:sayLocalized("npc.costello.uhm_as_you_6", npc, creature)
				return true
			end

			npcHandler:sayLocalized("npc.costello.by_the_gods_7", npc, creature)
			player:addItem(3214, 1)
			player:setStorageValue(Storage.Quest.U7_24.TheWhiteRavenMonastery.Diary, 2)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if not MsgContains(message, "amanda") then
			npcHandler:sayLocalized("npc.costello.i_never_heard_8", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end

		player:addItem(133, 1)
		player:setStorageValue(Storage.Quest.U8_1.RestInHallowedGround.Questline, 2)
		npcHandler:sayLocalized("npc.costello.ohh_why_didnt_9", npc, creature)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and table.contains({ 1, 2 }, npcHandler:getTopic(playerId)) then
		npcHandler:sayLocalized("npc.costello.uhm_as_you_10", npc, creature)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome, |PLAYERNAME|! Feel free to tell me what has brought you here.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye. Come back soon.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
