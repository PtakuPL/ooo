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
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_48")
	elseif MsgContains(message, "mortal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_49")
	elseif MsgContains(message, "Goshnar") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_50", "npc.flickering_soul.say_51" }, 4000)
	elseif MsgContains(message, "ambition") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_52", "npc.flickering_soul.say_53" }, 4000)
	elseif MsgContains(message, "milestone") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_54")
	elseif MsgContains(message, "everything") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_55")
	elseif MsgContains(message, "accomplish") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_56", "npc.flickering_soul.say_57", "npc.flickering_soul.say_58" }, 4000)
	elseif MsgContains(message, "dead") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_59")
	elseif MsgContains(message, "confident") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_60")
	elseif MsgContains(message, "peace") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_61", "npc.flickering_soul.say_62", "npc.flickering_soul.say_63", "npc.flickering_soul.say_64" }, 4000)
	elseif MsgContains(message, "soul") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_65", "npc.flickering_soul.say_66" }, 4000)
	elseif MsgContains(message, "weariness") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_67", "npc.flickering_soul.say_68" }, 4000)
	elseif MsgContains(message, "knowledge") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_69")
	elseif MsgContains(message, "return") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_70", "npc.flickering_soul.say_71" }, 4000)
	elseif MsgContains(message, "fetters") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_72", "npc.flickering_soul.say_73", "npc.flickering_soul.say_74" }, 4000)
	elseif MsgContains(message, "powerful") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_75")
	elseif MsgContains(message, "task") then
		local soulWarQuest = player:soulWarQuestKV()
		-- Checks if the boss has already been defeated
		if soulWarQuest:get("goshnar's-megalomania-killed") then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_76", "npc.flickering_soul.say_77" }, 2000)
			npcHandler:setTopic(playerId, 2)
			player:addOutfit("Revenant")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_78")
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_79")
		soulWarQuest:set("teleport-access", true)
	elseif MsgContains(message, "burden") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_80", "npc.flickering_soul.say_81" }, 5000)
	elseif MsgContains(message, "shards") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_82")
	elseif MsgContains(message, "hate") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_83", "npc.flickering_soul.say_84" }, 4000)
	elseif MsgContains(message, "fermuba") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_85")
	elseif MsgContains(message, "ferumbras") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_86", "npc.flickering_soul.say_87" }, 4000)
	elseif MsgContains(message, "grandson") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_88")
	elseif MsgContains(message, "pale worm") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_89")
	elseif MsgContains(message, "necromant king") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, player, { "npc.flickering_soul.say_90", "npc.flickering_soul.say_91" }, 4000)
	elseif MsgContains(message, "minions") or MsgContains(message, "followers") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_92")
	elseif MsgContains(message, "shards") then
		local bossesYetToDefeat = {}
		for bossName, _ in pairs(SoulWarQuest.miniBosses) do
			if not soulWarQuest:get(bossName) then
				table.insert(bossesYetToDefeat, bossName)
			end
		end

		local message
		if #bossesYetToDefeat > 0 then
			message = "You haven't killed " .. table.concat(bossesYetToDefeat, ", ") .. " yet."
		else
			message = "You have defeated all the Goshnar's Bosses. Your soul shines brighter with each victory."
		end
		npcHandler:say(message, npc, player)
	elseif MsgContains(message, "taints") or MsgContains(message, "penalties") then
		if player:getTaintLevel() ~= nil then
			player:resetTaints(true)
			NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_93")
			return
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, player, "npc.flickering_soul.say_94")
	end
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, playerSayCallback)

npcHandler:setMessage(MESSAGE_GREET, "Be greeted, living soul!")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
