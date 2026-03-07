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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local time = 20 * 60 * 60 -- 20 hours

	if MsgContains(message, "subterraneans") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_19")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean) <= 0 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.klom_stonecutter.say_20", "npc.klom_stonecutter.say_21" })
			npcHandler:setTopic(playerId, 2)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.klom_stonecutter.say_22", "npc.klom_stonecutter.say_23" })
			npcHandler:setTopic(playerId, 2)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms) < 50) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_24")
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms) >= 50) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_25")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskSubterranean, os.time() + time)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean, 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 2 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_26")
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline) < 1 then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Questline, 1)
		end
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Subterranean, 1)
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Organisms, 0)
		npcHandler:setTopic(playerId, 1)
	end

	if MsgContains(message, "home") then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome) > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_27")
			npcHandler:setTopic(playerId, 1)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 2 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome) <= 0 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.klom_stonecutter.say_28", "npc.klom_stonecutter.say_29", "npc.klom_stonecutter.say_30" })
			npcHandler:setTopic(playerId, 22)
		end
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) < 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.klom_stonecutter.say_31", "npc.klom_stonecutter.say_32", "npc.klom_stonecutter.say_33" })
			npcHandler:setTopic(playerId, 22)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) < 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) < 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_34")
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) >= 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) < 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_35")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome, os.time() + time)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home, 2)
			player:addItem(27654, 1)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 1)
			npcHandler:setTopic(playerId, 1)
		elseif (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home) == 1) and (player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.LostExiles) >= 20 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Prisoners) >= 3) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_36")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.TimeTaskHome, os.time() + time)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Home, 2)
			player:addItem(27654, 2)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + 2)
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 22 and MsgContains(message, "yes") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_37")
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
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_38")
		npcHandler:setTopic(playerId, 55)
	elseif npcHandler:getTopic(playerId) == 55 then
		count[playerId] = tonumber(message)
		if count[playerId] then
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_39", { count[playerId], plural })
			npcHandler:setTopic(playerId, 56)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_40")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_41")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You earned " .. count[playerId] .. " point" .. plural .. " on the gnomes mission.")
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_42")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_43")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You earned " .. count[playerId] .. " point" .. plural .. " on the dwarves mission.")
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_44")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 56 then
		if player:getItemCount(27653) >= count[playerId] then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_45")
			if count[playerId] > 1 then
				plural = plural .. "s"
			end
			player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You earned " .. count[playerId] .. " point" .. plural .. " on the scouts mission.")
			player:removeItem(27653, count[playerId])
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points, player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points) + count[playerId])
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_46")
			npcHandler:setTopic(playerId, 1)
		end
	end

	if MsgContains(message, "status") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_47")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "gnomes") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_48", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Points), 0) })
	elseif MsgContains(message, "dwarves") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_49", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Dwarves.Points), 0) })
	elseif MsgContains(message, "scouts") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.klom_stonecutter.say_50", { math.max(player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.Points), 0) })
	end

	return true
end

keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, text = "Well, the biggest problem we need to address are the ever charging {subterraneans} around here. And on top of that, there's the threat of the Lost, who quite made themselves at {home} in these parts." , i18nKey = "npc.klom_stonecutter.stdmod_10"})
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "Maintainin' this whole operation, the dwarven involvement 'course. Don't know about them gnomes but if I ain't gettin' those dwarves in line, there'll be chaos down here. I also oversee the {defences} and {counterattacks}." , i18nKey = "npc.klom_stonecutter.stdmod_11"})
keywordHandler:addKeyword({ "defences" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"The attacks of the enemy forces are fierce but we hold our ground. ... ",
		"I'd love to face one of their generals in combat but as their masters they cowardly hide far behind enemy lines and I have other duties to fulfil. ... ",
		"I envy you for the chance to thrust into the heart of the enemy, locking weapons with their jaws... or whatever... and see the fear in their eyes when they recognise they were bested.",
	},
})
keywordHandler:addKeyword({ "counterattacks" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"I welcome a fine battle as any dwarf worth his beard should do. As long as it's a battle against something I can hit with my trusty axe. ...",
		"But here the true {enemy} eludes us. We fight wave after wave of their lackeys and if the gnomes are right the true enemy is up to something far more sinister. ",
	},
})
keywordHandler:addKeyword({ "enemy" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"I have no idea what kind of creeps are behind all this. Even the gnomes don't and they have handled that stuff way more often. ...",
		"But even if we knew nothing more about them, the fact alone that they employ the help of those mockeries of all things dwarfish, marks them as an enemy of the dwarves and it's our obligation to annihilate them.",
	},
})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "Klom Stonecutter's the name. " , i18nKey = "npc.klom_stonecutter.stdmod_12"})

npcHandler:setMessage(MESSAGE_GREET, {
	"Greetings. A warning straight ahead: I don't like loiterin'. If you're not here to {help} us, you're here to waste my time. Which I consider loiterin'. Now, try and prove your {worth} to our alliance. ... ",
	"I have sealed some of the areas far too dangerous for anyone to enter. If you can prove you're capable, you'll get an opportunity to help destroy the weird machines, pumping lava into the caves leading to the most dangerous enemies.",
})
npcHandler:setMessage(MESSAGE_WALKAWAY, "Well, bye then.")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
