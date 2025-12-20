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
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_1")
				npcHandler:setTopic(playerId, 9)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust, 0)
			end
			if player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) < 20 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_1", { player:getItemCount(5905) })
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust) == 20 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_2")
				npcHandler:setTopic(playerId, 2)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 7)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 2) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			end
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_9")
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 8)
			player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 3) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 8 or player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) == 9 then
			if player:removeItem(7924, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.multi_4")
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline, 10)
				player:setStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Mission03, 5) -- The Inquisition Questlog- "Mission 3: Vampire Hunt"
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_3")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "vampire lord token") and player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.Questline) >= 11 then
		if player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_4")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_5")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_6")
			npcHandler:setTopic(playerId, 5)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_7")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_8")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_9")
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

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_2", { count, (20 - player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust)) == 0 and "Ask me for a {mission} to continue your quest." or ("Ye' need to bring " .. (20 - player:getStorageValue(Storage.Quest.U8_2.TheInquisitionQuest.StorkusVampiredust)) .. " more.") })
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(8192, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_10")
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 1)
				player:addExperience(1000, true)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_11")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(8192, 4) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_12")
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 2)
				player:addExperience(5 * 1000, true)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_13")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(8192, 5) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_14")
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 3)
				player:addExperience(10 * 1000, true)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_15")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			if player:removeItem(8192, 10) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_16")
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 4)
				player:addExperience(20 * 1000, true)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_17")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(8192, 30) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_18")
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 5)
				player:addExperience(50 * 1000, true)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_19")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(8192, 50) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_20")
				player:addItem(8191, 1)
				player:addExperience(100 * 1000, true)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Rank, 6)
				player:setStorageValue(Storage.Quest.U8_2.VampireHunterQuest.Door, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_21")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.storkus.say_22")
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
