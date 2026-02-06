local internalNpcName = "Zlak"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 339,
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

local function greetCallback(npc, creature)
	NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
		"npc.zlak.greet_msg_1",
		"npc.zlak.greet_msg_2",
	}, 1000)
	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_12")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.Zlak, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 23)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission05, 3) --Questlog, Wrath of the Emperor "Mission 05: New in Town"
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission06, 0) --Questlog, Wrath of the Emperor "Mission 06: The Office Job"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 23 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission06) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_9")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 24)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission07, 0) --Questlog, Wrath of the Emperor "Mission 07: A Noble Cause"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 24 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission07) == 6 then
			if npcHandler:getTopic(playerId) ~= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_6")
				npcHandler:setTopic(playerId, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zlak.multi_4")
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission08, 1) --Questlog, Wrath of the Emperor "Mission 08: Uninvited Guests"
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 25)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.zlak.farewell_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
