local internalNpcName = "Erayo"
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
	lookHead = 86,
	lookBody = 125,
	lookLegs = 86,
	lookFeet = 87,
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

local stage1Keys = { "npc.erayo.stage_1_request", "npc.erayo.stage_1_progress" }
local stage2Keys = { "npc.erayo.stage_2_request", "npc.erayo.stage_2_progress" }
local stage3Keys = { "npc.erayo.stage_3_request", "npc.erayo.stage_3_progress" }
local stage4Keys = { "npc.erayo.stage_4_request", "npc.erayo.stage_4_progress" }
local stage5Keys = { "npc.erayo.stage_5_request", "npc.erayo.stage_5_progress" }
local stage6Keys = { "npc.erayo.stage_6_request", "npc.erayo.stage_6_progress" }
local stage7Keys = { "npc.erayo.stage_7_request", "npc.erayo.stage_7_progress" }

local config = {
	["50 blue cloth"] = { storageValue = 1, i18nKeys = stage1Keys, itemId = 5912, count = 50 },
	["50 green cloth"] = { storageValue = 2, i18nKeys = stage2Keys, itemId = 5910, count = 50 },
	["50 red cloth"] = { storageValue = 3, i18nKeys = stage3Keys, itemId = 5911, count = 50 },
	["50 brown cloth"] = { storageValue = 4, i18nKeys = stage4Keys, itemId = 5913, count = 50 },
	["50 yellow cloth"] = { storageValue = 5, i18nKeys = stage5Keys, itemId = 5914, count = 50 },
	["50 white cloth"] = { storageValue = 6, i18nKeys = stage6Keys, itemId = 5909, count = 50 },
	["10 spools of yarn"] = { storageValue = 7, i18nKeys = stage7Keys, itemId = 5886, count = 10 },
	["10 yarn"] = { storageValue = 7, i18nKeys = stage7Keys, itemId = 5886, count = 10 },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "addon") then
		if player:hasOutfit(player:getSex() == PLAYERSEX_FEMALE and 156 or 152) and player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon) < 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.Shipwrecked) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.erayo.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif config[message] and npcHandler:getTopic(playerId) == 0 then
		if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon) == config[message].storageValue then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, config[message].i18nKeys[1])
			npcHandler:setTopic(playerId, 3)
			topic[playerId] = message
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.erayo.multi_1", "npc.erayo.multi_2", "npc.erayo.multi_3", "npc.erayo.multi_4" }, 10)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			if player:getStorageValue(Storage.OutfitQuest.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.erayo.say_2")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			local targetMessage = config[topic[playerId]]
			if not player:removeItem(targetMessage.itemId, targetMessage.count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.erayo.say_3")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon, player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon) + 1)
			if player:getStorageValue(Storage.Quest.U7_8.AssassinOutfits.AssassinFirstAddon) == 8 then
				player:addOutfitAddon(156, 1)
				player:addOutfitAddon(152, 1)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end
			local completionArgs = targetMessage.storageValue == 7 and { player:getName() } or nil
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.i18nKeys[2], completionArgs)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) > 0 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.erayo.say_4")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	topic[playerId] = nil
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.erayo.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
