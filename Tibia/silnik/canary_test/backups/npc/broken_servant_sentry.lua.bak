local internalNpcName = "Broken Servant Sentry"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 395,
	lookHead = 58,
	lookBody = 43,
	lookLegs = 38,
	lookFeet = 76,
	lookAddons = 0,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "slime") or MsgContains(message, "mould") or MsgContains(message, "fungus") or MsgContains(message, "sample") then
		if getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "cap") or MsgContains(message, "mage") then
		if (getPlayerItemCount(creature, 12599) >= 1 and getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit) == 2) and getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon1) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_6")
			doPlayerRemoveItem(creature, 12599, 1)
			setPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon1, 1)
			doPlayerAddOutfit(creature, 432, 1)
			doPlayerAddOutfit(creature, 433, 1)
			npcHandler:setTopic(playerId, 0)
		elseif getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon1) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "staff") or MsgContains(message, "spike") then
		if (getPlayerItemCount(creature, 12803) >= 1 and getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit) == 2) and getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon2) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_4")
			doPlayerRemoveItem(creature, 12803, 1)
			setPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon2, 1)
			doPlayerAddOutfit(creature, 432, 2)
			doPlayerAddOutfit(creature, 433, 2)
			npcHandler:setTopic(playerId, 0)
		elseif getPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Addon2) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_4")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_5")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_6")
			setPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit, 1)
			setPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Questline, 1) --this for default start of Outfit and Addon Quests
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_7")
			npcHandler:setTopic(playerId, 4)
		elseif (npcHandler:getTopic(playerId) == 4) and getPlayerItemCount(creature, 12601) >= 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.multi_2")
			doPlayerRemoveItem(creature, 12601, 20)
			setPlayerStorageValue(creature, Storage.Quest.U9_1.ElementalistOutfits.Outfit, 2)
			doPlayerAddOutfit(creature, 432, 0)
			doPlayerAddOutfit(creature, 433, 0)
			npcHandler:setTopic(playerId, 0)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.broken_servant_sentry.say_8")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "The Master is-is-is-is de-ad. Plea*chrrrrchk*se. Be. In. Mourning.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
