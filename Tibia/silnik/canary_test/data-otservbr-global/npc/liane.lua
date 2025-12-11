local internalNpcName = "Liane"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 136,
	lookHead = 77,
	lookBody = 98,
	lookLegs = 79,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.liane.voice_1" },
	{ i18nKey = "npc.liane.voice_2" },
	{ i18nKey = "npc.liane.voice_3" },
	{ i18nKey = "npc.liane.voice_4" },
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

	if MsgContains(message, "measurements") then
		if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) >= 1 and player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.MeasurementsLiane) ~= 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.liane.say_1")
			npcHandler:setTopic(playerId, 1)
		else
			npcHandler:say("...", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if player:removeItem(3447, 12) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.liane.say_2")
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07, player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission07) + 1)
				player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.MeasurementsLiane, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.liane.say_3")
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_GREET, "Hello. How may I help you |PLAYERNAME|? Ask me for a trade if you want to buy something. I can also explain the {mail} system.")
npcHandler:setMessage(MESSAGE_FAREWELL, "It was a pleasure to help you, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "It was a pleasure to help you, |PLAYERNAME|.")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Here. Don't forget that you need to buy a label too if you want to send a parcel. Always write the name of the {receiver} in the first line.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "label", clientId = 3507, buy = 1 },
	{ itemName = "letter", clientId = 3505, buy = 8 },
	{ itemName = "parcel", clientId = 3503, buy = 15 },
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
