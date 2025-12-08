local internalNpcName = "Storkus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 69,
	lookHead = 57,
	lookBody = 59,
	lookLegs = 118,
	lookFeet = 114,
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

	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 6 then
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) < 0 then
				npcHandler:sayLocalized("npc.storkus.so_theyve_sent_1", npc, creature)
				npcHandler:setTopic(playerId, 9)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust, 0)
			end
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) < 20 then
				npcHandler:sayLocalized("npc.storkus.so_far_yeve_2" .. player:getItemCount(5905) .. " of 20 {vampire dusts}. Do ye' have any more with ye'? ", npc, creature)
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) == 20 then
				npcHandler:sayLocalized("npc.storkus.fine_youre_done_3", npc, creature)
				npcHandler:setTopic(playerId, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 7)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 2) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			end
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 7 then
			npcHandler:say({
				"While ye' were keeping the lower ranks busy, I could get valuable information about some vampire lords. ...",
				"One of them is hiding somewhere beneath the Green Claw Swamp. I expect ye' to find him and kill him. ...",
				"But be warned: Without good preparation, ye' might get into trouble. I hope for ye' he will be sleeping in his coffin when ye' arrive. ...",
				"Before ye' open his coffin and drag that beast out to destroy it, I advise ye' to place some garlic necklaces on the stone slabs next to his coffin. That will weaken him considerably. ...",
				"Bring me his ring as proof for his death. And now hurry and good hunt to ye'.",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 8)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 3) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 8 or player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 9 then
			if player:removeItem(7924, 1) then
				npcHandler:say({
					"Ding, dong, the vampire is dead, eh? So I guess ye' can return to Henricus and tell him that ye' finished your job here. I'm quite sure he has some more challenging task up his sleeve. ...",
					"One more thing before ye' leave: I already mentioned the master vampires. ...",
					"They are quite hard to find. If ye' stumble across one of them and manage to kill him, he will surely drop some token that proves his death. Bring me these tokens. ...",
					"If ye' kill enough of them, I might have a little surprise for ye'.",
				}, npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 10)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 5) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			else
				npcHandler:sayLocalized("npc.storkus.have_ye_killed_4", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "vampire lord token") and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) >= 11 then
		if player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) < 1 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_5", npc, creature)
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 1 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_6", npc, creature)
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 2 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_7", npc, creature)
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 3 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_8", npc, creature)
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 4 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_9", npc, creature)
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 5 then
			npcHandler:sayLocalized("npc.storkus.would_ye_like_10", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			local count = player:getItemCount(5905)
			local requiredCount = 20 - player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust)
			if count > requiredCount then
				count = requiredCount
			end
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust, player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) + count)
			player:removeItem(5905, count)

			npcHandler:sayLocalized("npc.storkus.yeve_brought_me_11" .. count .. " vampire dusts. " .. (20 - player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust)) == 0 and "Ask me for a {mission} to continue your quest." or ("Ye' need to bring " .. (20 - player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust)) .. " more."), npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(8192, 1) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_12", npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 1)
				player:addExperience(1000, true)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_13", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(8192, 4) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_14", npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 2)
				player:addExperience(5 * 1000, true)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_15", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(8192, 5) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_16", npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 3)
				player:addExperience(10 * 1000, true)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_17", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(8192, 10) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_18", npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 4)
				player:addExperience(20 * 1000, true)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_19", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(8192, 30) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_20", npc, creature)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 5)
				player:addExperience(50 * 1000, true)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_21", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(8192, 50) then
				npcHandler:sayLocalized("npc.storkus.ye_brought_the_22", npc, creature)
				player:addItem(8191, 1)
				player:addExperience(100 * 1000, true)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 6)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Door, 1)
			else
				npcHandler:sayLocalized("npc.storkus.ye_dont_have_23", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			npcHandler:sayLocalized("npc.storkus.as_they_might_24", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
