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

	NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_1")
	npcHandler:setInteraction(npc, creature)

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "nokmir") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) == 4 and player:removeItem(8777, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_4")
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 5)
		end
	elseif MsgContains(message, "grombur") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_5")
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) < 1 and player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll) > 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_6")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_7")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.multi_2")
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_8")
			player:addItem(3398, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue, 8)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 or npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emperor_rehal.say_9")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addCustomGreetKeyword({ "hail emperor" }, greetCallback, { npcHandler = npcHandler })

local node1 = keywordHandler:addKeyword({ "promot" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.emperor_rehal.stdmod_1" })
node1:addChildKeyword({ "yes" }, StdModule.promotePlayer, { npcHandler = npcHandler, cost = 20000, level = 20, promotion = 1, i18nKey = "npc.emperor_rehal.promote_success" })
node1:addChildKeyword({ "no" }, StdModule.say, { npcHandler = npcHandler, onlyFocus = true, i18nKey = "npc.emperor_rehal.stdmod_2", reset = true })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
