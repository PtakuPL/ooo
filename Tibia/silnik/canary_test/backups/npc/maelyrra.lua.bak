local internalNpcName = "Maelyrra"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 989,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
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

local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "mission") then
		if player:getStorageValue(ThreatenedDreams.Mission02[1]) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_1")
			npcHandler:setTopic(playerId, 1)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) >= 1 and player:getStorageValue(ThreatenedDreams.Mission02[1]) <= 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) >= 3 and player:getStorageValue(ThreatenedDreams.Mission02[1]) <= 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_3")
			npcHandler:setTopic(playerId, 4)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 5 and player:getStorageValue(ThreatenedDreams.Mission03[1]) == 4 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_4")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_5")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_6")
			npcHandler:setTopic(playerId, 8)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_7")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_8")
			player:setStorageValue(ThreatenedDreams.Mission02[1], 1)
			player:setStorageValue(ThreatenedDreams.Mission02.KroazurAccess, 1)
			player:setStorageValue(ThreatenedDreams.Mission02.EnfeebledCount, 0)
			player:setStorageValue(ThreatenedDreams.Mission02.FrazzlemawsCount, 0)
			player:setStorageValue(ThreatenedDreams.QuestLine, 2)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			local enfeebledKills = player:getStorageValue(ThreatenedDreams.Mission02.EnfeebledCount)
			local frazzlemawsKills = player:getStorageValue(ThreatenedDreams.Mission02.FrazzlemawsCount)
			local kroazurKill = player:getStorageValue(ThreatenedDreams.Mission02.KroazurKill)
			if player:getStorageValue(ThreatenedDreams.Mission02[1]) == 1 and kroazurKill >= 1 and (enfeebledKills + frazzlemawsKills) >= 200 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_9")
				npcHandler:setTopic(playerId, 3)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 2)
			elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_10")
				npcHandler:setTopic(playerId, 3)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_12")
			player:setStorageValue(ThreatenedDreams.Mission02[1], 3)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:getStorageValue(ThreatenedDreams.Mission02.FairiesCounter) == 5 and player:getStorageValue(ThreatenedDreams.Mission02.DarkMoonMirror) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_12")
				npcHandler:setTopic(playerId, 5)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 4)
			elseif player:getStorageValue(ThreatenedDreams.Mission02[1]) == 4 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_13")
				npcHandler:setTopic(playerId, 5)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_14")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 5 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_8")
			player:setStorageValue(ThreatenedDreams.Mission02[1], 5)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_6")
			player:setStorageValue(ThreatenedDreams.Mission02[1], 6)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:getItemCount(25734) >= 1 and player:getItemCount(25732) >= 1 and player:getItemCount(25730) >= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.multi_3")
				player:setStorageValue(ThreatenedDreams.Mission02[1], 7)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_15")
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getStorageValue(ThreatenedDreams.Mission02.ChargedMoonMirror) == 0 and player:getStorageValue(ThreatenedDreams.Mission02.ChargedStarlightVial) == 0 and player:getStorageValue(ThreatenedDreams.Mission02.ChargedSunCatcher) == 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_16")
				player:addItem(25780, 1)
				player:setStorageValue(ThreatenedDreams.Mission02[1], 8)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_17")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.maelyrra.say_18")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.maelyrra.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.maelyrra.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.maelyrra.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
