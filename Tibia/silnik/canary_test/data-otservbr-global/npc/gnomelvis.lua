local internalNpcName = "Gnomelvis"
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
	lookHead = 67,
	lookBody = 76,
	lookLegs = 105,
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

	if MsgContains(message, "looking") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) >= 19 or player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) <= 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.say_1")
		end
	elseif MsgContains(message, "musical") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.multi_5")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 21)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MelodyStatus, 1)
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MelodyTone1) < 1 then
				for i = 0, 6 do
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MelodyTone1 + i, math.random(1, 4))
				end
			end
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 21 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.say_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.say_3")
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.multi_2")
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine, 25)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLineComplete, 2)
			player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank)
			player:addAchievement("Becoming a Bigfoot")
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomelvis.say_4")
		end
	end

	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello. Is it me you're {looking} for?")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
