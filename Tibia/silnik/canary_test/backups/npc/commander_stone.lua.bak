local internalNpcName = "Commander Stone"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 512,
	lookHead = 85,
	lookBody = 9,
	lookLegs = 9,
	lookFeet = 9,
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

	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLineComplete) >= 2 then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_2")
			npcHandler:setTopic(playerId, 0)
		end

		-- Crystal Kepper
	elseif MsgContains(message, "keeper") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.CrystalKeeperTimout) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_3")
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.RepairedCrystalCount, 0)
				player:addItem(15703, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.CrystalKeeperTimout) > os.time() then -- trying to take mission while in cooldown
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_4")
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper) > 0 then -- reporting mission
				if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.RepairedCrystalCount) >= 5 then -- can report missions
					player:removeItem(15703, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) + 5)
					player:addItem(16128, 1)
					player:addItem(15698, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper, 0)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.CrystalKeeperTimout, os.time() + configManager.getNumber(configKeys.BOSS_DEFAULT_TIME_TO_FIGHT_AGAIN))
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.RepairedCrystalCount, -1)
					player:addAchievement("Crystal Keeper")
					player:checkGnomeRank()
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_5")
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_6") -- is reporting
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_7") -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_8")
		end
		-- Crystal Keeper

		-- Raiders of the Lost Spark
	elseif MsgContains(message, "spark") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.RaidersOfTheLostSparkTimeout) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_9")
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount, 0)
				player:addItem(15696, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.RaidersOfTheLostSparkTimeout) > os.time() then -- trying to take mission while in cooldown
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_10")
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark) > 0 then -- reporting mission
				if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount) >= 7 then -- can report missions
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) + 5)
					player:removeItem(15696, 1)
					player:addItem(16128, 1)
					player:addItem(15698, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark, 0)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount, -1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.RaidersOfTheLostSparkTimeout, os.time() + configManager.getNumber(configKeys.BOSS_DEFAULT_TIME_TO_FIGHT_AGAIN))
					player:addAchievement("Call Me Sparky")
					player:checkGnomeRank()
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_11")
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_12") -- is reporting
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_13") -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_14")
		end
		-- Raiders of the Lost Spark

		-- Exterminators
	elseif MsgContains(message, "extermination") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatorsTimeout) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_15")
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatedCount, 0) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatorsTimeout) > os.time() then -- trying to take mission while in cooldown
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_16")
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators) > 0 then -- reporting mission
				if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatedCount) >= 10 then -- can report missions
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) + 5)
					player:addItem(16128, 1)
					player:addItem(15698, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators, 0)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatedCount, -1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatorsTimeout, os.time() + configManager.getNumber(configKeys.BOSS_DEFAULT_TIME_TO_FIGHT_AGAIN))
					player:addAchievement("One Foot Vs. Many")
					player:checkGnomeRank()
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_17")
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_18") -- is reporting
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_19") -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_20")
		end
		-- Exterminators

		-- Mushroom Digger
	elseif MsgContains(message, "digging") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomDiggerTimeout) < os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.multi_4")
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount, 0)
				player:addItem(15828, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomDiggerTimeout) > os.time() then -- trying to take mission while in cooldown
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_21")
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger) > 0 then -- reporting mission
				if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount) >= 3 then -- can report missions
					player:removeItem(15828, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) + 5)
					player:addItem(16128, 1)
					player:addItem(15698, 1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger, 0)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount, -1)
					player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomDiggerTimeout, os.time() + configManager.getNumber(configKeys.BOSS_DEFAULT_TIME_TO_FIGHT_AGAIN))
					player:addAchievement("The Picky Pig")
					player:checkGnomeRank()
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_22")
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_23") -- is reporting
					else
						NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_24") -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_25")
		end
		-- Mushroom Digger
	elseif MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_26")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.commander_stone.say_27")
			npcHandler:setTopic(playerId, 2)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.commander_stone.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
