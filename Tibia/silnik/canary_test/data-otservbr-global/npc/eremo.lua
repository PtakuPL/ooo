local internalNpcName = "Eremo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 0,
	lookBody = 109,
	lookLegs = 128,
	lookFeet = 128,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "letter") then
		if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven) == 7 then
			if player:getItemCount(3506) > 0 then
				if player:removeItem(3506, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.eremo.say_1")
					player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.ReputationInSabrehaven, 8)
				end
			end
		end
	end
	return true
end

-- Wisdom of Solitude
local blessKeyword = keywordHandler:addKeyword({ "solitude" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_1",
})
blessKeyword:addChildKeyword({ "yes" }, StdModule.bless, {
	npcHandler = npcHandler,
	text = "So receive the wisdom of solitude, pilgrim.",
	cost = "|BLESSCOST|",
	bless = 2,
})
blessKeyword:addChildKeyword({ "" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_2",
	reset = true,
})
keywordHandler:addAliasKeyword({ "wisdom" })

-- Healing
local function addHealKeyword(text, condition, effect)
	keywordHandler:addKeyword({ "heal" }, StdModule.say, {
		npcHandler = npcHandler,
		text = text,
	}, function(player)
		return player:getCondition(condition) ~= nil
	end, function(player)
		player:removeCondition(condition)
		player:getPosition():sendMagicEffect(effect)
	end)
end

addHealKeyword("You are burning. Let me quench those flames.", CONDITION_FIRE, CONST_ME_MAGIC_GREEN)
addHealKeyword("You are poisoned. Let me soothe your pain.", CONDITION_POISON, CONST_ME_MAGIC_RED)
addHealKeyword("You are electrified, my child. Let me help you to stop trembling.", CONDITION_ENERGY, CONST_ME_MAGIC_GREEN)

keywordHandler:addKeyword({ "heal" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_3",
}, function(player)
	return player:getHealth() < 40
end, function(player)
	local health = player:getHealth()
	if health < 40 then
		player:addHealth(40 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_4",
})

-- Teleport back
local teleportKeyword = keywordHandler:addKeyword({ "cormaya" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_5",
})
teleportKeyword:addChildKeyword({ "yes" }, StdModule.travel, {
	npcHandler = npcHandler,
	text = "Here you go!",
	premium = false,
	destination = Position(33288, 31956, 6),
})
teleportKeyword:addChildKeyword({ "" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_6",
	ungreet = true,
})

keywordHandler:addAliasKeyword({ "back" })
keywordHandler:addAliasKeyword({ "passage" })
keywordHandler:addAliasKeyword({ "pemaret" })

-- Basic
keywordHandler:addKeyword({ "pilgrimage" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_7",
})
keywordHandler:addKeyword({ "blessings" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_8",
})
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_9",
}, function(player)
	return player:hasBlessing(1)
end)
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_10",
}, function(player)
	return player:hasBlessing(2)
end)
keywordHandler:addKeyword({ "suns" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_11",
}, function(player)
	return player:hasBlessing(3)
end)
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_12",
}, function(player)
	return player:hasBlessing(4)
end)
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "spiritual" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_13",
})
keywordHandler:addAliasKeyword({ "shield" })
keywordHandler:addKeyword({ "embrace" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_14",
})
keywordHandler:addKeyword({ "suns" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_15",
})
keywordHandler:addAliasKeyword({ "fire" })
keywordHandler:addKeyword({ "phoenix" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_16",
})
keywordHandler:addAliasKeyword({ "spark" })
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_17",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.eremo.stdmod_18",
})

npcHandler:setMessage(MESSAGE_GREET, "Welcome to my little garden, adventurer |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "It was a pleasure to help you, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "It was a pleasure to help you, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "amulet of loss", clientId = 3057, buy = 50000, sell = 45000 },
	{ itemName = "broken amulet", clientId = 3080, sell = 50000 },
	{ itemName = "protection amulet", clientId = 3084, buy = 700, count = 250 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
