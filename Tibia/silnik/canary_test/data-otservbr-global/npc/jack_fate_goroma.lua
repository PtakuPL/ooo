local internalNpcName = "Jack Fate"
local npcType = Game.createNpcType("Jack Fate (Goroma)")
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 19,
	lookBody = 69,
	lookLegs = 88,
	lookFeet = 69,
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

	if message then
		message = message:lower()
	end

	if table.contains({ "sail", "passage", "wreck", "liberty bay", "ship" }, message) then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToGoroma) ~= 1 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_1")
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_2")
				npcHandler:setTopic(playerId, 3)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_3")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.multi_3")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_4")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(5901, 30) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_5")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked, 2)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToGoroma, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_6")
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			player:teleportTo(Position(32285, 32892, 6), false)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.jack_fate_goroma.say_7")
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate_goroma.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate_goroma.stdmod_2" })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate_goroma.stdmod_3" })
keywordHandler:addKeyword({ "goroma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.jack_fate_goroma.stdmod_4" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.jack_fate_goroma.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.jack_fate_goroma.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.jack_fate_goroma.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
