local internalNpcName = "Klom Stonecutter"
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
	lookHead = 3,
	lookBody = 77,
	lookLegs = 68,
	lookFeet = 76,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.klom_stonecutter.voice_1" },
	{ i18nKey = "npc.klom_stonecutter.voice_2" },
	{ text = 'And they call this "deep"...' },
	{ i18nKey = "npc.klom_stonecutter.voice_3" },
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

local count = {}

local function greetCallback(npc, creature)
	NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
		"npc.klom_stonecutter.greet_msg_1",
		"npc.klom_stonecutter.greet_msg_2",
	}, 1000)
	return false
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local time = 20 * 60 * 60 -- 20 hours

	if MsgContains(message, "subterraneans") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_1")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_10")
			npcHandler:setTopic(playerId, 2)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_8")
			npcHandler:setTopic(playerId, 2)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms) < 50) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_2")
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms) >= 50) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_3")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean, os.time() + time)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean, 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_4")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms, 0)
		npcHandler:setTopic(playerId, 1)
	end

	if MsgContains(message, "home") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_5")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome) <= 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_6")
			npcHandler:setTopic(playerId, 22)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.multi_3")
			npcHandler:setTopic(playerId, 22)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) < 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) < 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_6")
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) >= 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) < 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_7")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome, os.time() + time)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home, 2)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 1)
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) >= 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) >= 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_8")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome, os.time() + time)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home, 2)
			player:addItem(27654, 2)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 22 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_9")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles, 0)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners, 0)
		npcHandler:setTopic(playerId, 1)
	end

	local plural = ""

	if MsgContains(message, "suspicious devices") or MsgContains(message, "suspicious device") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_10")
		npcHandler:setTopic(playerId, 55)
	elseif npcHandler:getTopic(playerId) == 55 then
		count[playerId] = tonumber(message)
		if count[playerId] then
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_1", { count[playerId], plural })
			npcHandler:setTopic(playerId, 56)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_11")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_12")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_gnomes", {count[playerId]})
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_13")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_14")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_dwarves", {count[playerId]})
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_15")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_16")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quest.dangerous_depths.earned_points_scouts", {count[playerId]})
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_17")
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "status") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_18")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_2", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points), 0) })
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_3", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points), 0) })
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_4", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points), 0) })
	end

	return true
end

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.klom_stonecutter.stdmod_1" })
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.klom_stonecutter.stdmod_2" })
keywordHandler:addKeyword({ "defences" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.klom_stonecutter.stdmod_7",
})
keywordHandler:addKeyword({ "counterattacks" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.klom_stonecutter.stdmod_8",
})
keywordHandler:addKeyword({ "enemy" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.klom_stonecutter.stdmod_9",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.klom_stonecutter.stdmod_3" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.klom_stonecutter.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
