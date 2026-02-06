local internalNpcName = "Riddler"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 48,
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

	local storage = Storage.Quest.U7_24.TheParadoxTower
	if MsgContains(message, "test") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_9")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "goshnar") and npcHandler:getTopic(playerId) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_10")
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "demonbunny") and npcHandler:getTopic(playerId) == 3 then
		if player:getStorageValue(storage.TheFearedHugo) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_2")
			npcHandler:setTopic(playerId, 4)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_3")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "tha'kull") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_4")
		npcHandler:setTopic(playerId, 6)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_5")
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "breath") and npcHandler:getTopic(playerId) == 7 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_6")
		npcHandler:setTopic(playerId, 8)
	elseif MsgContains(message, "silence") and npcHandler:getTopic(playerId) == 8 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_11")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "old") and npcHandler:getTopic(playerId) == 9 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_7")
		npcHandler:setTopic(playerId, 10)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 10 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_8")
		npcHandler:setTopic(playerId, 11)
	elseif MsgContains(message, "green") and npcHandler:getTopic(playerId) == 11 then
		if player:getStorageValue(storage.FavoriteColour) < 1 then
			player:setStorageValue(storage.FavoriteColour, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_12")
		npcHandler:setTopic(playerId, 12)
	elseif MsgContains(message, "none") and npcHandler:getTopic(playerId) == 12 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_13")
		npcHandler:setTopic(playerId, 13)
	elseif MsgContains(message, "1") then
		if npcHandler:getTopic(playerId) == 13 then
			if player:getStorageValue(storage.Mathemagics) >= 1 then
				-- Complete mission mathemagics
				if player:getStorageValue(storage.Mathemagics) == 1 then
					player:setStorageValue(storage.Mathemagics, 2)
				end
				-- Complete mission favorite colour
				if player:getStorageValue(storage.FavoriteColour) == 1 then
					player:setStorageValue(storage.FavoriteColour, 2)
				end

				player:teleportTo({ x = 32478, y = 31905, z = 1 })
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_10")
				player:teleportTo({ x = 32725, y = 31589, z = 12 })
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			end
		end
	elseif npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_11")
		player:teleportTo({ x = 32725, y = 31589, z = 12 })
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.riddler.say_12")
		player:teleportTo({ x = 32725, y = 31589, z = 12 })
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

keywordHandler:addKeyword({ "paradox" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_1" })
keywordHandler:addAliasKeyword({ "tower" })

keywordHandler:addKeyword({ "master" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_2" })
keywordHandler:addKeyword({ "treasure" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_3" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_4" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_5" })
keywordHandler:addKeyword({ "key" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.riddler.stdmod_6" })
keywordHandler:addAliasKeyword({ "door" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.riddler.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.riddler.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.riddler.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
