local internalNpcName = "Appaloosa"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 140,
	lookHead = 114,
	lookBody = 0,
	lookLegs = 114,
	lookFeet = 0,
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

	if MsgContains(message, "transport") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif table.contains({ "rent", "horses" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_2")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		local player = Player(creature)
		if npcHandler:getTopic(playerId) == 1 then
			if player:isPzLocked() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_3")
				return true
			end

			if not player:removeMoneyBank(125) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_4")
				return true
			end

			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			local destination = Position(32449, 32226, 7)
			player:teleportTo(destination)
			destination:sendMagicEffect(CONST_ME_TELEPORT)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_5")
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.Quest.U9_1.HorseStationWorldChange.Timer) >= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_6")
				return true
			end

			if not player:removeMoneyBank(500) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_7")
				return true
			end

			local mountId = { 22, 25, 26 }
			player:addMount(mountId[math.random(#mountId)])
			player:setStorageValue(Storage.Quest.U9_1.HorseStationWorldChange.Timer, os.time() + 86400)
			player:addAchievement("Natural Born Cowboy")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_8")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.appaloosa.say_9")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.appaloosa.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
