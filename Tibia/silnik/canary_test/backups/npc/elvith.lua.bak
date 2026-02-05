local internalNpcName = "Elvith"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 159,
	lookHead = 76,
	lookBody = 3,
	lookLegs = 0,
	lookFeet = 76,
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
keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_1" })
keywordHandler:addKeyword({ "instruments" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_2" })
keywordHandler:addKeyword({ "music" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_4" })
keywordHandler:addKeyword({ "song" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_5" })
keywordHandler:addKeyword({ "melody" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_6" })
keywordHandler:addKeyword({ "elf" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_7" })
keywordHandler:addKeyword({ "kuridai" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_8" })
keywordHandler:addKeyword({ "teshial" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_9" })
keywordHandler:addKeyword({ "crunor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_10" })
keywordHandler:addKeyword({ "human" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_11" })
keywordHandler:addKeyword({ "deraisim" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_12" })
keywordHandler:addKeyword({ "cenath" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_13" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_14" })
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_15" })
keywordHandler:addKeyword({ "hellgate" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.elvith.stdmod_16" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "songs of the forest") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elvith.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elvith.multi_2")
	elseif MsgContains(message, "love poem") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elvith.say_17")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:setTopic(playerId, 0)
			local player = Player(creature)
			if not player:removeMoneyBank(200) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elvith.say_18")
				return true
			end

			player:addItem(6119, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.elvith.say_19")
		end
	end
	return true
end

-- Greeting message
keywordHandler:addGreetKeyword({ "ashari" }, { npcHandler = npcHandler, text = "Ashari, |PLAYERNAME|.", i18nKey = "npc.elvith.greet_1" })
--Farewell message
keywordHandler:addFarewellKeyword({ "asgha thrazi" }, { npcHandler = npcHandler, text = "Asha Thrazi, |PLAYERNAME|.", i18nKey = "npc.elvith.farewell_1" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.elvith.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.elvith.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.elvith.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "drum", clientId = 14253, buy = 140 },
	{ itemName = "lute", clientId = 2950, buy = 195 },
	{ itemName = "lyre", clientId = 2949, buy = 120 },
	{ itemName = "simple fanfare", clientId = 2954, buy = 150 },
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
