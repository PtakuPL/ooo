local internalNpcName = "Amber"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 59,
	lookBody = 113,
	lookLegs = 132,
	lookFeet = 76,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.amber.voice_1" },
	{ i18nKey = "npc.amber.voice_2" },
	{ i18nKey = "npc.amber.voice_3" },
	{ i18nKey = "npc.amber.voice_4" },
	{ i18nKey = "npc.amber.voice_5" },
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

	local addonProgress = player:getStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRook)
	if MsgContains(message, "addon") or MsgContains(message, "outfit") or (addonProgress == 1 and MsgContains(message, "leather")) or ((addonProgress == 1 or addonProgress == 2) and MsgContains(message, "backpack")) then
		if addonProgress < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif addonProgress == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_2")
			npcHandler:setTopic(playerId, 3)
		elseif addonProgress == 2 then
			if player:getStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRookTimer) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_3")
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:setStorageValue(Storage.OutfitQuest.Ref, math.min(0, player:getStorageValue(Storage.OutfitQuest.Ref) - 1))
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionBackpackRook, 4)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRook, 3)
				player:addOutfitAddon(136, 1)
				player:addOutfitAddon(128, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_4")
			end
		elseif addonProgress == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_5")
		end
		return true
	end

	if npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "backpack") or MsgContains(message, "minotaur") or MsgContains(message, "leather") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_6")
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.OutfitQuest.Ref, math.max(0, player:getStorageValue(Storage.OutfitQuest.Ref)) + 1)
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRook, 1)
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionBackpackRook, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_7")
			npcHandler:removeInteraction(npc, creature)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_8")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			if player:getItemCount(5878) < 100 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_10")
				player:removeItem(5878, 100)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionBackpackRook, 2)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRook, 2)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonBackpackRookTimer, os.time() + 2 * 60 * 60) --2 hours
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.amber.say_11")
		end
		npcHandler:setTopic(playerId, 0)
	end
end

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_1",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_2",
})
keywordHandler:addKeyword({ "explore" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_3",
})
keywordHandler:addKeyword({ "adventure" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_4",
})
keywordHandler:addKeyword({ "sea" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_5",
})
keywordHandler:addKeyword({ "time" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_6",
})
keywordHandler:addKeyword({ "help" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_7",
})
keywordHandler:addKeyword({ "information" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_8",
})
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_9",
})
keywordHandler:addKeyword({ "sewer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_10",
})
keywordHandler:addKeyword({ "monster" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_11",
})
keywordHandler:addKeyword({ "cyclops" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_12",
})
keywordHandler:addKeyword({ "dragon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_13",
})
keywordHandler:addKeyword({ "raft" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_14",
})
keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_15",
})
keywordHandler:addKeyword({ "mission" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_16",
})
keywordHandler:addKeyword({ "seymour" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_17",
})
keywordHandler:addKeyword({ "academy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_18",
})
keywordHandler:addKeyword({ "king" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_19",
})
keywordHandler:addKeyword({ "thais" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_20",
})
keywordHandler:addKeyword({ "weapon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_21",
})
keywordHandler:addKeyword({ "magic" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_22",
})
keywordHandler:addKeyword({ "tibia" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_23",
})
keywordHandler:addKeyword({ "castle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_24",
})
keywordHandler:addKeyword({ "mainland" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_25",
})
keywordHandler:addKeyword({ "tools" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_26",
})
keywordHandler:addKeyword({ "rope" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_27",
})
keywordHandler:addKeyword({ "shovel" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_28",
})
keywordHandler:addKeyword({ "torch" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_29",
})
keywordHandler:addKeyword({ "bank" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_30",
})
keywordHandler:addKeyword({ "destiny" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_31",
})
keywordHandler:addKeyword({ "academy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_32",
})
keywordHandler:addKeyword({ "trade" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_33",
})
keywordHandler:addKeyword({ "premium" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_34",
})

-- Names
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_35",
})
keywordHandler:addKeyword({ "loui" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_36",
})
keywordHandler:addKeyword({ "zirella" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_37",
})
keywordHandler:addKeyword({ "santiago" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_38",
})
keywordHandler:addKeyword({ "amber" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_39",
})
keywordHandler:addKeyword({ "tom" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_40",
})
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_41",
})
keywordHandler:addKeyword({ "oracle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_42",
})
keywordHandler:addKeyword({ "norma" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_43",
})
keywordHandler:addKeyword({ "seymour" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_44",
})
keywordHandler:addKeyword({ "lily" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_45",
})
keywordHandler:addKeyword({ "billy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_46",
})
keywordHandler:addKeyword({ "willie" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_47",
})
keywordHandler:addKeyword({ "paulie" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_48",
})
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_49",
})
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_50",
})
keywordHandler:addKeyword({ "obi" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_51",
})
keywordHandler:addKeyword({ "dixi" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_52",
})
keywordHandler:addKeyword({ "zerbrus" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_53",
})
keywordHandler:addAliasKeyword({ "dallheim" })

-- Orc language
keywordHandler:addKeyword({ "orc" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_54",
})
local prisonerKeyword = keywordHandler:addKeyword({ "prisoner" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_55",
})
prisonerKeyword:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_56",
	reset = true,
})
prisonerKeyword:addChildKeyword({ "no" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_57",
	reset = true,
})
keywordHandler:addAliasKeyword({ "language" })

-- Food (Salmon)
keywordHandler:addKeyword({ "food" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_58",
})
local salmonKeyword = keywordHandler:addKeyword({ "salmon" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_59",
})
salmonKeyword:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_60",
	reset = true,
}, function(player)
	return player:getItemCount(3579) > 0
end, function(player)
	player:removeItem(3579, 1)
end)
salmonKeyword:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_61",
	reset = true,
})
salmonKeyword:addChildKeyword({ "" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_62",
	reset = true,
})

-- Logbook Quest
local bookKeyword = keywordHandler:addKeyword({ "book" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_63",
})
bookKeyword:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_64",
	reset = true,
}, function(player)
	return player:getItemCount(2821) > 0
end, function(player)
	player:addItem(3294, 1)
	player:removeItem(2821, 1)
end)
bookKeyword:addChildKeyword({ "yes" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_65",
	reset = true,
})
bookKeyword:addChildKeyword({ "" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.amber.stdmod_66",
	reset = true,
})
keywordHandler:addAliasKeyword({ "notebook" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.amber.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.amber.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.amber.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
