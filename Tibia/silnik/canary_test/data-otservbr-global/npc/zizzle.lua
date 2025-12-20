local internalNpcName = "Zizzle"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 114,
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
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.say_1")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission08, 2) --Questlog, Wrath of the Emperor "Mission 08: Uninvited Guests"
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission09, 0) --door access
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.Zizzle, 3) --teleport access
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 26)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_18")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 29 then
			if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) < 30 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_7")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_9")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_11")
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.InnerSanctum, 1)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 30)
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission10, 2) --Questlog, Wrath of the Emperor "Mission 10: A Message of Freedom"
				player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.BossStatus, 1)
				player:addItem(11362, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.say_2")
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.zizzle.multi_3")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.SleepingDragon, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission09, 1) --Questlog, Wrath of the Emperor "Mission 08: Uninvited Guests"
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 27)
			player:addItem(11372, 1)
			player:addItem(11426, 1)
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.zizzle.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
