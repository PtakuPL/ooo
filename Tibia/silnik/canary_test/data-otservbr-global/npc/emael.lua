local internalNpcName = "Emael"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 114,
	lookBody = 114,
	lookLegs = 75,
	lookFeet = 113,
	lookAddons = 1,
	lookMount = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.emael.voice_1" },
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
	NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
		"npc.emael.greet_msg_1",
		"npc.emael.greet_msg_2",
	}, 1000)
	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()
	if message == "podium" then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif message == "yes" and npcHandler:getTopic(playerId) == 1 then
		if player:getStorageValue(30020) == 1 then
			if player:removeMoney(1000000) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_2")
				local inbox = player:getStoreInbox()
				local inboxItems = inbox:getItems()
				if inbox and #inboxItems < inbox:getMaxCapacity() then
					local decoKit = inbox:addItem(ITEM_DECORATION_KIT, 1)
					if decoKit then
						decoKit:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, "Unwrap it in your own house to create a <" .. ItemType(38707):getName() .. ">.")
						decoKit:setCustomAttribute("unWrapId", 38707)
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_3")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_4")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_5")
		end
		npcHandler:setTopic(playerId, 0)
	elseif message == "no" and npcHandler:getTopic(playerId == 1) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.emael.say_6")
		npcHandler:setTopic(playerId, 0)
	end
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.emael.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.emael.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)
