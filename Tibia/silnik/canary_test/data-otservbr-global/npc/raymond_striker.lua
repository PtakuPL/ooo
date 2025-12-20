local internalNpcName = "Raymond Striker"
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
	lookHead = 39,
	lookBody = 77,
	lookLegs = 98,
	lookFeet = 95,
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

	if MsgContains(message, "eleonore") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_1")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) == 3 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_3")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 13 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_30")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_32")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_4")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 15)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1, 3)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission1) == 3 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_25")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_26")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_27")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_28")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_29")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToNargor, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2) == 2 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 16 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_5")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 18)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2, 3)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission2) == 3 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission3) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_22")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission3, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission3) == 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TavernMap1) == 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TavernMap2) == 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TavernMap3) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_17")
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 20)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission3, 3)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4, 1)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_6")
			player:addItem(6105, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4, 3)
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_13")
			player:addItem(2994, 1)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 21)
			player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4, 5)
		end
	elseif MsgContains(message, "mermaid") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) < 1 then
			if npcHandler:getTopic(playerId) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_7")
				npcHandler:setTopic(playerId, 0)
				player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid, 1)
			end
		elseif player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.APoemForTheMermaid) == 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_8")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "pirate outfit") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.AccessToLagunaIsland) == 1 and player:getStorageValue(Storage.Quest.U7_8.PirateOutfits.PirateBaseOutfit) < 1 and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_9")
			player:addOutfit(151)
			player:addOutfit(155)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
			player:setStorageValue(Storage.Quest.U7_8.PirateOutfits.PirateBaseOutfit, 1)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "task") and player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.RaysMission4) == 5 then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask) < 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_10")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.PirateCount) >= 3000 then
				if player:getStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1) <= 2 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_5")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_6")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_7")
					player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask, 1)
					player:addExperience(10000, true)
					player:addMoney(5000)
				elseif player:getStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1) == 3 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_3")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_4")
					player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask, 1)
					player:addExperience(10000, true)
					player:addMoney(5000)
				elseif player:getStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1) > 3 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_10")
					player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask, 3)
					player:addExperience(10000, true)
					player:addMoney(5000)
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_11")
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.multi_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_12")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.raymond_striker.say_13")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.PirateCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PirateMarauderCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PirateCutthroadCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PirateBuccaneerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.PirateCorsairCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.PirateTask, 0)
			player:setStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1, math.max(player:getStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1), 0))
			player:setStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1, player:getStorageValue(REPEATSTORAGE_BASE + #tasks.GrizzlyAdams + 1) + 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.raymond_striker.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.raymond_striker.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.raymond_striker.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
