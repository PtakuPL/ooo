local internalNpcName = "Curos"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 29,
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

local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier
local AnUneasyAlliance = Storage.Quest.U8_54.AnUneasyAlliance
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(TheNewFrontier.Questline) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(TheNewFrontier.Questline) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_20")
			player:setStorageValue(TheNewFrontier.Questline, 19)
			player:setStorageValue(TheNewFrontier.Mission06, 4) --Questlog, The New Frontier Quest "Mission 06: Days Of Doom"
		elseif player:getStorageValue(TheNewFrontier.Mission06) >= 5 and player:getStorageValue(AnUneasyAlliance.Questline) < 1 then --An Uneasy Alliance Quest
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_17")
			player:setStorageValue(AnUneasyAlliance.Questline, 1)
			player:setStorageValue(AnUneasyAlliance.QuestDoor, 0)
		elseif player:getStorageValue(AnUneasyAlliance.Questline) == 1 and player:getStorageValue(AnUneasyAlliance.QuestDoor) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.say_2")
			player:setStorageValue(AnUneasyAlliance.Questline, 2)
		elseif player:getStorageValue(AnUneasyAlliance.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_9")
			player:setStorageValue(AnUneasyAlliance.Questline, 3)
		elseif player:getStorageValue(AnUneasyAlliance.Questline) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_4")
			player:setStorageValue(AnUneasyAlliance.Questline, 5)
			player:addItem(10217)
		end
	elseif MsgContains(message, "test") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.curos.multi_2")
			npcHandler:setTopic(playerId, 0)
			player:setStorageValue(TheNewFrontier.Questline, 17)
			player:setStorageValue(TheNewFrontier.Mission06, 2) --Questlog, The New Frontier Quest "Mission 06: Days Of Doom"
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.curos.greet_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
