local internalNpcName = "Flickering Soul"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 1219,
	lookHead = 6,
	lookBody = 26,
	lookLegs = 26,
	lookFeet = 6,
	lookAddons = 0,
	lookMount = 0,
}

npcConfig.flags = {
	floorchange = false,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, player)
	npcHandler:onAppear(npc, player)
end

npcType.onDisappear = function(npc, player)
	npcHandler:onDisappear(npc, player)
end

npcType.onMove = function(npc, player, fromPosition, toPosition)
	npcHandler:onMove(npc, player, fromPosition, toPosition)
end

npcType.onSay = function(npc, player, type, message)
	npcHandler:onSay(npc, player, type, message)
end

npcType.onCloseChannel = function(npc, player)
	npcHandler:onCloseChannel(npc, player)
end

local function playerSayCallback(npc, player, type, message)
	if not npcHandler:checkInteraction(npc, player) then
		return false
	end

	local soulWarQuest = player:soulWarQuestKV()

	local playerId = player:getId()
	if MsgContains(message, "living") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_1")
	elseif MsgContains(message, "mortal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_2")
	elseif MsgContains(message, "Goshnar") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_18", "npc.flickering_soul.say_19"}, 4000)
	elseif MsgContains(message, "ambition") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_20", "npc.flickering_soul.say_21"}, 4000)
	elseif MsgContains(message, "milestone") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_3")
	elseif MsgContains(message, "everything") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_4")
	elseif MsgContains(message, "accomplish") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_22", "npc.flickering_soul.say_23", "npc.flickering_soul.say_24"}, 4000)
	elseif MsgContains(message, "dead") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_5")
	elseif MsgContains(message, "confident") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_6")
	elseif MsgContains(message, "peace") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_25", "npc.flickering_soul.say_26", "npc.flickering_soul.say_27", "npc.flickering_soul.say_28"}, 4000)
	elseif MsgContains(message, "soul") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_29", "npc.flickering_soul.say_30"}, 4000)
	elseif MsgContains(message, "weariness") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_31", "npc.flickering_soul.say_32"}, 4000)
	elseif MsgContains(message, "knowledge") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_7")
	elseif MsgContains(message, "return") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_33", "npc.flickering_soul.say_34"}, 4000)
	elseif MsgContains(message, "fetters") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_35", "npc.flickering_soul.say_36", "npc.flickering_soul.say_37"}, 4000)
	elseif MsgContains(message, "powerful") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_8")
	elseif MsgContains(message, "task") then
		local soulWarQuest = player:soulWarQuestKV()
		-- Checks if the boss has already been defeated
		if soulWarQuest:get("goshnar's-megalomania-killed") then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_38", "npc.flickering_soul.say_39"}, 2000)
			npcHandler:setTopic(playerId, 2)
			player:addOutfit("Revenant")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_9")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_10")
		soulWarQuest:set("teleport-access", true)
	elseif MsgContains(message, "burden") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_40", "npc.flickering_soul.say_41"}, 5000)
	elseif MsgContains(message, "shards") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_11")
	elseif MsgContains(message, "hate") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_42", "npc.flickering_soul.say_43"}, 4000)
	elseif MsgContains(message, "fermuba") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_12")
	elseif MsgContains(message, "ferumbras") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_44", "npc.flickering_soul.say_45"}, 4000)
	elseif MsgContains(message, "grandson") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_13")
	elseif MsgContains(message, "pale worm") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_14")
	elseif MsgContains(message, "necromant king") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, {"npc.flickering_soul.say_46", "npc.flickering_soul.say_47"}, 4000)
	elseif MsgContains(message, "minions") or MsgContains(message, "followers") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_15")
	elseif MsgContains(message, "shards") then
		local bossesYetToDefeat = {}
		for bossName, _ in pairs(SoulWarQuest.miniBosses) do
			if not soulWarQuest:get(bossName) then
				table.insert(bossesYetToDefeat, bossName)
			end
		end

		local message
		if #bossesYetToDefeat > 0 then
			local bossList = table.concat(bossesYetToDefeat, ", ")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.shards_remaining", { bossList })
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.shards_all_done")
		end
	elseif MsgContains(message, "taints") or MsgContains(message, "penalties") then
		if player:getTaintLevel() ~= nil then
			player:resetTaints(true)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_16")
			return
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.flickering_soul.say_17")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, playerSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.flickering_soul.greet_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
