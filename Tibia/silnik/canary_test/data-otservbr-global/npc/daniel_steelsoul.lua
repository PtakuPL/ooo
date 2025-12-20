local internalNpcName = "Daniel Steelsoul"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 73,
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

local condition = Condition(CONDITION_FIRE)
condition:setParameter(CONDITION_PARAM_DELAYED, 1)
condition:addDamage(14, 1000, -10)

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "fuck", "idiot", "asshole", "ass", "fag", "stupid", "tyrant", "shit", "lunatic" }, message) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_1")
		player:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONAREA)
		player:addCondition(condition)
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.AgainstTheSpiderCult) < 1 then
			npcHandler:setTopic(playerId, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_2")
		elseif player:getStorageValue(Storage.Quest.U8_1.TibiaTales.AgainstTheSpiderCult) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.AgainstTheSpiderCult, 6)
			npcHandler:setTopic(playerId, 0)
			player:addItem(814, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_3")
		end
	elseif MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.TrollCount) >= 100 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_4")
				player:addExperience(200, true)
				player:addMoney(200)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask, 1)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_1", { player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.TrollCount) })
				return true
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GoblinTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GoblinCount) >= 150 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_5")
				player:addExperience(300, true)
				player:addMoney(250)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GoblinTask, 1)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_2", { player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GoblinCount) })
				return true
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.RotwormCount) >= 300 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_6")
				player:addExperience(1000, true)
				player:addMoney(400)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask, 1)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_3", { player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.RotwormCount) })
				return true
			end
		elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask) == 0 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.CyclopsCount) >= 500 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_7")
				player:addExperience(3000, true)
				player:addMoney(800)
				player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask, 1)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_4", { player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.CyclopsCount) })
				return true
			end
		end
		if player:getLevel() < 20 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask) < 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_12")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_13")
				npcHandler:setTopic(playerId, 2)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask) == 1 and player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GoblinTask) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_8")
				npcHandler:setTopic(playerId, 4)
			elseif player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_11")
				npcHandler:setTopic(playerId, 3)
			end
		end
		if player:getLevel() >= 30 and player:getLevel() < 60 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask) < 0 or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_9")
				npcHandler:setTopic(playerId, 6)
				return true
			end
		end
		if player:getLevel() >= 20 and player:getLevel() < 40 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask) < 0 or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_9")
				npcHandler:setTopic(playerId, 5)
				return true
			end
		end
	elseif MsgContains(message, "trolls") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_10")
		player:setStorageValue(JOIN_STOR, 1)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.TrollCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.TrollCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.TrollChampionCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask, 0)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "goblins") and npcHandler:getTopic(playerId) == 4 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_11")
		player:setStorageValue(JOIN_STOR, 1)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GoblinCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinScavengerCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinAssassinCount, 0)
		player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GoblinTask, 0)
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.DefaultStart, 1)
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.AgainstTheSpiderCult, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_7")
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_12")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.TrollCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.TrollCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.TrollChampionCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.TrollTask, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_13")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.GoblinCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinScavengerCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.GoblinAssassinCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.GoblinTask, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_5")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.RotwormCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.RotwormCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.CarrionWormnCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask, 0)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.multi_3")
			player:setStorageValue(JOIN_STOR, 1)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.MonsterKillCount.CyclopsCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.CyclopsCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.CyclopsDroneCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.AltKillCount.CyclopsSmithCount, 0)
			player:setStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask, 0)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_14")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_15")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 5 and player:getLevel() >= 30 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.CyclopsTask) < 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_16")
				npcHandler:setTopic(playerId, 6)
			end
		elseif npcHandler:getTopic(playerId) == 6 and player:getLevel() < 40 then
			if player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask) < 0 or player:getStorageValue(Storage.Quest.U8_5.KillingInTheNameOf.RotwormTask) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.daniel_steelsoul.say_17")
				npcHandler:setTopic(playerId, 5)
			end
		end
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.daniel_steelsoul.stdmod_1" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.daniel_steelsoul.stdmod_2" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.daniel_steelsoul.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.daniel_steelsoul.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.daniel_steelsoul.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
