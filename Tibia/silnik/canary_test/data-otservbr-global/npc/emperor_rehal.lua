local internalNpcName = "Emperor Rehal"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 66,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function greetCallback(npc, creature, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not MsgContains(message, "hail emperor") then
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	npcHandler:sayLocalized("npc.emperor_rehal.may_fire_and_1", npc, creature)
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "nokmir") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 1 then
			npcHandler:sayLocalized("npc.emperor_rehal.i_always_liked_2", npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 4 and player:removeItem(8777, 1) then
			npcHandler:sayLocalized("npc.emperor_rehal.interesting_the_fact_3", npc, creature)
			npcHandler:sayLocalized("npc.emperor_rehal.let_there_be_4", npc, creature)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 5)
		end
	elseif MsgContains(message, "grombur") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.emperor_rehal.hes_very_ambitious_5", npc, creature)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) < 1 and player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) > 4 then
			npcHandler:sayLocalized("npc.emperor_rehal.as_you_have_6", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) == 7 then
			npcHandler:sayLocalized("npc.emperor_rehal.my_son_was_7", npc, creature)
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			npcHandler:say({
				"Splendid! My son Rehon set off on an expedition to the deeper mines. He and a group of dwarfs were to search for new veins of crystal. Unfortunately they have been missing for 2 weeks now. ...",
				"Find my son and if he's alive bring him back. You will find a reactivated ore wagon tunnel at the entrance of the great citadel which leades to the deeper mines. If you encounter problems within the tunnel go ask Xorlosh, he can help you.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			npcHandler:sayLocalized("npc.emperor_rehal.look_at_these_8", npc, creature)
			player:addItem(3398, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue, 8)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 or npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.emperor_rehal.alright_then_come_9", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addCustomGreetKeyword({ "hail emperor" }, greetCallback, { npcHandler = npcHandler })

local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, text = "I can promote you for 20000 gold coins. Do you want me to promote you?" })
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, { npcHandler = npcHandler, cost = 20000, level = 20, promotion = 1, text = "Congratulations! You are now promoted." })
node1:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, text = "Alright then, come back when you are ready.", reset = true })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
