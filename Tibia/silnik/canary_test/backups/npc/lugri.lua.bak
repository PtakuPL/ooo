local internalNpcName = "Lugri"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 145,
	lookHead = 132,
	lookBody = 114,
	lookLegs = 0,
	lookFeet = 38,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "outfit") or MsgContains(message, "addon") then
		if player:getStorageValue(Storage.Quest.U7_8.WizardOutfits) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "shield") or MsgContains(message, "medusa shield") then
		if player:getStorageValue(Storage.Quest.U7_8.WizardOutfits) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "mail") or MsgContains(message, "dragon scale mail") then
		if player:getStorageValue(Storage.Quest.U7_8.WizardOutfits) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_3")
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "legs") or MsgContains(message, "crown legs") then
		if player:getStorageValue(Storage.Quest.U7_8.WizardOutfits) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_4")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "ring") or MsgContains(message, "ring of the sky") then
		if player:getStorageValue(Storage.Quest.U7_8.WizardOutfits) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_5")
			npcHandler:setTopic(playerId, 6)
		end

		------------Task Part-------------
	elseif MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers) < 0 and player:getLevel() >= 60 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_12")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.NecromancerCount) >= 4000 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_7")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_9")
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers, 1)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.BossKillCount.NecropharusCount, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_6")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_5")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers, 4)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers) == 3 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.NecromancerCount) >= 1000 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_7")
				player:addExperience(40000, true)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers, 4)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_8")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_9")
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_10")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_11")
			player:setStorageValue(Storage.Quest.U7_8.WizardOutfits, 1)
			player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1) --this for default start of Outfit and Addon Quests
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(3436, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_12")
				player:setStorageValue(Storage.Quest.U7_8.WizardOutfits, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_13")
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(3386, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_14")
				player:setStorageValue(Storage.Quest.U7_8.WizardOutfits, 3)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_15")
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(3382, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_16")
				player:setStorageValue(Storage.Quest.U7_8.WizardOutfits, 4)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_17")
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(3006, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_18")
				player:setStorageValue(Storage.Quest.U7_8.WizardOutfits, 5)
				player:addOutfitAddon(145, 2)
				player:addOutfitAddon(149, 2)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_19")
			end
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.multi_3")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.NecromancerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.NecromancerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PriestessCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.BloodPriestCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.BloodHandCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.ShadowPupilCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_20")
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.NecromancerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.NecromancerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PriestessCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.BloodPriestCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.BloodHandCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.ShadowPupilCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.LugriNecromancers, 3)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) > 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lugri.say_21")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "What is it that you {want}, |PLAYERNAME|?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Bye.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Bye.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
