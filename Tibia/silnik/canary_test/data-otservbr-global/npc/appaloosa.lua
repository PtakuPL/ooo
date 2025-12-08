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
		npcHandler:sayLocalized("npc.appaloosa.we_can_bring_1", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif table.contains({ "rent", "horses" }, message) then
		npcHandler:sayLocalized("npc.appaloosa.do_you_want_2", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "yes") then
		local player = Player(creature)
		if npcHandler:getTopic(playerId) == 1 then
			if player:isPzLocked() then
				npcHandler:sayLocalized("npc.appaloosa.first_get_rid_3", npc, creature)
				return true
			end

			if not player:removeMoneyBank(125) then
				npcHandler:sayLocalized("npc.appaloosa.you_dont_have_4", npc, creature)
				return true
			end

			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			local destination = Position(32449, 32226, 7)
			player:teleportTo(destination)
			destination:sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:sayLocalized("npc.appaloosa.have_a_nice_5", npc, creature)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.Quest.U9_1.HorseStationWorldChange.Timer) >= os.time() then
				npcHandler:sayLocalized("npc.appaloosa.you_already_have_6", npc, creature)
				return true
			end

			if not player:removeMoneyBank(500) then
				npcHandler:sayLocalized("npc.appaloosa.you_do_not_7", npc, creature)
				return true
			end

			local mountId = { 22, 25, 26 }
			player:addMount(mountId[math.random(#mountId)])
			player:setStorageValue(Storage.Quest.U9_1.HorseStationWorldChange.Timer, os.time() + 86400)
			player:addAchievement("Natural Born Cowboy")
			npcHandler:sayLocalized("npc.appaloosa.ill_give_you_8", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 0 then
		npcHandler:say("Then not.", npc, creature)
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Salutations, |PLAYERNAME| I guess you are here for the {horses}.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
