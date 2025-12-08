local internalNpcName = "Captain Waverider"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 96,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

	if MsgContains(message, "peg leg") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToMeriana) == 1 then
			npcHandler:sayLocalized("npc.captain_waverider.ohhhh_so_lowers_1", npc, creature)
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:sayLocalized("npc.captain_waverider.sorry_my_old_2", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "passage") then
		npcHandler:sayLocalized("npc.captain_waverider.sigh_i_knew_3", npc, creature)
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "no") then
		npcHandler:sayLocalized("npc.captain_waverider.i_have_to_4", npc, creature)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeMoneyBank(50) then
				npcHandler:sayLocalized("npc.captain_waverider.and_there_we_5", npc, creature)
				player:teleportTo(Position(32346, 32625, 7))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.captain_waverider.you_dont_have_6", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:removeMoneyBank(200) then
				npcHandler:sayLocalized("npc.captain_waverider.and_there_we_7", npc, creature)
				player:teleportTo(Position(32131, 32913, 7))
				player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.captain_waverider.you_dont_have_8", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, daring adventurer. If you need a {passage}, let me know.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Oh well.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
