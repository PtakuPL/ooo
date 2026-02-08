local internalNpcName = "Gnomaticus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 1,
	lookBody = 86,
	lookLegs = 1,
	lookFeet = 95,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "shooting") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.multi_2")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 13)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Shooting, 0)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.say_1")
		end
	elseif MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.say_2")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Shooting, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Shooting) + 1)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 15)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.say_3")
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) <= 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomaticus.say_4")
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomaticus.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
