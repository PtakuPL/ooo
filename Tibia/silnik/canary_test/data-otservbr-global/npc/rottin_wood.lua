local internalNpcName = "Rottin Wood"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 129,
	lookHead = 114,
	lookBody = 118,
	lookLegs = 116,
	lookFeet = 97,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if MsgContains(message, "mission") or MsgContains(message, "task") then
		-- Checks if the mission has not yet started and the cooldown has expired
		if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) < 1 then
			if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time) <= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_1")
				npcHandler:setTopic(playerId, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_2")
			end

		-- Checks if the player is already on the rabbit feet collection mission
		elseif getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_3")
			npcHandler:setTopic(playerId, 3)

		-- Checks if Mission 03 is completed and the cooldown has expired
		elseif getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 2 then
			if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time) <= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_21")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_22")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_23")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_24")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_25")
				npcHandler:setTopic(playerId, 4)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_4")
			end

		-- Checks if Mission 04 is completed and the cooldown has expired
		elseif (getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 3) and getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.RottinStart) >= 4 then
			if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time) <= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_5")
				npcHandler:setTopic(playerId, 5)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_6")
			end

		-- Checks if Mission 05 is completed and the cooldown has expired
		elseif getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 4 then
			if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time) <= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_18")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_19")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_20")
				npcHandler:setTopic(playerId, 6)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_7")
			end

		-- Checks if Mission 06 is completed and the cooldown has expired
		elseif (getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03) == 5) and getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Corpse) == 4 then
			if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time) <= os.time() then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_8")
				-- Checks if this is the first time the quest is completed
				if getPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.FirstTime) == 0 then
					player:addExperience(1000, true) -- Adds 1000 experience on the first time
					setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.FirstTime, 1) -- Marks the quest as completed for the first time
				else
					player:addExperience(100, true) -- Adds 100 experience on subsequent completions
				end
				-- Resets storage values to start new missions
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, -1) -- reset storage
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.RottinStart, -1) -- reset storage
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Trap, -1) -- reset storage
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Corpse, -1) -- reset storage
				-- Sets the time to start a new mission
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time, os.time() + configManager.getNumber(configKeys.BOSS_DEFAULT_TIME_TO_FIGHT_AGAIN)) -- set time to start mission again
				setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 2) -- quest log
				-- Gives a reward item to the player
				local items = {
					[0] = { id = 3035, count = 3, chance = 100 },
					[1] = { id = 3053, count = 1, chance = 80 },
					[2] = { id = 12260, count = 1, chance = 25 },
				}
				for i = 0, #items do
					if items[i].chance > math.random(1, 100) then
						doPlayerAddItem(creature, items[i].id, items[i].count)
						npcHandler:setTopic(playerId, 0)
					end
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_9")
			end
		end
		------------------------ FINISH MISSION 03 ------------------------
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_10")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_17")
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, 1)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 1) -- quest log
			doPlayerAddItem(creature, 12171, 7)
			npcHandler:setTopic(playerId, 0)
		elseif (npcHandler:getTopic(playerId) == 3) and getPlayerItemCount(creature, 12173) >= 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_11")
			doPlayerRemoveItem(creature, 12173, 7)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, 2)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 4) -- quest log
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time, os.time() + (20 * 3600)) -- 20 hours
			npcHandler:setTopic(playerId, 0)
		elseif (npcHandler:getTopic(playerId) == 3) and getPlayerItemCount(creature, 12173) <= 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_12")
			------------------------ FINISH MISSION 01 ------------------------
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.say_13")
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, 3)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 3) -- quest log
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_13")
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, 4)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 6) -- quest log
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Time, os.time() + (20 * 3600)) -- 20 hours
			doPlayerAddItem(creature, 3035, 5)
			npcHandler:setTopic(playerId, 0)
			------------------------ FINISH MISSION 02 ------------------------
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_11")
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.rottin_wood.multi_7")
			doPlayerAddItem(creature, 12186, 5)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Mission03, 5)
			setPlayerStorageValue(creature, Storage.Quest.U8_7.RottinWoodAndTheMarriedMen.Questline, 5) -- quest log
			npcHandler:setTopic(playerId, 0)
			------------------------ FINISH MISSION 03 ------------------------
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hunter's greeting! I assume you want something from me since you came all the way out here on your own. This is a dangerous place to be, I doubt that all my men will accept strangers like I do. You don't seem to have any problems with that, though.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
