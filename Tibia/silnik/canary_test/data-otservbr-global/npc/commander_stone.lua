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
			npcHandler:say({ "Two missions are available for your {rank}: crystal {keeper} and {spark} hunting. You can undertake each mission but you can turn in a specific mission only once each 20 hours. ...", "If you lose a mission item you can probably buy it from Gnomally." }, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			npcHandler:say({ "For your {rank} there are four missions avaliable: crystal {keeper}, {spark} hunting, monster {extermination} and mushroom {digging}. By the way, you {rank} now allows you to take aditional missions from {Gnomeral} in {Gnomebase Alpha}. ... ", "If you lose a mission item you can probably buy it from Gnomally." }, npc, creature)
			npcHandler:setTopic(playerId, 0)
		end

		-- Crystal Kepper
	elseif MsgContains(message, "keeper") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.CrystalKeeperTimout) < os.time() then
				npcHandler:sayLocalized("npc.commander_stone.you_will_have_1", npc, creature)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionCrystalKeeper, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.RepairedCrystalCount, 0)
				player:addItem(15703, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.CrystalKeeperTimout) > os.time() then -- trying to take mission while in cooldown
				npcHandler:sayLocalized("npc.commander_stone.sorry_you_will_2", npc, creature)
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
					npcHandler:sayLocalized("npc.commander_stone.you_did_well_3", npc, creature)
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						npcHandler:sayLocalized("npc.commander_stone.you_are_not_4", npc, creature) -- is reporting
					else
						npcHandler:sayLocalized("npc.commander_stone.you_already_have_5", npc, creature) -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			npcHandler:sayLocalized("npc.commander_stone.sorry_you_do_6", npc, creature)
		end
		-- Crystal Keeper

		-- Raiders of the Lost Spark
	elseif MsgContains(message, "spark") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.RaidersOfTheLostSparkTimeout) < os.time() then
				npcHandler:say({ "Take this extractor and drive it into a body of a slain crystal crusher. This will charge your own body with energy sparks. Charge it with seven sparks and return to me. ...", "Don't worry. The gnomes assured me you'd be save. That is if nothing strange or unusual occurs! " }, npc, creature)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount, 0)
				player:addItem(15696, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.RaidersOfTheLostSparkTimeout) > os.time() then -- trying to take mission while in cooldown
				npcHandler:sayLocalized("npc.commander_stone.sorry_you_will_7", npc, creature)
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
					npcHandler:sayLocalized("npc.commander_stone.you_did_well_8", npc, creature)
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						npcHandler:sayLocalized("npc.commander_stone.you_did_not_9", npc, creature) -- is reporting
					else
						npcHandler:sayLocalized("npc.commander_stone.you_already_have_10", npc, creature) -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			npcHandler:sayLocalized("npc.commander_stone.sorry_you_do_11", npc, creature)
		end
		-- Raiders of the Lost Spark

		-- Exterminators
	elseif MsgContains(message, "extermination") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatorsTimeout) < os.time() then
				npcHandler:sayLocalized("npc.commander_stone.the_wigglers_have_12", npc, creature)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionExterminators, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatedCount, 0) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExterminatorsTimeout) > os.time() then -- trying to take mission while in cooldown
				npcHandler:sayLocalized("npc.commander_stone.sorry_you_will_13", npc, creature)
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
					npcHandler:sayLocalized("npc.commander_stone.you_did_well_14", npc, creature)
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						npcHandler:sayLocalized("npc.commander_stone.you_are_not_15", npc, creature) -- is reporting
					else
						npcHandler:sayLocalized("npc.commander_stone.you_already_have_16", npc, creature) -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			npcHandler:sayLocalized("npc.commander_stone.sorry_you_do_17", npc, creature)
		end
		-- Exterminators

		-- Mushroom Digger
	elseif MsgContains(message, "digging") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger) < 1 and player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomDiggerTimeout) < os.time() then
				npcHandler:say({
					"Take this little piggy here. It will one day become a great mushroom hunter for sure. For now it is depended on you and other pigs. ...",
					"Well, other pigs like it is one, I mean. I was of course not comparing you with a pig! Go to the truffles area and follow the truffle pigs there. If they dig up some truffles, let the little pig eat the mushrooms. ...",
					"You'll have to feed it three times. Then return it to me. ...",
					"Keep in mind that the pig has to be returned to his mother after a while. If you don't do this, the gnomes will call it back via teleport crystals.",
				}, npc, creature)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger, 1)
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount, 0)
				player:addItem(15828, 1) --- taking missions
			elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomDiggerTimeout) > os.time() then -- trying to take mission while in cooldown
				npcHandler:sayLocalized("npc.commander_stone.sorry_you_will_18", npc, creature)
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
					npcHandler:sayLocalized("npc.commander_stone.you_did_well_19", npc, creature)
					npcHandler:setTopic(playerId, 0)
				else -- haven't finished
					if npcHandler:getTopic(playerId) >= 1 then
						npcHandler:sayLocalized("npc.commander_stone.you_are_not_20", npc, creature) -- is reporting
					else
						npcHandler:sayLocalized("npc.commander_stone.you_already_have_21", npc, creature) -- se nao tiver reportando
					end
					npcHandler:setTopic(playerId, 0)
				end
			end
		else
			npcHandler:sayLocalized("npc.commander_stone.sorry_you_do_22", npc, creature)
		end
		-- Mushroom Digger
	elseif MsgContains(message, "report") then
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) < 30 then
			npcHandler:sayLocalized("npc.commander_stone.which_mission_do_23", npc, creature)
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) >= 30 then
			npcHandler:sayLocalized("npc.commander_stone.which_mission_do_24", npc, creature)
			npcHandler:setTopic(playerId, 2)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hello recruit.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
