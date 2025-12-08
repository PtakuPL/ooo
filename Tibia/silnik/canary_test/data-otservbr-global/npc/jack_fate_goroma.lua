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
				npcHandler:sayLocalized("npc.jack_fate_goroma.id_love_to_1", npc, creature)
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked) == 1 then
				npcHandler:sayLocalized("npc.jack_fate_goroma.have_you_brought_2", npc, creature)
				npcHandler:setTopic(playerId, 3)
			end
		else
			npcHandler:sayLocalized("npc.jack_fate_goroma.do_you_want_3", npc, creature)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say({
				"Thank you. Luckily the damage my ship has taken looks more severe than it is, so I will only need a few wooden boards. ...",
				"I saw some lousy trolls running away with some parts of the ship. It might be a good idea to follow them and check if they have some more wood. ...",
				"We will need 30 pieces of wood, no more, no less. Did you understand everything?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.jack_fate_goroma.good_please_return_4", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(5901, 30) then
				npcHandler:sayLocalized("npc.jack_fate_goroma.excellent_now_we_5", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked, 2)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToGoroma, 1)
				npcHandler:setTopic(playerId, 0)
			else
				npcHandler:sayLocalized("npc.jack_fate_goroma.you_dont_have_6", npc, creature)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			player:teleportTo(Position(32285, 32892, 6), false)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:sayLocalized("npc.jack_fate_goroma.set_the_sails_7", npc, creature)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "My name is Jack Fate from the Royal Tibia Line." })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "I'm the captain of this - well, wreck. Argh." })
keywordHandler:addKeyword({ "captain" }, StdModule.say, { npcHandler = npcHandler, text = "I'm the captain of this - well, wreck. Argh" })
keywordHandler:addKeyword({ "goroma" }, StdModule.say, { npcHandler = npcHandler, text = "This is where we are... the volcano island Goroma. There are many rumours about this place." })

npcHandler:setMessage(MESSAGE_GREET, "Hello, Sir |PLAYERNAME|. Where can I {sail} you today?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye then.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
