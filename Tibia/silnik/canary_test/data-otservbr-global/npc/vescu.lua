local internalNpcName = "Vescu"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 152,
	lookHead = 119,
	lookBody = 120,
	lookLegs = 119,
	lookFeet = 101,
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

local topic = {}

local stage1Keys = { "npc.vescu.stage_1_request", "npc.vescu.stage_1_progress", "npc.vescu.stage_1_next" }
local stage2Keys = { "npc.vescu.stage_2_request", "npc.vescu.stage_2_progress", "npc.vescu.stage_2_next" }
local stage3Keys = { "npc.vescu.stage_3_request", "npc.vescu.stage_3_progress", "npc.vescu.stage_3_next" }
local stage4Keys = { "npc.vescu.stage_4_request", "npc.vescu.stage_4_progress", "npc.vescu.stage_4_next" }
local stage5Keys = { "npc.vescu.stage_5_request", "npc.vescu.stage_5_progress", "npc.vescu.stage_5_next" }
local stage6Keys = { "npc.vescu.stage_6_request", "npc.vescu.stage_6_progress", "npc.vescu.stage_6_next" }
local stage7Keys = { "npc.vescu.stage_7_request", "npc.vescu.stage_7_progress", "npc.vescu.stage_7_next" }

local config = {
	["30 bonelord eyes"] = { storageValue = 1, i18nKeys = stage1Keys, itemId = 5898, count = 30 },
	["bonelord eyes"] = { storageValue = 1, i18nKeys = stage1Keys, itemId = 5898, count = 30 },
	["bonelord eye"] = { storageValue = 1, i18nKeys = stage1Keys, itemId = 5898, count = 30 },
	["10 red dragon scales"] = { storageValue = 2, i18nKeys = stage2Keys, itemId = 5882, count = 10 },
	["red dragon scales"] = { storageValue = 2, i18nKeys = stage2Keys, itemId = 5882, count = 10 },
	["red dragon scale"] = { storageValue = 2, i18nKeys = stage2Keys, itemId = 5882, count = 10 },
	["30 lizard scales"] = { storageValue = 3, i18nKeys = stage3Keys, itemId = 5881, count = 30 },
	["lizard scales"] = { storageValue = 3, i18nKeys = stage3Keys, itemId = 5881, count = 30 },
	["lizard scale"] = { storageValue = 3, i18nKeys = stage3Keys, itemId = 5881, count = 30 },
	["20 fish fins"] = {
		storageValue = 4,
		i18nKeys = stage4Keys,
		itemId = 5895,
		count = 20,
	},
	["fish fins"] = { storageValue = 4, i18nKeys = stage4Keys, itemId = 5895, count = 20 },
	["fish fin"] = { storageValue = 4, i18nKeys = stage4Keys, itemId = 5895, count = 20 },
	["20 vampire dust"] = { storageValue = 5, i18nKeys = stage5Keys, itemId = 5905, count = 20 },
	["vampire dust"] = { storageValue = 5, i18nKeys = stage5Keys, itemId = 5905, count = 20 },
	["10 demon dust"] = {
		storageValue = 6,
		i18nKeys = stage6Keys,
		itemId = 5906,
		count = 10,
	},
	["demon dust"] = {
		storageValue = 6,
		i18nKeys = stage6Keys,
		itemId = 5906,
		count = 10,
	},
	["warrior's sweat"] = {
		storageValue = 7,
		i18nKeys = stage7Keys,
		itemId = 5885,
	},
}

local function endConversationWithDelay(npcHandler, npc, creature)
	addEvent(function()
		npcHandler:unGreet(npc, creature)
	end, 1000)
end

local function greetCallback(npc, creature)
	local player = Player(creature)
	if player and player:getCondition(CONDITION_DRUNK) and player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) < 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vescu.greet_msg_1")
		npcHandler:setInteraction(npc, creature)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_1")
		endConversationWithDelay(npcHandler, npc, creature)
		return false
	end

	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "sober") then
		if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_2")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "potion") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_3")
				npcHandler:setTopic(playerId, 2)
			end
		end
	elseif config[message] and npcHandler:getTopic(playerId) == 0 then
		if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) == config[message].storageValue then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].i18nKeys[1])
			npcHandler:setTopic(playerId, 4)
			topic[playerId] = message
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].i18nKeys[2])
		end
	elseif MsgContains(message, "secret") then
		if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_4")
			player:addOutfit(156)
			player:addOutfit(152)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			player:setStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit, 9)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.vescu.multi_1", "npc.vescu.multi_2", "npc.vescu.multi_3", "npc.vescu.multi_4", "npc.vescu.multi_5" }, 10)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(Storage.OutfitQuest.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_5")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			local targetMessage = config[topic[playerId]]
			local count = targetMessage.count or 1
			if not player:removeItem(targetMessage.itemId, count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_6")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit, player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinBaseOutfit) + 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.i18nKeys[3])
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) ~= 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_7")
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vescu.say_8")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	topic[playerId] = nil
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.vescu.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.vescu.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
