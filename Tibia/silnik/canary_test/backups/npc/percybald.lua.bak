local internalNpcName = "Percybald"
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
	lookHead = 3,
	lookBody = 21,
	lookLegs = 21,
	lookFeet = 38,
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

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "disguise") then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.TheatreScript) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.multi_5")
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.TheatreScript, 0)
		end
	elseif MsgContains(message, "test") then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_3")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_4")
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_5")
			npcHandler:setTopic(playerId, 8)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_6")
			npcHandler:setTopic(playerId, 10)
		elseif npcHandler:getTopic(playerId) == 11 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_7")
			npcHandler:setTopic(playerId, 12)
		elseif npcHandler:getTopic(playerId) == 13 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_8")
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission04, 6)
			player:addItem(7865, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "I don't think so, dear doctor!") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_9")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 4 then
		if MsgContains(message, "Watch out! It's a trap!") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_11")
			npcHandler:setTopic(playerId, 5)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_12")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		if MsgContains(message, "Look! It's Lucky, the wonder dog!") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_13")
			npcHandler:setTopic(playerId, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_14")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "Oh no! Look! It's Princess Buttercup! He's holding her hostage!") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_15")
			npcHandler:setTopic(playerId, 9)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_16")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 10 then
		if MsgContains(message, "Ahhhhhh!") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_17")
			npcHandler:setTopic(playerId, 11)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_18")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 12 then
		if MsgContains(message, "Hahaha! Now drop your weapons or else...") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_19")
			npcHandler:setTopic(playerId, 13)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_20")
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- Additional dialogue options related to outfits
	if MsgContains(message, "outfit") or MsgContains(message, "addon") or MsgContains(message, "royal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_21")
		npcHandler:setTopic(playerId, 14)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 14 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.multi_3")
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 15 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_22")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 16 then
			if player:getStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit) < 1 then
				if player:removeItem(22516, 15000) and player:removeItem(22721, 12500) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_23")
					player:addOutfit(1457)
					player:addOutfit(1456)
					player:getPosition():sendMagicEffect(171)
					player:setStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit, 1)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_24")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_25")
			end
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 17 then
			if player:getStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit) == 1 then
				if player:getStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit) < 2 then
					if player:removeItem(22516, 7500) and player:removeItem(22721, 6250) then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_26")
						player:addOutfitAddon(1457, 1)
						player:addOutfitAddon(1456, 1)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit, 2)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_27")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_28")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_29")
			end
			npcHandler:setTopic(playerId, 15)
		elseif npcHandler:getTopic(playerId) == 18 then
			if player:getStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit) == 2 then
				if player:getStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit) < 3 then
					if player:removeItem(22516, 7500) and player:removeItem(22721, 6250) then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_30")
						player:addOutfitAddon(1457, 2)
						player:addOutfitAddon(1456, 2)
						player:getPosition():sendMagicEffect(171)
						player:setStorageValue(Storage.OutfitQuest.RoyalCostumeOutfit, 3)
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_31")
					end
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_32")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_33")
			end
			npcHandler:setTopic(playerId, 15)
		end
	elseif MsgContains(message, "armor") and npcHandler:getTopic(playerId) == 15 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_34")
		npcHandler:setTopic(playerId, 16)
	elseif MsgContains(message, "shield") and npcHandler:getTopic(playerId) == 15 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_35")
		npcHandler:setTopic(playerId, 17)
	elseif MsgContains(message, "crown") and npcHandler:getTopic(playerId) == 15 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.percybald.say_36")
		npcHandler:setTopic(playerId, 18)
	end

	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.percybald.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
