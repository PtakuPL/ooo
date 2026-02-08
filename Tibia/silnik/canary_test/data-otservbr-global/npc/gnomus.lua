local internalNpcName = "Gnomus"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 493,
	lookHead = 67,
	lookBody = 67,
	lookLegs = 67,
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

	if MsgContains(message, "measurements") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskMeasurements) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_1")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskMeasurements) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_34")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_35")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_36")
			npcHandler:setTopic(playerId, 2)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_31")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_32")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_33")
			npcHandler:setTopic(playerId, 2)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationCount) < 5) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationCount) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_29")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_30")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskMeasurements, os.time() + time)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements, 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_26")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_27")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_28")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Measurements, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartChest, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationCount, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationA, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationB, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationC, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationD, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LocationE, 0)
		npcHandler:setTopic(playerId, 1)
	end

	if MsgContains(message, "ordnance") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 3 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskOrdnance) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_3")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 3 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskOrdnance) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_23")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_24")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_25")
			npcHandler:setTopic(playerId, 22)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_20")
			npcHandler:setTopic(playerId, 22)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 1) or (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomesCount) < 5) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_4")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomesCount) >= 5 then
			if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.CrawlersCount) >= 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_15")
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskOrdnance, os.time() + time)
				player:addItem(27654, 2)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + 2)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_5")
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskOrdnance, os.time() + time)
				player:addItem(27654, 1)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + 1)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance, 3)
			end
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 22 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_12")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_13")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomesCount, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.CrawlersCount, 0)
		npcHandler:setTopic(playerId, 1)
	end

	if MsgContains(message, "charting") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskCharting) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_6")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskCharting) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_11")
			npcHandler:setTopic(playerId, 33)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_7")
			npcHandler:setTopic(playerId, 33)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.ChartingCount) < 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_7")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.ChartingCount) >= 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_8")
			if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.ChartingCount) == 6 then
				player:addItem(27654, 2)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + 2)
			else
				player:addItem(27654, 1)
				player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + 1)
			end
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting, 2)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TimeTaskCharting, os.time() + time)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 33 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.multi_3")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Charting, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.ChartingCount, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartPaper, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.OldGate, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.TheGaze, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.LostRuin, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Outpost, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Bastion, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.BrokenTower, 0)
		npcHandler:setTopic(playerId, 1)
	end

	local plural = ""

	if MsgContains(message, "suspicious devices") or MsgContains(message, "suspicious device") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_9")
		npcHandler:setTopic(playerId, 55)
	elseif npcHandler:getTopic(playerId) == 55 then
		amount[playerId] = tonumber(message)
		if amount[playerId] then
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_1", { amount[playerId], plural })
			npcHandler:setTopic(playerId, 56)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_10")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_11")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_gnomes", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_12")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_13")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_dwarves", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_14")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= amount[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_15")
			if amount[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_scouts", {amount[playerId]})
			player:removeItem(27653, amount[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + amount[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_16")
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "status") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_17")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_2", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points), 0) })
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_3", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points), 0) })
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomus.say_4", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points), 0) })
	end

	return true
end

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gnomus.stdmod_1" })
keywordHandler:addKeyword({ "worthy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gnomus.stdmod_4",
})
keywordHandler:addKeyword({ "base" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gnomus.stdmod_6" })
keywordHandler:addKeyword({ "efforts" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gnomus.stdmod_5",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gnomus.stdmod_2" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.gnomus.stdmod_3" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomus.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gnomus.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)