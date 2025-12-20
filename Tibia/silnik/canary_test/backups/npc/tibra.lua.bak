local internalNpcName = "Tibra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 138,
	lookHead = 41,
	lookBody = 92,
	lookLegs = 90,
	lookFeet = 95,
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

-- Wooden Stake
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_1" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 2 and player:getItemCount(5941) == 0
end)

local stakeKeyword = keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_2" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 2
end)
stakeKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_3", reset = true }, nil, function(player)
	player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake, 3)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
stakeKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_4", reset = true })

keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_5" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) == 3
end)
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_6" }, function(player)
	return player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheBlessedStake) > 3
end)
keywordHandler:addKeyword({ "stake" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_7" })

-- Healing
local function addHealKeyword(text, condition, effect)
	keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, text = text }, function(player)
		return player:getCondition(condition) ~= nil
	end, function(player)
		player:removeCondition(condition)
		player:getPosition():sendMagicEffect(effect)
	end)
end

addHealKeyword("You are burning. Let me quench those flames.", CONDITION_FIRE, CONST_ME_MAGIC_GREEN)
addHealKeyword("You are poisoned. Let me soothe your pain.", CONDITION_POISON, CONST_ME_MAGIC_RED)
addHealKeyword("You are electrified, my child. Let me help you to stop trembling.", CONDITION_ENERGY, CONST_ME_MAGIC_GREEN)

keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_8" }, function(player)
	return player:getHealth() < 40
end, function(player)
	local health = player:getHealth()
	if health < 40 then
		player:addHealth(40 - health)
	end
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
end)
keywordHandler:addKeyword({ "heal" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_9" })

-- Basic
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_10" })
keywordHandler:addKeyword({ "life" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_11" })
keywordHandler:addKeyword({ "mission" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_12" })
keywordHandler:addKeyword({ "quest" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_13" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_14" })
keywordHandler:addKeyword({ "queen" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_15" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_16" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_17" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_18" })
keywordHandler:addKeyword({ "crypt" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_19" })
keywordHandler:addKeyword({ "monsters" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_20" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_21" })
keywordHandler:addKeyword({ "ferumbras" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_22" })
keywordHandler:addKeyword({ "lugri" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_23" })
keywordHandler:addKeyword({ "gods" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_24" })
keywordHandler:addKeyword({ "gods of good" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_25" })
keywordHandler:addKeyword({ "fardos" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_26" })
keywordHandler:addKeyword({ "uman" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_27" })
keywordHandler:addKeyword({ "air" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_28" })
keywordHandler:addKeyword({ "fire" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_29" })
keywordHandler:addKeyword({ "sula" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_30" })
keywordHandler:addKeyword({ "suon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_31" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_32" })
keywordHandler:addKeyword({ "nornur" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_33" })
keywordHandler:addKeyword({ "bastesh" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_34" })
keywordHandler:addKeyword({ "kirok" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_35" })
keywordHandler:addKeyword({ "toth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_36" })
keywordHandler:addKeyword({ "banor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_37" })
keywordHandler:addKeyword({ "evil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_38" })
keywordHandler:addKeyword({ "zathroth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_39" })
keywordHandler:addKeyword({ "fafnar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_40" })
keywordHandler:addKeyword({ "brog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_41" })
keywordHandler:addKeyword({ "urgith" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_42" })
keywordHandler:addKeyword({ "archdemons" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_43" })
keywordHandler:addKeyword({ "ruthless seven" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.tibra.stdmod_44" })

npcHandler:setMessage(MESSAGE_GREET, "Welcome in the name of the gods, pilgrim |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|. May the gods be with you to guard and guide you, my child!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
