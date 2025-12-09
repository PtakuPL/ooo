local internalNpcName = "A Sleeping Dragon"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookTypeEx = 168,
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
	if Player(creature):getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 27 then
		npcHandler:setMessage(MESSAGE_GREET, "ZzzzZzzZz...chrrr...")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Greetings, {wayfarer}.")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 27 then
		if (message == "SOLOSARASATIQUARIUM") and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.InterdimensionalPotion) == 1 then
			npcHandler:say({
				"Dragon dreams are golden. ...",
				"A broad darkness surrounds you as if a heavy curtain is closing before your eyes. After what seems like minutes of floating through emptiness, you get the feeling as if a hole opens in the dark before you. ...",
				"The hole grows larger, you cannot close your eyes. An unimaginable black. Deeper and darker than any nothingness you could possibly imagine drags you into it. ...",
				"You feel as if you cannot breathe anymore. The very second you let loose of your consciousness, you sense all heaviness around you lifted. ...",
				"You dive into an ocean of emerald light. Feeling like born anew the colour around you is almost overwhelming. Countless objects of all shapes and sizes are dashing past you. Racing against each other, millions are clashing in the distance. ..",
				"The loudness of the gargantuan spectacle around you bursts your hearing, yet you absorb all the sounds around you. ...",
				"As several large obstacles move aside directly in front of you, an intense bright centre leaps into your view. Though you cannot perceive how fast you are, your pace seems too slow. ...",
				"Ever decelerating, you ultimately approach a middle in this chaos of tones of green. ...",
				"As you come closer to it, yellowish shades of orange embrace you, softer shapes emerge and you almost forget the mayhem before. In warm comfort you see what lies in the heart of it all. ...",
				"A majestic dragon in his sleep is surrounded by what seems the warmth and energy of a thousand suns. The tranquillity of its sight makes you smile gently. ...",
				"You feel a perfect mixture of joy, compassion and sudden peacefulness. Bright xanthous impressions of topaz, orange and white welcome you at the final halt of your journey. ...",
				"Dragon dreams are golden. ...",
				"You find yourself inside the dragon's dream. You can {look} around or {go} into a specific direction. You can also {take} or {use} an object. Enter {help} to display this information at any time.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif message:lower() == "help" and npcHandler:getTopic(playerId) > 0 and npcHandler:getTopic(playerId) < 34 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_1")
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif message:lower() == "take attachment" and npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_3")
			npcHandler:setTopic(playerId, 3)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_4")
			npcHandler:setTopic(playerId, 4)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_5")
			npcHandler:setTopic(playerId, 5)
		elseif message:lower() == "take stand" and npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_6")
			npcHandler:setTopic(playerId, 6)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_7")
			npcHandler:setTopic(playerId, 7)
		elseif message:lower() == "take model" and npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_8")
			npcHandler:setTopic(playerId, 8)
		elseif message:lower() == "take emeralds" and npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_9")
			npcHandler:setTopic(playerId, 9)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_10")
			npcHandler:setTopic(playerId, 10)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_11")
			npcHandler:setTopic(playerId, 11)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_12")
			npcHandler:setTopic(playerId, 12)
		elseif message:lower() == "take rubies" and npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_13")
			npcHandler:setTopic(playerId, 13)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_14")
			npcHandler:setTopic(playerId, 14)
		elseif message:lower() == "use attachment" and npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_15")
			npcHandler:setTopic(playerId, 15)
		elseif message:lower() == "take mirror" and npcHandler:getTopic(playerId) == 15 then
			npcHandler:say({
				"As your eyes adjust to the sudden reduction of brightness, you see the giant wings of the gate before you move to the side. You can also make out something shiny on the ground.",
				"You pick the mirror from the ground.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 16)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_16")
			npcHandler:setTopic(playerId, 17)
		elseif message:lower() == "use model" and npcHandler:getTopic(playerId) == 17 then
			npcHandler:say({
				"You lunge out and throw the model far into the water. As nothing happens, you turn your back to the ocean. ...",
				"The very moment you walk down the dune to head back south, rays of light burst over your head in a shock wave that makes you tumble down the rest of the hill. ...",
			}, npc, creature)
			npcHandler:setTopic(playerId, 18)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 18 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_17")
			npcHandler:setTopic(playerId, 19)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 19 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_18")
			npcHandler:setTopic(playerId, 20)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_19")
			npcHandler:setTopic(playerId, 21)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 21 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_20")
			npcHandler:setTopic(playerId, 22)
		elseif message:lower() == "north" and npcHandler:getTopic(playerId) == 22 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_21")
			npcHandler:setTopic(playerId, 23)
		elseif message:lower() == "west" and npcHandler:getTopic(playerId) == 23 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_22")
			npcHandler:setTopic(playerId, 24)
		elseif message:lower() == "take sapphire" and npcHandler:getTopic(playerId) == 24 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_23")
			npcHandler:setTopic(playerId, 25)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_24")
			npcHandler:setTopic(playerId, 26)
		elseif message:lower() == "south" and npcHandler:getTopic(playerId) == 26 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_25")
			npcHandler:setTopic(playerId, 27)
		elseif message:lower() == "east" and npcHandler:getTopic(playerId) == 27 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_26")
			npcHandler:setTopic(playerId, 28)
		elseif message:lower() == "use stand" and npcHandler:getTopic(playerId) == 28 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_27")
			npcHandler:setTopic(playerId, 29)
		elseif message:lower() == "use ruby" and npcHandler:getTopic(playerId) == 29 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_28")
			npcHandler:setTopic(playerId, 30)
		elseif message:lower() == "use sapphire" and npcHandler:getTopic(playerId) == 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_29")
			npcHandler:setTopic(playerId, 31)
		elseif message:lower() == "use emerald" and npcHandler:getTopic(playerId) == 31 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_30")
			npcHandler:setTopic(playerId, 32)
		elseif message:lower() == "use mirror" and npcHandler:getTopic(playerId) == 32 then
			npcHandler:say({
				"With your eyes covered and avoiding direct sight of the rays, you put the mirror into the stand. ...",
				"Instinctively you run to a larger emerald bluff near the raise to find cover. Mere seconds after you claimed the sturdy shelter, a deep dark humming starts to swirl through the air. ...",
				"Seconds pass as the hum gets louder. The noise is maddening, drowning all other sounds around you. As you cover your ears in pain, the humming explodes into a deafening growl. ...",
				"You raise your head above the edge of the emerald to catch a glimpse of what's happening. ...",
				"The hand seems to have grown into a fist. In the distance you can now see a blurry scheme of a creature too large for your eyes to get a sharper view of its head. ...",
				"Blending the rays, the mirror directs pure white light directly towards the part where you assume the face of the creature. ...",
				"The growl transforms into a scream, everything around you seems to compress. As you press yourself tightly against the bluff, everything falls silent and in a split second, the dark being dissolves into bursts of blackness. You wake.",
			}, npc, creature)
			player:addAchievement("Wayfarer")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 28)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission09, 2) --Questlog, Wrath of the Emperor "Mission 09: The Sleeping Dragon"
			npcHandler:setTopic(playerId, 0)
		end
	elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 28 then
		if MsgContains(message, "wayfarer") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sleeping_dragon.say_31")
		elseif MsgContains(message, "mission") then
			npcHandler:say({
				"Aaaah... free at last. Hmmm. ...",
				"I assume you need to get through the gate to reach the evildoer. I can help you if you trust me, wayfarer. I will share a part of my mind with you which should enable you to step through the gate. ...",
				"This procedure may be exhausting. Are you prepared to receive my key?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 41)
		elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 41 then
			npcHandler:say({
				"SAETHELON TORILUN GARNUM. ...",
				"SLEEP. ...",
				"GAIN. ...",
				"RISE. ...",
				"The transfer was successful. ...",
				"You are now prepared to enter the realm of the evildoer. I am grateful for your help, wayfarer. Should you seek my council, use this charm I cede to you. For my spirit will guide you wherever you are. May you enjoy a sheltered future, you shall prevail.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 29)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission10, 1) --Questlog, Wrath of the Emperor "Mission 10: A Message of Freedom"
			player:addItem(10343, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
