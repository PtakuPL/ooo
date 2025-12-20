local internalNpcName = "Melchior"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 0,
	lookBody = 25,
	lookLegs = 59,
	lookFeet = 115,
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
	local playerId = creature:getId()
	npcHandler:setMessage(MESSAGE_GREET, Player(creature):getSex() == PLAYERSEX_FEMALE and "Welcome, |PLAYERNAME|! The lovely sound of your voice shines like a beam of light through my solitary darkness!" or "Greetings, |PLAYERNAME|. I do not see your face, but I can read a thousand things in your voice!")
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "word of greeting") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting) ~= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melchior.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melchior.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melchior.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.melchior.multi_4")

			if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.Factions) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Factions, 1)
			end
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.Faction.Greeting, 1)
		end
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.melchior.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.melchior.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
