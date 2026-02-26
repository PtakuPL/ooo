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
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.sandomo.say_11", "npc.sandomo.say_12" })
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "bridge") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.sandomo.say_13", "npc.sandomo.say_14" })
			npcHandler:setTopic(playerId, 2)
		end
	elseif MsgContains(message, "mortar") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.sandomo.say_15", "npc.sandomo.say_16", "npc.sandomo.say_17", "npc.sandomo.say_18", "npc.sandomo.say_19" })
			npcHandler:setTopic(playerId, nil)
		end
	end

	if MsgContains(message, "gratitude") then
		npcHandler:setTopic(playerId, 3)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_20")
	elseif MsgContains(message, "repairs") then
		if npcHandler:getTopic(playerId) == 3 then
			if player:getInquisitionGold() > 0 then
				npcHandler:setTopic(playerId, 4)
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.sandomo.say_21", { math.max(0, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Mortar_Thrown)) } }, { "npc.sandomo.say_22", { math.max(0, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Frazzlemaws)) } }, { "npc.sandomo.say_23", { math.max(0, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Silencers)), player:getInquisitionGold() } } })
			else
				npcHandler:setTopic(playerId, nil)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_24")
			end
		end
	elseif npcHandler:getTopic(playerId) == 4 then
		local v = math.max(0, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record))
		if MsgContains(message, "book") or MsgContains(message, "books") then
			npcHandler:setTopic(playerId, 5)
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.sandomo.say_25", { player:getInquisitionGold(), v } }, "npc.sandomo.say_26" })
		end
	elseif npcHandler:getTopic(playerId) == 5 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.sandomo.say_27", { player:getName(), player:getInquisitionGold() } }, "npc.sandomo.say_28" })
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record, player:getInquisitionGold())
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Mortar_Thrown, 0)
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Frazzlemaws, 0)
			player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Killed_Silencers, 0)
			npcHandler:setTopic(playerId, nil)
		end
	elseif MsgContains(message, "record") then
		local v = player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record)
		if v > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_29", { v })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_30")
		end
	elseif MsgContains(message, "trade") then
		local v = player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record)
		if v >= 100 then
			npcHandler:setTopic(playerId, 6)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_31", { v })
		else
			npcHandler:setTopic(playerId, nil)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_32")
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		local v = tonumber(message)
		if (v == nil) or (v < 1) or (math.floor(v) ~= v) then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_33")
		end

		local max = math.floor(player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) / 100)
		if v > max then
			return NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_34", { max })
		end

		player:addItem(20062, v)
		npcHandler:setTopic(playerId, nil)
		player:setStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record, player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) - (v * 100))
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_35", { player:getStorageValue(Storage.Quest.U10_30.RoshamuulQuest.Roshamuul_Gold_Record) })
	end

	if MsgContains(message, "bucket") or MsgContains(message, "supplies") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_36")
	elseif MsgContains(message, "maun") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.sandomo.say_37")
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Hm. Greetings.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Praise the gods, I bid you farewell.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, false)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
