local internalNpcName = "Caramellia"
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
	lookHead = 96,
	lookBody = 34,
	lookLegs = 34,
	lookFeet = 34,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Can I finally have some peace...?" },
	{ text = "Please leave me alone in my mourning." },
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

keywordHandler:addKeyword({ "mourning" }, StdModule.say, { npcHandler = npcHandler, text = "All is lost. With {Winfred} dead, my love has died and I'm only an empty shell without hope or purpose." })
keywordHandler:addKeyword({ "port hope" }, StdModule.say, { npcHandler = npcHandler, text = "We put all our hope in this far away colony. Sadly, we never made it there and I will never know what our life would have been like in Port Hope." })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, text = "I guess he was the one that put my father up to the whole thing. He spied on Winfred and me and it was certainly him that suggested my {imprisonment} in this tower." })
keywordHandler:addKeyword({ "imprisonment" }, StdModule.say, { npcHandler = npcHandler, text = "This forsaken place seems as remote from the rest of the world as my heart is." })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "Please leave me alone in my mourning." })
keywordHandler:addKeyword({ "thais" }, StdModule.say, { npcHandler = npcHandler, text = "The bustling streets of Thais are all but a faint memory to me." })
keywordHandler:addKeyword({ "carlin" }, StdModule.say, { npcHandler = npcHandler, text = "Carlin is a lovely and green city as far as I remember." })
keywordHandler:addKeyword({ "venore" }, StdModule.say, { npcHandler = npcHandler, text = "My father wanted me to marry a wealthy Venorean. He understood so little about love and the ways of the heart." })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, text = "The city of the elves is an exotic wonder." })
keywordHandler:addKeyword({ "kazordoon" }, StdModule.say, { npcHandler = npcHandler, text = "The city is like the dwarfs that built it. Stony, never-changing and hard to understand for an outsider." })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "winfred") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_8")
	elseif MsgContains(message, "father") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_4")
	elseif MsgContains(message, "tower") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.caramellia.multi_2")
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello, |PLAYERNAME|. Please leave me alone in my {mourning}.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
