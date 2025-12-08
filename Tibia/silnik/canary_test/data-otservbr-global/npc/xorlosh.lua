local internalNpcName = "Xorlosh"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 41,
	lookBody = 95,
	lookLegs = 75,
	lookFeet = 95,
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
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.GoingDown) < 1 then
			npcHandler:sayLocalized("npc.xorlosh.hmmmm_you_could_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.GoingDown) == 1 and player:removeItem(8775, 3) then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.GoingDown, 2)
			npcHandler:sayLocalized("npc.xorlosh.holy_mother_of_2", npc, creature)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.GoingDown, 1)
			player:setStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.DefaultStart, 1)
			npcHandler:sayLocalized("npc.xorlosh.that_would_be_3", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "tunnel") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) == 1 then
			npcHandler:say({
				"There should be a book in our library about tunnelling. I don't have that much time to talk to you about that. ...",
				"If you want to have some information, you'll just have to find that book. If you need some equipment, go ask Harog. You'll find the library in the north eastern wing of Beregar city.",
			}, npc, creature)
		end
	elseif MsgContains(message, "book") then
		if player:getStorageValue(Storage.Quest.U8_4.TheHiddenCityOfBeregar.RoyalRescue) == 1 then
			npcHandler:sayLocalized("npc.xorlosh.the_book_about_4", npc, creature)
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "See you my friend.")
npcHandler:setMessage(MESSAGE_FAREWELL, "See you my friend.")
npcHandler:setMessage(MESSAGE_GREET, "Who are you? Are you a genius in mechanics? You don't look like one.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
