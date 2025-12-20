local internalNpcName = "Norma"
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
	lookHead = 78,
	lookBody = 76,
	lookLegs = 72,
	lookFeet = 96,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.norma.voice_1" },
	{ i18nKey = "npc.norma.voice_2" },
	{ i18nKey = "npc.norma.voice_3" },
	{ i18nKey = "npc.norma.voice_4" },
	{ i18nKey = "npc.norma.voice_5" },
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

--[[
addon
Pretty, isn't it? I made it myself, but I could teach you how to do that if you like. What do you say?
hat
13:44 Norma: Pretty, isn't it? I made it myself, but I could teach you how to do that if you like. What do you say?
yes
13:44 Norma: Okay, here we go, listen closely! I need a few things... a basic hat of course, maybe a legion helmet would do. Then about 100 chicken feathers... and 50 honeycombs as glue. That's it, come back to me once you gathered it!!
]]

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "addon") or MsgContains(message, "outfit") or MsgContains(message, "hat") then
		if player:getStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonHatRook) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_1")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionHatRookRook) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_2")
			npcHandler:setTopic(playerId, 1)
		end

		return true
	end

	if npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonHatRook, 1)
			player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionHatRook, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_3")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_4")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if player:getItemCount(3374) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_5")
			elseif player:getItemCount(5890) < 100 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_6")
			elseif player:getItemCount(5902) < 50 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_8")
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				player:removeItem(3374, 1)
				player:removeItem(5902, 50)
				player:removeItem(5890, 100)
				player:addOutfitAddon(136, 2)
				player:addOutfitAddon(128, 2)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.MissionHatRook, 0)
				player:setStorageValue(Storage.Quest.U7_8.CitizenOutfitsRook.AddonHatRook, 2)
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.norma.say_9")
		end
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

-- Basic keywords
keywordHandler:addKeyword({ "hint" }, StdModule.rookgaardHints, { npcHandler = npcHandler })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_2" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_3" })
keywordHandler:addKeyword({ "merchant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_4" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_5" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_6" })
keywordHandler:addKeyword({ "equipment" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_7" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_8" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_9" })
keywordHandler:addKeyword({ "sewer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_10" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_11" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_12" })
keywordHandler:addKeyword({ "premium" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_13" })
keywordHandler:addKeyword({ "drink" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_14" })
keywordHandler:addKeyword({ "temple" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_15" })

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_16" })
keywordHandler:addAliasKeyword({ "information" })

keywordHandler:addKeyword({ "backpack" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_17" })
keywordHandler:addAliasKeyword({ "rope" })
keywordHandler:addAliasKeyword({ "shovel" })
keywordHandler:addAliasKeyword({ "fishing" })

keywordHandler:addKeyword({ "armor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_18" })
keywordHandler:addAliasKeyword({ "shield" })

keywordHandler:addKeyword({ "offer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_19" })
keywordHandler:addAliasKeyword({ "sell" })
keywordHandler:addAliasKeyword({ "buy" })
keywordHandler:addAliasKeyword({ "wares" })
keywordHandler:addAliasKeyword({ "stuff" })

-- Names
keywordHandler:addKeyword({ "mary" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_20" })
keywordHandler:addKeyword({ "al", "dee" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_21" })
keywordHandler:addKeyword({ "amber" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_22" })
keywordHandler:addKeyword({ "billy" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_23" })
keywordHandler:addKeyword({ "willie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_24" })
keywordHandler:addKeyword({ "tom" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_25" })
keywordHandler:addKeyword({ "seymour" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_26" })
keywordHandler:addKeyword({ "zirella" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_27" })
keywordHandler:addKeyword({ "santiago" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_28" })
keywordHandler:addKeyword({ "paulie" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_29" })
keywordHandler:addKeyword({ "oracle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_30" })
keywordHandler:addKeyword({ "obi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_31" })
keywordHandler:addKeyword({ "norma" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_32" })
keywordHandler:addKeyword({ "dixi" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_33" })
keywordHandler:addKeyword({ "loui" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_34" })
keywordHandler:addKeyword({ "lee'delle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_35" })
keywordHandler:addKeyword({ "hyacinth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_36" })
keywordHandler:addKeyword({ "cipfried" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_37" })
keywordHandler:addKeyword({ "dallheim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.norma.stdmod_38" })
keywordHandler:addAliasKeyword({ "zerbrus" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.norma.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.norma.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, "npc.norma.sendtrade_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.norma.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "bread", clientId = 3600, buy = 3 },
	{ itemName = "cheese", clientId = 3607, buy = 5 },
	{ itemName = "egg", clientId = 3606, buy = 2 },
	{ itemName = "mug of beer", clientId = 2880, buy = 3, count = 3 },
	{ itemName = "mug of lemonade", clientId = 2880, buy = 2, count = 12 },
	{ itemName = "mug of milk", clientId = 2880, buy = 2, count = 6 },
	{ itemName = "mug of wine", clientId = 2880, buy = 3, count = 2 },
	{ itemName = "party cake", clientId = 6279, buy = 50 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
