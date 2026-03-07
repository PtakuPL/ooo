local internalNpcName = "Woblin"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 297,
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

	if MsgContains(message, "key") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.woblin.say_2")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "reward") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.woblin.say_3")
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 2)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "old nasty") then
		if player:getStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey) == 3 and player:getItemCount(21402) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.woblin.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.woblin.say_4")
			player:removeItem(21402, 1)
			local TheDormKey = player:addItem(21392, 1)
			TheDormKey:setActionId(103)
			player:setStorageValue(Storage.Quest.U10_55.Dawnport.TheDormKey, 4)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end
keywordHandler:addKeyword({ "goblins" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.woblin.stdmod_1",
})
keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.woblin.stdmod_2",
})
keywordHandler:addKeyword({ "precious" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.woblin.stdmod_3",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.woblin.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
