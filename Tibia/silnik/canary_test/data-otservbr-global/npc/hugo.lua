local internalNpcName = "Hugo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 14,
	lookBody = 81,
	lookLegs = 80,
	lookFeet = 0,
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

local config = {
	["20 brown pieces of cloth"] = {
		itemId = 5913,
		count = 20,
		value = 1,
		messageKey = {
			done = "npc.hugo.cloth_done",
			deliever = "npc.hugo.cloth_deliver",
			notEnough = "npc.hugo.cloth_not_enough",
			success = "npc.hugo.cloth_success",
		},
	},
	["50 minotaur leathers"] = {
		itemId = 5878,
		count = 50,
		value = 2,
		messageKey = {
			done = "npc.hugo.leather_done",
			deliever = "npc.hugo.leather_deliver",
			notEnough = "npc.hugo.leather_not_enough",
			success = "npc.hugo.leather_success",
		},
	},
	["10 bat wings"] = {
		itemId = 5894,
		count = 10,
		value = 3,
		messageKey = {
			done = "npc.hugo.bat_done",
			deliever = "npc.hugo.bat_deliver",
			notEnough = "npc.hugo.bat_not_enough",
			success = "npc.hugo.bat_success",
		},
	},
	["30 heaven blossoms"] = {
		itemId = 5921,
		count = 30,
		value = 4,
		messageKey = {
			done = "npc.hugo.blossom_done",
			deliever = "npc.hugo.blossom_deliver",
			notEnough = "npc.hugo.blossom_not_enough",
			success = "npc.hugo.blossom_success",
		},
		lastItem = true,
	},
}

local topic = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	topic[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "uniforms") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "dress pattern") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_2")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 2)
		elseif player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_3")
			player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission06, 12)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "outfit") then
		if not player:isPremium() then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_4")
			return true
		end

		if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_6")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) > 0 and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) < 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_5")
		elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 5 then
			if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimer) > os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_6")
			elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimer) > 0 and player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimer) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_7")
				npcHandler:setTopic(playerId, 5)
			end
		elseif player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_8")
		end
	elseif config[message:lower()] then
		local targetMessage = config[message:lower()]
		if player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) ~= targetMessage.value then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.done)
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.deliever)
		npcHandler:setTopic(playerId, 4)
		topic[playerId] = targetMessage
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.multi_3")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(Storage.OutfitQuest.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_9")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			local targetMessage = topic[playerId]
			if not player:removeItem(targetMessage.itemId, targetMessage.count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.notEnough)
				return true
			end

			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, player:getStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit) + 1)
			if targetMessage.lastItem then
				player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfitTimer, os.time() + 86400)
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.success)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:addOutfit(153)
			player:addOutfit(157)
			player:setStorageValue(Storage.Quest.U7_8.BeggarOutfits.BeggarOutfit, 6)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_11")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_12")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_13")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.hugo.say_14")
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
