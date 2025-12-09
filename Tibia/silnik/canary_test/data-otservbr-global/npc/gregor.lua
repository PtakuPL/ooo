local internalNpcName = "Gregor"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 38,
	lookBody = 38,
	lookLegs = 38,
	lookFeet = 38,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Gather around me, young knights! I'm going to teach you some spells!" },
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

	if player:getStorageValue(Storage.Quest.U7_6.TheApeCity.Questline) <= 15 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_1")
		return true
	end

	local addonProgress = player:getStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet)
	if MsgContains(message, "task") then
		if not player:isPremium() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_2")
			return true
		end

		if addonProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_3")
			npcHandler:setTopic(playerId, 1)
		elseif addonProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_4")
		elseif addonProgress == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_5")
		elseif addonProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_6")
		elseif addonProgress == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_7")
		elseif addonProgress == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_8")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_9")
		end
	elseif MsgContains(message, "behemoth fang") then
		if addonProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_10")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_11")
		end
	elseif MsgContains(message, "ramsay the reckless helmet") then
		if addonProgress == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_12")
			npcHandler:setTopic(playerId, 4)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_13")
		end
	elseif MsgContains(message, "sweat") then
		if addonProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_14")
			npcHandler:setTopic(playerId, 5)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_15")
		end
	elseif MsgContains(message, "royal steel") then
		if addonProgress == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_16")
			npcHandler:setTopic(playerId, 6)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_17")
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			npcHandler:say({
				"Well then, listen closely. First, you will have to prove that you are a fierce and restless warrior by bringing me 100 perfect behemoth fangs. ...",
				"Secondly, please retrieve a helmet for us which has been lost a long time ago. The famous Ramsay the Reckless wore it when exploring an ape settlement. ...",
				"Third, we need a new flask of warrior's sweat. We've run out of it recently, but we need a small amount for the show battles in our arena. ...",
				"Lastly, I will have our smith refine your helmet if you bring me royal steel, an especially noble metal. ...",
				"Did you understand everything I told you and are willing to handle this task?",
			}, npc, creature, 100)
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_18")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.OutfitQuest.Ref, math.max(0, player:getStorageValue(Storage.OutfitQuest.Ref)) + 1)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet, 1)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.MissionHelmet, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_19")
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_20")
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if not player:removeItem(5893, 100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_21")
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet, 2)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.MissionHelmet, 2)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.RamsaysHelmetDoor, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_22")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_23")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 4 then
		if MsgContains(message, "yes") then
			if not player:removeItem(5924, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_24")
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet, 3)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.MissionHelmet, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_25")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_26")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			if not player:removeItem(5885, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_27")
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet, 4)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.MissionHelmet, 4)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_28")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_29")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 6 then
		if MsgContains(message, "yes") then
			if not player:removeItem(5887, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_30")
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.AddonHelmet, 5)
			player:setStorageValue(Storage.Quest.U7_8.KnightOutfits.MissionHelmet, 5)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_31")
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gregor.say_32")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addSpellKeyword({ "find", "person" }, {
	npcHandler = npcHandler,
	spellName = "Find Person",
	price = 80,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "light" }, {
	npcHandler = npcHandler,
	spellName = "Light",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "cure", "poison" }, {
	npcHandler = npcHandler,
	spellName = "Cure Poison",
	price = 150,
	level = 10,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "wound", "cleansing" }, {
	npcHandler = npcHandler,
	spellName = "Wound Cleansing",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "great", "light" }, {
	npcHandler = npcHandler,
	spellName = "Great Light",
	price = 500,
	level = 13,
	vocation = VOCATION.BASE_ID.KNIGHT,
})

keywordHandler:addKeyword({ "healing", "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "In this category I have '{Wound Cleansing}' and '{Cure Poison}'.",
})
keywordHandler:addKeyword({ "support", "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "In this category I have '{Light}', '{Find Person}' and '{Great Light}'.",
})
keywordHandler:addKeyword({ "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "I can teach you {healing spells} and {support spells}. What kind of spell do you wish to learn? You can also tell me for which level you would like to learn a spell, if you prefer that.",
})

keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "I am the first knight. I trained some of the greatest heroes of Tibia.",
})
keywordHandler:addKeyword({ "heroes" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Of course, you heard of them. Knights are the best fighters in Tibia.",
})
keywordHandler:addKeyword({ "king" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Hail to our King!",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "You are joking, eh? Of course, you know me. I am Gregor, the first knight.",
})
keywordHandler:addKeyword({ "gregor" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "A great name, isn't it?",
})
keywordHandler:addKeyword({ "tibia" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Beautiful Tibia. And with our help everyone is save.",
})
keywordHandler:addKeyword({ "time" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "It is time to join the Knights!",
})
keywordHandler:addKeyword({ "knights" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Knights are the warriors of Tibia. Without us, no one would be safe. Every brave and strong man or woman can join us.",
})
keywordHandler:addKeyword({ "bozo" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Some day someone will make something happen to him...",
})
keywordHandler:addKeyword({ "elane" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "A bow might be a fine weapon for someone not strong enough to wield a REAL weapon.",
})
keywordHandler:addKeyword({ "frodo" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "I and my students often share a cask of beer or wine at Frodo's hut.",
})
keywordHandler:addKeyword({ "gorn" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Always concerned with his profit. What a loss! He was adventuring with baxter in the old days.",
})
keywordHandler:addKeyword({ "baxter" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "He was an adventurer once.",
})
keywordHandler:addKeyword({ "lynda" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Before she became a priest she won the Miss Tibia contest three times in a row.",
})
keywordHandler:addKeyword({ "mcronald" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Peaceful farmers.",
})
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "A fine game to hunt. But be careful, he cheats!",
})
keywordHandler:addKeyword({ "muriel" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Bah, go away with these sorcerer tricks. Only cowards use tricks.",
})
keywordHandler:addKeyword({ "oswald" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "What an idiot.",
})
keywordHandler:addKeyword({ "quentin" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "I will never understand this peaceful monks and priests.",
})
keywordHandler:addKeyword({ "sam" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "He has the muscles, but lacks the guts.",
})
keywordHandler:addKeyword({ "tibianus" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Hail to our King!",
})
keywordHandler:addKeyword({ "outfit" }, StdModule.say, {
	npcHandler = npcHandler,
	text = "Only the bravest warriors may wear adorned helmets. They are traditionally awarded after having completed a difficult task for our guild.",
})

npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|. What do you want?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Be careful on your journeys.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Be careful on your journeys.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
