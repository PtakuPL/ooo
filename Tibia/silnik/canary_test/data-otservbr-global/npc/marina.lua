local internalNpcName = "Marina"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 5811,
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

	if MsgContains(message, "silk") or MsgContains(message, "yarn") or MsgContains(message, "silk yarn") or MsgContains(message, "spool of yarn") then
		if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina) < 1 then
			npcHandler:sayLocalized("npc.marina.um_you_mean_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina) == 2 then
			npcHandler:sayLocalized("npc.marina.okay_a_deal_2", npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "honey") or MsgContains(message, "honeycomb") or MsgContains(message, "50 honeycombs") then
		if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina) == 1 then
			npcHandler:sayLocalized("npc.marina.did_you_bring_3", npc, creature)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "raymond striker") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) == 1 then
			npcHandler:sayLocalized("npc.marina.giggles_i_think_4", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "date") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove) == 1 then
			npcHandler:sayLocalized("npc.marina.is_that_the_5", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove, 2)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove) == 4 then
			npcHandler:say({
				"This lovely, exotic Djinn is a true poet. And he is asking me for a date? Excellent. Now I can finaly dump this human pirate. He was growing to be boring more and more with each day ...",
				"As a little reward for your efforts I allow you to ride my sea turtles. Just look around at the shores and you will find them.",
			}, npc, creature)
			player:addAchievement("Matchmaker")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove, 5)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToLagunaIsland, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:sayLocalized("npc.marina.well_everyone_would_6", npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:say({
				"<giggles> It's funny how easy it is to get humans to say what you want. Now, proving it will be even more fun! ...",
				"You want me to touch something gooey, so you have to touch something gooey for me too. <giggles> ...",
				"I love honey and I haven't eaten it in a while, so bring me 50 honeycombs and worship my beauty a little more, then we will see.",
			}, npc, creature)
			if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(5902, 50) then
				npcHandler:sayLocalized("npc.marina.oh_goodie_thank_7", npc, creature)
				npcHandler:setTopic(playerId, 0)
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina, 2)
			else
				npcHandler:sayLocalized("npc.marina.you_dont_have_8", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(5879, 10) then
				player:addItem(5886, 1)
				npcHandler:sayLocalized("npc.marina.ew_gooey_there_9", npc, creature)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.marina.you_dont_have_10", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Oh, hello |PLAYERNAME|. A visitor, how nice!")

keywordHandler:addKeyword({ "mermaid comb" }, StdModule.say, { npcHandler = npcHandler, text = "Sorry, I don't have a spare comb. I lost my favourite one when diving around in Calassa." })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
