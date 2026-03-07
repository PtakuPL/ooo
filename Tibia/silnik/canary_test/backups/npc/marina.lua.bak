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
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_2")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "honey") or MsgContains(message, "honeycomb") or MsgContains(message, "50 honeycombs") then
		if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_3")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "raymond striker") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_4")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "date") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_5")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove, 2)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.multi_5")
			player:addAchievement("Matchmaker")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ADjinnInLove, 5)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToLagunaIsland, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_6")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.multi_3")
			if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(5902, 50) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_7")
				npcHandler:setTopic(playerId, 0)
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheMermaidMarina, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_8")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(5879, 10) then
				player:addItem(5886, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_9")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.marina.say_10")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.marina.greet_msg_1")

keywordHandler:addKeyword({ "mermaid comb" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.marina.stdmod_1" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
