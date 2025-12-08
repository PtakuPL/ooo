local internalNpcName = "Ezebeth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 96,
	lookBody = 31,
	lookLegs = 34,
	lookFeet = 94,
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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01) == -1 then
			npcHandler:sayLocalized("npc.ezebeth.well_there_is_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:sayLocalized("npc.ezebeth.you_already_asked_2", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "assistance") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.ezebeth.its_nothing_really_3", npc, creature)
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "strange") then
		if npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.ezebeth.they_usually_know_4", npc, creature)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission01, 1) -- Mission 1 start
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "outfit") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission18) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Outfit) < 1 then
			npcHandler:sayLocalized("npc.ezebeth.nice_work_take_5", npc, creature)
			player:addOutfit(610, 0)
			player:addOutfit(618, 0)
			player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Outfit, 1)
			npcHandler:setTopic(playerId, 0)
		else
			npcHandler:sayLocalized("npc.ezebeth.you_already_have_6", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "addon") then
		if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Outfit) == 1 then
			if player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints) >= 6 and player:getStorageValue(Storage.Quest.U10_50.GloothEngineerOutfits.Addon2) < 1 then
				npcHandler:sayLocalized("npc.ezebeth.receive_the_second_7", npc, creature)
				player:addOutfit(610, 2)
				player:addOutfit(618, 2)
				player:setStorageValue(Storage.Quest.U10_50.GloothEngineerOutfits.Addon2, 1)
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(Storage.Quest.U10_50.OramondQuest.VotingPoints) >= 3 and player:getStorageValue(Storage.Quest.U10_50.GloothEngineerOutfits.Addon1) < 1 then
				npcHandler:sayLocalized("npc.ezebeth.receive_the_first_8", npc, creature)
				player:addOutfit(610, 1)
				player:addOutfit(618, 1)
				player:setStorageValue(Storage.Quest.U10_50.GloothEngineerOutfits.Addon1, 1)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:say({
					"We provide addons to people dedicated to our city. So the first addon is granted to someone who has voted for each of the available shortcuts and each dungeon at least once. ...",
					"The second addon is granted to someone who has voted for each bossfight at least once.",
				}, npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello! I guess you are here for a {mission}.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
