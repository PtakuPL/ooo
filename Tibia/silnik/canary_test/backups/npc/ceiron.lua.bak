local internalNpcName = "Ceiron"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 144,
	lookHead = 78,
	lookBody = 100,
	lookLegs = 119,
	lookFeet = 116,
	lookAddons = 3,
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

	if table.contains({ "addon", "outfit" }, message) then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_1")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "faolan") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_2")
			npcHandler:setTopic(playerId, 3)
		elseif player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_3")
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 9)
			npcHandler:setTopic(playerId, 0)
		end
	elseif table.contains({ "griffinclaw", "container" }, message) then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_4")
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "task") then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_20")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_22")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_23")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_13")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_14")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_15")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_17")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_10")
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "waterskin") or MsgContains(message, "water skin") then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_5")
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "dust") or MsgContains(message, "demon dust") then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_6")
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "chain") or MsgContains(message, "wolf tooth chain") then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_7")
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "ceiron's waterskin") then
		if player:getStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_8")
			npcHandler:setTopic(playerId, 12)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.multi_5")
			npcHandler:setTopic(playerId, 4)
		elseif npcHandler:getTopic(playerId) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_9")
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 1)
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DefaultStart, 1) --this for default start of Outfit and Addon Quests
			player:addItem(4867, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			if player:removeItem(5937, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_10")
				player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 2)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_11")
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 3)
			player:addItem(5938, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(5939, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_12")
				player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 4)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 8 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_13")
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(5906, 100) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_14")
				player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 6)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 10 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_15")
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 7)
			player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidAmuletDoor, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			if player:removeItem(5940, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_16")
				player:setStorageValue(Storage.Quest.U7_8.DruidOutfits.DruidHatAddon, 8)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 12 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ceiron.say_17")
			npcHandler:setTopic(playerId, 13)
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeMoneyBank(1000) then
				player:addItem(5938, 1)
				npcHandler:setTopic(playerId, 0)
			end
		end
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.ceiron.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.ceiron.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.ceiron.walkaway_msg_1")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
