local internalNpcName = "Sane Mage"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 394,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Hm? What is the meaning of all this?" },
	{ text = "What have I become? What is slime if it's not for everyone?" },
	{ text = "Slime! Everywhere! SLIME TIME! Or... not?" },
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

keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I AM THE... I mean... I am - what is a mage, if he is not {mad}? If he isn't... raging? I am... I am just sane. A sane mage." })
keywordHandler:addKeyword({ "mad" }, StdModule.say, { npcHandler = npcHandler, text = "I am not mad... I- YES, that's the whole problem, isn't it? What's going on, what's happening to me? I don't even know anymore." })
keywordHandler:addKeyword({ "vacation" }, StdModule.say, { npcHandler = npcHandler, text = "Yes, well... I'm taking a break. It will take some time. I don't know how long I just... I want to get away from all this for some time, that's it." })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, text = "Slime is my mission. Is there anything more important? There isn't. To me. Right now at least." })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, text = "Slime is my mission. Is there anything more important? There isn't. To me. Right now at least." })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, text = "You want to help me? HELP me? You? Who... who are you anyway? Ah nevermind." })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "job") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_8")
	elseif table.contains({ "slime", "fungus" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sane_mage.multi_2")
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "...er... hello? Yes...? Well, if... if you have any questions - I am not even here.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Yes... then, goodbye.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Yes... then, goodbye.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
