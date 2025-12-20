local internalNpcName = "Awarness Of The Emperor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 231,
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
	if Player(creature):getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) < 31 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.awarness_of_the_emperor.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.awarness_of_the_emperor.greet_msg_2")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		local player = Player(creature)
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 30 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.BossStatus) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_11")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 32 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.multi_5")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.SleepingDragon, 2)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 33)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			local player = Player(creature)
			player:teleportTo(Position(33360, 31397, 9))
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.AwarnessEmperor, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.Wote10, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.BossRoom, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 31)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission11, 1) --Questlog, Wrath of the Emperor "Mission 11: Payback Time"
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.awarness_of_the_emperor.say_1")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
