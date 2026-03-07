local internalNpcName = "Razan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 146,
	lookHead = 19,
	lookBody = 19,
	lookLegs = 9,
	lookFeet = 58,
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

local config = {
	["ape fur"] = {
		itemId = 5883,
		count = 100,
		storageValue = 1,
		textKey = {
			"npc.razan.ape_fur_ask",
			"npc.razan.ape_fur_info",
			"npc.razan.ape_fur_done",
		},
	},
	["fish fins"] = {
		itemId = 5895,
		count = 100,
		storageValue = 2,
		textKey = {
			"npc.razan.fish_fins_ask",
			"npc.razan.fish_fins_info",
			"npc.razan.fish_fins_done",
		},
	},
	["enchanted chicken wings"] = {
		itemId = 5891,
		count = 2,
		storageValue = 3,
		textKey = {
			"npc.razan.chicken_wings_ask",
			"npc.razan.chicken_wings_info",
			"npc.razan.chicken_wings_done",
		},
	},
	["blue cloth"] = {
		itemId = 5912,
		count = 100,
		storageValue = 4,
		textKey = {
			"npc.razan.blue_cloth_ask",
			"npc.razan.blue_cloth_info",
			"npc.razan.blue_cloth_done",
		},
	},
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if player:getSex() == PLAYERSEX_MALE and MsgContains(message, "outfit") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.say_1")
	elseif player:getSex() == PLAYERSEX_MALE and MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.say_2")
			npcHandler:setTopic(playerId, 1)
		end
	elseif config[message] and npcHandler:getTopic(playerId) == 0 then
		if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) == config[message].storageValue then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].textKey[1])
			npcHandler:setTopic(playerId, 3)
			topic[playerId] = message
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].textKey[2])
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.multi_6")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.OutfitQuest.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.say_3")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			local targetMessage = config[topic[playerId]]
			if not player:removeItem(targetMessage.itemId, targetMessage.count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.say_4")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon, player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) + 1)
			if player:getStorageValue(Storage.Quest.U7_8.OrientalOutfits.SecondOrientalAddon) == 5 then
				player:addOutfitAddon(146, 2) -- male addon
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.textKey[3])
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) ~= 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.razan.say_5")
		npcHandler:setTopic(playerId, 0)
	end

	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	topic[playerId] = nil
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.razan.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.razan.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
