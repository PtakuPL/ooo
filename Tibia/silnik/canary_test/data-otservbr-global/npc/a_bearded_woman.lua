local internalNpcName = "A Bearded Woman"
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
	lookHead = 60,
	lookBody = 22,
	lookLegs = 24,
	lookFeet = 32,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.a_bearded_woman.voice_1" },
	{ i18nKey = "npc.a_bearded_woman.voice_2" },
	{ i18nKey = "npc.a_bearded_woman.voice_3" },
	{ i18nKey = "npc.a_bearded_woman.voice_4" },
	{ i18nKey = "npc.a_bearded_woman.voice_5" },
	{ i18nKey = "npc.a_bearded_woman.voice_6" },
	{ i18nKey = "npc.a_bearded_woman.voice_7" },
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

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_1" })
keywordHandler:addKeyword({ "actor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_2" })
keywordHandler:addKeyword({ "stage" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_3" })
keywordHandler:addKeyword({ "kid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_4" })
keywordHandler:addKeyword({ "princess" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_5" })
keywordHandler:addKeyword({ "cell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_6" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_7" })
keywordHandler:addKeyword({ "rot" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_bearded_woman.stdmod_8" })
keywordHandler:addKeyword({ "pirate" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"In a just world, I would be captain of a grand ship, ...",
		"Those pirates out there would now be my minions, and we would brave the seas and become the terror of the coastal towns! ...",
		"If only our plan had worked!",
	},
})
keywordHandler:addKeyword({ "ship" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Captain Kid sold his ship to buy pointless things like those insanely expensive locks for the cell doors. ...",
		"He said the canoes would do for a while. ...",
		"I got the impression he was not overly sad to part with the ship because he was known to suffer a lot from seasickness.",
	},
})
keywordHandler:addKeyword({ "captain" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"I'd have been a much better captain then Kid was. I played several captains on stage and I was good! ...",
		"Where Kid longed for the appreciation of his men, I would rule by fear and with an iron fist!",
	},
})
keywordHandler:addKeyword({ "plan" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"It was all captain Kid's idea. You see, he hated his name and planned to become known by the name captain Kidnap. ...",
		"All he needed was someone famous to kidnap. ...",
		"Given his men's dismal lack of talent and intelligence that would have been quite a feat. ...",
		"We knew each other from a few scams we did together in the past, so he contacted me. ...",
		"I was to impersonate the famous Princess Lumelia. You know, the one everyone was looking for. ...",
		"That would show his men and the other pirates what a great kidnapper he was. ...",
		"He promised me that I would become his second in command and lead a wonderful life of plundering, robbing and pillaging. ...",
		"So I agreed to impersonate the Princess for a while and it worked fine at first. ...",
		"He returned with me dressed as the Princess from a raid on his own and was instantaneously the hero of the day for his men. ...",
		"Things went bad when they decided to have a victory party. ...",
		"As far as I could make out from the mumblings of the pirates, Kid lost the key to my cell while relieving himself in the underground river. ...",
		"The fool decided to dive after it .. never to be seen again. ...",
		"When I found out about Kid's demise I tried to convince the pirates it was a hoax, but they just won't believe me!",
	},
})
keywordHandler:addKeyword({ "kidnap" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Ah kidnapping is so much fun. That is, if you're not on the receiving end. ...",
		"It's easy money and you have a chance to frighten and torture someone who can't fight back!",
	},
})
keywordHandler:addKeyword({ "scams" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The more stupid the people are, the easier it is to con them. ...",
		"And the poorer they are the less means they have to get revenge. Har Har! ...",
		"So I make sure I ruin those I scam. Then they have other things to worry about than getting revenge on me.",
	},
})
keywordHandler:addKeyword({ "key" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The key was lost in the underground river and has probably washed into the seven seas by now! ...",
		"If that stupid Kid hadn't been so obsessed with kidnapping he'd not have sold his ship to buy the most expensive and complicated locks for his cells!",
	},
})
keywordHandler:addKeyword({ "plundering" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"As long as we stick to undefended coastal towns we can make an easy fortune. Har Har! ...",
		"As soon as I get out of here I'll finally become a pirate captain on my own. I don't need Captain Kid!",
	},
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_bearded_woman.greet_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
