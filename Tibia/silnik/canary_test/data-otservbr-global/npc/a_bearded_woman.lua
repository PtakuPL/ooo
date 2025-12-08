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
	{ text = "I am a MAN! Get me out you drunken fools!" },
	{ text = "GET ME OUT OF HERE!" },
	{ text = "Get me out! It was all part of the plan, you fools!" },
	{ text = "If I ever get out of here, I'll kill you all! All of you!" },
	{ text = "I am NOT Princess Lumelia, you fools!" },
	{ text = "Get a locksmith and free me or you will regret it, you foolish pirates!" },
	{ text = "I am not a princess, I am an actor!" },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
local npcI18n = NPC_LIB and NPC_LIB.i18n

local function sayLocalizedMessage(npc, player, keys, fallback)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	if npcI18n then
		if type(keys) == "table" then
			return npcI18n.npcSayMultiple(npcHandler, npc, player, keys, 100)
		end
		return npcI18n.npcSay(npcHandler, npc, player, keys)
	end

	if type(fallback) == "table" then
		npcHandler:say(fallback, npc, player)
	else
		npcHandler:say(fallback, npc, player)
	end
	return true
end

local function addLocalizedKeyword(words, keys, fallback)
	keywordHandler:addKeyword(words, function(npc, player)
		return sayLocalizedMessage(npc, player, keys, fallback)
	end)
end

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

addLocalizedKeyword({ "job" }, "npc.a_bearded_woman.job", "I am a great and famous actor! Not a princess, at all. I was only PRETENDING to be a princess. But try explaining that to those stupid pirates.")
addLocalizedKeyword({ "actor" }, "npc.a_bearded_woman.actor", "Stage acting was a waste of my immense talent. Not only am I a born leader, my talent is more profitable when it is used for conning people.")
addLocalizedKeyword({ "stage" }, "npc.a_bearded_woman.actor", "Stage acting was a waste of my immense talent. Not only am I a born leader, my talent is more profitable when it is used for conning people.")
addLocalizedKeyword({ "kid" }, "npc.a_bearded_woman.kid", "He was always a fool with a heart too soft to become a feared pirate.")
addLocalizedKeyword({ "princess" }, "npc.a_bearded_woman.princess", "Me playing a princess was just part of a cunning plan we had.")
addLocalizedKeyword({ "cell" }, "npc.a_bearded_woman.cell", "If you find some way to release me I might even let you live as reward! So you'd better do your best or I'll kill you!")
addLocalizedKeyword({ "name" }, "npc.a_bearded_woman.name", "How dare you? I left to rot in this dirty cell and you have nothing better to do than chit chat?")
addLocalizedKeyword({ "rot" }, "npc.a_bearded_woman.rot", "YOU .. YOU .. You are as good as dead! I will get you! Do you hear me? I will have your head! On a platter!")
addLocalizedKeyword({ "pirate" }, {
	"npc.a_bearded_woman.pirate_1",
	"npc.a_bearded_woman.pirate_2",
	"npc.a_bearded_woman.pirate_3",
}, {
	"In a just world, I would be captain of a grand ship, ...",
	"Those pirates out there would now be my minions, and we would brave the seas and become the terror of the coastal towns! ...",
	"If only our plan had worked!",
})
addLocalizedKeyword({ "ship" }, {
	"npc.a_bearded_woman.ship_1",
	"npc.a_bearded_woman.ship_2",
	"npc.a_bearded_woman.ship_3",
}, {
	"Captain Kid sold his ship to buy pointless things like those insanely expensive locks for the cell doors. ...",
	"He said the canoes would do for a while. ...",
	"I got the impression he was not overly sad to part with the ship because he was known to suffer a lot from seasickness.",
})
addLocalizedKeyword({ "captain" }, {
	"npc.a_bearded_woman.captain_1",
	"npc.a_bearded_woman.captain_2",
}, {
	"I'd have been a much better captain then Kid was. I played several captains on stage and I was good! ...",
	"Where Kid longed for the appreciation of his men, I would rule by fear and with an iron fist!",
})
addLocalizedKeyword({ "plan" }, {
	"npc.a_bearded_woman.plan_1",
	"npc.a_bearded_woman.plan_2",
	"npc.a_bearded_woman.plan_3",
	"npc.a_bearded_woman.plan_4",
	"npc.a_bearded_woman.plan_5",
	"npc.a_bearded_woman.plan_6",
	"npc.a_bearded_woman.plan_7",
	"npc.a_bearded_woman.plan_8",
	"npc.a_bearded_woman.plan_9",
	"npc.a_bearded_woman.plan_10",
	"npc.a_bearded_woman.plan_11",
	"npc.a_bearded_woman.plan_12",
	"npc.a_bearded_woman.plan_13",
}, {
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
})
addLocalizedKeyword({ "kidnap" }, {
	"npc.a_bearded_woman.kidnap_1",
	"npc.a_bearded_woman.kidnap_2",
}, {
	"Ah kidnapping is so much fun. That is, if you're not on the receiving end. ...",
	"It's easy money and you have a chance to frighten and torture someone who can't fight back!",
})
addLocalizedKeyword({ "scams" }, {
	"npc.a_bearded_woman.scams_1",
	"npc.a_bearded_woman.scams_2",
	"npc.a_bearded_woman.scams_3",
}, {
	"The more stupid the people are, the easier it is to con them. ...",
	"And the poorer they are the less means they have to get revenge. Har Har! ...",
	"So I make sure I ruin those I scam. Then they have other things to worry about than getting revenge on me.",
})
addLocalizedKeyword({ "key" }, {
	"npc.a_bearded_woman.key_1",
	"npc.a_bearded_woman.key_2",
}, {
	"The key was lost in the underground river and has probably washed into the seven seas by now! ...",
	"If that stupid Kid hadn't been so obsessed with kidnapping he'd not have sold his ship to buy the most expensive and complicated locks for his cells!",
})
addLocalizedKeyword({ "plundering" }, {
	"npc.a_bearded_woman.plundering_1",
	"npc.a_bearded_woman.plundering_2",
}, {
	"As long as we stick to undefended coastal towns we can make an easy fortune. Har Har! ...",
	"As soon as I get out of here I'll finally become a pirate captain on my own. I don't need Captain Kid!",
})

local function greetCallback(npc, creature)
	local player = Player(creature)
	if not player then
		return false
	end

	if npcI18n then
		npcI18n.sayLocalized(player, "npc.a_bearded_woman.greet", nil, MESSAGE_NPC_FROM)
	else
		player:sendTextMessage(MESSAGE_NPC_FROM, "GET ME OUT OF HERE! NOW!")
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_GREET, "")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
