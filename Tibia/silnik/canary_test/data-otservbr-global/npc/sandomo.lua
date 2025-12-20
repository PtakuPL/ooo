local internalNpcName = "Sandomo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 289,
	lookHead = 38,
	lookBody = 113,
	lookLegs = 2,
	lookFeet = 20,
	lookAddons = 1,
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

function Player.getInquisitionGold(self)
	local v = {
		math.max(0, self:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Mortar_Thrown)) * 100,
		math.max(0, self:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Frazzlemaws)),
		math.max(0, self:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Silencers)),
	}
	return v[1] + v[2] + v[3]
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_23")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_24")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "bridge") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_21")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_22")
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "mortar") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_16")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_17")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_18")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_19")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_20")
			npcHandler:setTopic(playerId, nil)
		end
	end

	if MsgContains(message, "gratitude") then
		npcHandler:setTopic(playerId, 3)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_1")
	elseif MsgContains(message, "repairs") then
		if npcHandler:getTopic(playerId) == 3 then
			if player:getInquisitionGold() > 0 then
				npcHandler:setTopic(playerId, 4)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_9")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_11")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_12")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_13")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_15")
			else
				npcHandler:setTopic(playerId, nil)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_2")
			end
		end
	elseif npcHandler:getTopic(playerId) == 4 then
		local v = math.max(0, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record))
		if MsgContains(message, "book") or MsgContains(message, "books") then
			npcHandler:setTopic(playerId, 5)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_8")
		end
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.multi_4")
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record, player:getInquisitionGold())
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Mortar_Thrown, 0)
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Frazzlemaws, 0)
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Silencers, 0)
			npcHandler:setTopic(playerId, nil)
		end
	elseif MsgContains(message, "record") then
		local v = player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record)
		if v > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_1", { v })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_4")
		end
	elseif MsgContains(message, "trade") then
		local v = player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record)
		if v >= 100 then
			npcHandler:setTopic(playerId, 6)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_2", { v })
		else
			npcHandler:setTopic(playerId, nil)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_6")
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		local v = tonumber(message)
		if (v == nil) or (v < 1) or (math.floor(v) ~= v) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_7")
		end

		local max = math.floor(player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) / 100)
		if v > max then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_3", { max })
		end

		player:addItem(20062, v)
		npcHandler:setTopic(playerId, nil)
		player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) - (v * 100))
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_4", { player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) })
	end

	if MsgContains(message, "bucket") or MsgContains(message, "supplies") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_9")
	elseif MsgContains(message, "maun") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_10")
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.sandomo.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.sandomo.farewell_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, false)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
