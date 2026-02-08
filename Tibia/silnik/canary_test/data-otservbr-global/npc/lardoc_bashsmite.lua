local internalNpcName = "Lardoc Bashsmite"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 160,
	lookHead = 57,
	lookBody = 47,
	lookLegs = 47,
	lookFeet = 76,
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

local amount = {}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local time = 20 * 60 * 60 -- 20 hours

	if MsgContains(message, "diremaws") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.TimeTaskDiremaws) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_1")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.TimeTaskDiremaws) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_22")
			npcHandler:setTopic(playerId, 2)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_17")
			npcHandler:setTopic(playerId, 2)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.DiremawsCount) < 20) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.DiremawsCount) >= 20 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_3")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskDiremaws, os.time() + time)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw, 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_4")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Diremaw, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.GnomishChest, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.DiremawsCount, 0)
		npcHandler:setTopic(playerId, 1)
	end

	if MsgContains(message, "growth") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.TimeTaskGrowth) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_5")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.TimeTaskGrowth) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_12")
			npcHandler:setTopic(playerId, 22)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.multi_6")
			npcHandler:setTopic(playerId, 22)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.BarrelCount) >= 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_6")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskGrowth, os.time() + time)
			if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.BarrelCount) >= 5 then
				player:addItem(27654, 2)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + 2)
			else
				player:addItem(27654, 1)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + 1)
			end
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth, 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 22 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_7")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Growth, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.BarrelCount, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.FirstBarrel, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.SecondBarrel, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.ThirdBarrel, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.FourthBarrel, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.FifthBarrel, 0)

		npcHandler:setTopic(playerId, 1)
		npcHandler:setTopic(playerId, 1)
	end

	local plural = ""

	if MsgContains(message, "suspicious devices") or MsgContains(message, "suspicious device") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_8")
		npcHandler:setTopic(playerId, 55)
	elseif npcHandler:getTopic(playerId) == 55 then
		amount[playerId] = tonumber(message)
		if amount[playerId] then
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_1", { amount[playerId], plural })
			npcHandler:setTopic(playerId, 56)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_9")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_10")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_gnomes", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_11")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_12")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_dwarves", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_13")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_14")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_scouts", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_15")
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "status") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_16")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_2", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points), 0) })
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_3", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points), 0) })
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.lardoc_bashsmite.say_4", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points), 0) })
	end

	return true
end

keywordHandler:addKeyword({ "work" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lardoc_bashsmite.stdmod_1" })
keywordHandler:addKeyword({ "worth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.lardoc_bashsmite.stdmod_3",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.lardoc_bashsmite.stdmod_4",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.lardoc_bashsmite.stdmod_2" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.lardoc_bashsmite.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.lardoc_bashsmite.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
