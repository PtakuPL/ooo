local internalNpcName = "Mr. West"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 58,
	lookBody = 25,
	lookLegs = 29,
	lookFeet = 114,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestDoor) == 1 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.mr._west.greet_msg_1",
			"npc.mr._west.greet_msg_2",
		}, 1000)
		return false
	elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestDoor) == 2 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
			"npc.mr._west.greet_msg_3",
			"npc.mr._west.greet_msg_4",
		}, 1000)
		return false
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
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 24 then
			if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestDoor) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr._west.say_1")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 25)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 3) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestStatus, 1)
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestDoor) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.mr._west.say_2")
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 25)
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission04, 4) -- StorageValue for Questlog "Mission 04: Good to be Kingpin"
				player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.MrWestStatus, 2)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
