local internalNpcName = "Chartan"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 338,
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
		if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.say_3")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "zalamon") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_13")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 3)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission01, 3) --Questlog, Wrath of the Emperor "Mission 01: Catering the Lions Den"
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_7")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 4)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission02, 1) --Questlog, Wrath of the Emperor "Mission 02: First Contact"
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chartan.multi_2")
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.TeleportAccess.Rebel, 1)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Questline, 6)
			player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission02, 3) --Questlog, Wrath of the Emperor "Mission 02: First Contact"
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.chartan.greet_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "avalanche rune", clientId = 3161, buy = 64 },
	{ itemName = "blank rune", clientId = 3147, buy = 10 },
	{ itemName = "chameleon rune", clientId = 3178, buy = 210 },
	{ itemName = "convince creature rune", clientId = 3177, buy = 80 },
	{ itemName = "cure poison rune", clientId = 3153, buy = 65 },
	{ itemName = "destroy field rune", clientId = 3148, buy = 15 },
	{ itemName = "dragonfruit", clientId = 11682, buy = 5 },
	{ itemName = "egg", clientId = 3606, buy = 3 },
	{ itemName = "empty potion flask", clientId = 283, sell = 5 },
	{ itemName = "empty potion flask", clientId = 284, sell = 5 },
	{ itemName = "empty potion flask", clientId = 285, sell = 5 },
	{ itemName = "energy field rune", clientId = 3164, buy = 38 },
	{ itemName = "energy wall rune", clientId = 3166, buy = 85 },
	{ itemName = "explosion rune", clientId = 3200, buy = 31 },
	{ itemName = "fire bomb rune", clientId = 3192, buy = 147 },
	{ itemName = "fire field rune", clientId = 3188, buy = 28 },
	{ itemName = "fire wall rune", clientId = 3190, buy = 61 },
	{ itemName = "great fireball rune", clientId = 3191, buy = 64 },
	{ itemName = "great health potion", clientId = 239, buy = 225 },
	{ itemName = "great mana potion", clientId = 238, buy = 158 },
	{ itemName = "great spirit potion", clientId = 7642, buy = 254 },
	{ itemName = "ham", clientId = 3582, buy = 10 },
	{ itemName = "health potion", clientId = 266, buy = 50 },
	{ itemName = "heavy magic missile rune", clientId = 3198, buy = 12 },
	{ itemName = "intense healing rune", clientId = 3152, buy = 95 },
	{ itemName = "light magic missile rune", clientId = 3174, buy = 4 },
	{ itemName = "mana potion", clientId = 268, buy = 56 },
	{ itemName = "poison field rune", clientId = 3172, buy = 21 },
	{ itemName = "poison wall rune", clientId = 3176, buy = 52 },
	{ itemName = "stalagmite rune", clientId = 3179, buy = 12 },
	{ itemName = "strong health potion", clientId = 236, buy = 115 },
	{ itemName = "strong mana potion", clientId = 237, buy = 108 },
	{ itemName = "sudden death rune", clientId = 3155, buy = 162 },
	{ itemName = "supreme health potion", clientId = 23375, buy = 650 },
	{ itemName = "ultimate healing rune", clientId = 3160, buy = 175 },
	{ itemName = "ultimate health potion", clientId = 7643, buy = 379 },
	{ itemName = "ultimate mana potion", clientId = 23373, buy = 488 },
	{ itemName = "ultimate spirit potion", clientId = 23374, buy = 488 },
	{ itemName = "vial", clientId = 2874, sell = 5 },
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
