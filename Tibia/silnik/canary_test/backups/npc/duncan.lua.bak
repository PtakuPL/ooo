local internalNpcName = "Duncan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 38,
	lookBody = 23,
	lookLegs = 0,
	lookFeet = 116,
	lookAddons = 1,
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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local storage = Storage.Quest.U7_8.PirateOutfits.PirateSabreAddon

	if table.contains({ "outfit", "addon" }, message) and player:getStorageValue(Storage.Quest.U7_8.PirateOutfits.PirateBaseOutfit) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_1")
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_2")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 10)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_3")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2) > 0 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_4")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_5")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "task") then
		if player:getStorageValue(storage) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_6")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "eye patches") then
		if player:getStorageValue(storage) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_7")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "peg legs") then
		if player:getStorageValue(storage) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_8")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "hooks") then
		if player:getStorageValue(storage) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_9")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_7")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(storage, 1)
			player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1) --this for default start of Outfit and Addon Quests
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_10")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(6098, 100) then
				player:setStorageValue(storage, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_11")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_12")
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(6126, 100) then
				player:setStorageValue(storage, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_13")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_14")
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(6097, 100) then
				player:setStorageValue(storage, 4)
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_firebird")
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_15")
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 10 then
				if player:removeItem(6108, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_16")
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 11)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_17")
					npcHandler:setTopic(playerId, 0)
				end
			end
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor) < 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.multi_4")
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor, 1)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor) == 1 then
				if player:removeItem(6125, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_18")
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorDoor, 2)
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 16)
					if player:getStorageValue(Storage.TheIceIslands.Questline) >= 9 then
						player:addAchievement("Animal Activist")
					end
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_19")
					npcHandler:setTopic(playerId, 0)
				end
			end
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) >= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.duncan.say_20")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.duncan.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.duncan.farewell_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "pirate tapestry", clientId = 5615, buy = 40 },
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
