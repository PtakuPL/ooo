local internalNpcName = "Falonzo"
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
	lookHead = 39,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 3,
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

keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_1",
})

keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_2",
})

keywordHandler:addKeyword({ "place" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"This {plane} is now inhabited by {intruders} and creatures that accidentally became {dragged} in. ...",
		"It is neither completely of our world nor is it still that disconnected and unreachable as it used to be. I fear it's only a harbinger of something more dangerous and more {sinister}.",
	},
})

keywordHandler:addKeyword({ "anomaly" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Well, the whole place here is an anomaly so to say. You can hardly have missed the fact that you arrived here through a mystical gate. ...",
		"Well actually it's no gate at all but a rift in the fabric of nature. It is this minor {plane} trying to reconnect to our world.",
	},
})

keywordHandler:addKeyword({ "plane" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_3",
})

keywordHandler:addKeyword({ "intruders" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_4",
})

keywordHandler:addKeyword({ "dragged" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"This place became a fiery trap to certain beings with an affinity to fire. Somehow it reconnects randomly with the known world, to which it once belonged ...",
		"but also to other places that it shares some affinity with like hellish places of unspeakable evil that spawn infernal creatures.",
	},
})

keywordHandler:addKeyword({ "sinister" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Something is tearing at the fabric of reality. I can't tell what is it but the {boundaries} between worlds are fading. ...",
		"A process that what watched for over a century but which has extremely grown in momentum over the last few years. Something is happening and it's for sure nothing good. ...",
		"Be it as it may, the plane trying to reconnect was only a side effect. It still might teach us about what is happening and it has for sure attracted some {attention} already.",
	},
})
keywordHandler:addAliasKeyword({ "changed" })

keywordHandler:addKeyword({ "lost" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_5",
})

keywordHandler:addKeyword({ "boundaries" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"We know about other planes of existence but in all history it has never been as easy to reach them as it is now. ...",
		"Sometimes world seem to overlap and we can identify more and more such planes and worlds. More then we ever had imagined. All we can tell is, that something is changing. And not for the good.",
	},
})

keywordHandler:addKeyword({ "attention" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.falonzo.stdmod_6",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.falonzo.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.falonzo.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.falonzo.walkaway_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
