local internalNpcName = "Vanys"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 1137,
	lookHead = 0,
	lookBody = 38,
	lookLegs = 34,
	lookFeet = 73,
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

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local dreamTalisman = 30132

	if MsgContains(message, "talk") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_1")
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "story") then
		if npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_2")
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "short") and npcHandler:getTopic(playerId) == 3 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_11")
		npcHandler:setTopic(playerId, 4)
	elseif npcHandler:getTopic(playerId) == 4 or npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "task") then
			if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Questline) >= 3 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.TheSummerCourt) == 1 and not (player:hasOutfit(1146) or player:hasOutfit(1147)) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_3")
				for i = 1146, 1147 do
					player:addOutfit(i)
				end
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Count) >= 8 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.TheSummerCourt) == 1 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Questline) == 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_7")
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Questline, 2)
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.TheSevenKeys.Questline, 1)
				npcHandler:setTopic(playerId, 5)
			elseif player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Questline) < 1 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.TheSummerCourt) < 1 and player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.TheWinterCourt) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.multi_5")
				if player:getStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.Questline) < 1 then
					player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.Questline, 1)
				end
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.Main.TheSummerCourt, 1)
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Questline, 1)
				player:setStorageValue(Storage.Quest.U12_00.TheDreamCourts.WardStones.Count, 0)
				player:addItem(dreamTalisman, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_4")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "keys") and npcHandler:getTopic(playerId) == 5 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_5")
	elseif MsgContains(message, "addon") then
		if player:hasOutfit(1146) or player:hasOutfit(1147) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_6")
			npcHandler:setTopic(playerId, 6)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_7")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 6 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_8")
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_9")
			npcHandler:setTopic(playerId, 8)
		end
	elseif npcHandler:getTopic(playerId) == 8 then
		if MsgContains(message, "pomegranates") then
			if player:getItemCount(30169) >= 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_10")
				player:removeItem(30169, 5)
				for i = 1146, 1147 do
					player:addOutfitAddon(i, 2)
				end
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_11")
				npcHandler:setTopic(playerId, 0)
			end
		elseif MsgContains(message, "ice shield") then
			if player:getItemCount(30168) >= 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_12")
				player:removeItem(30168, 1)
				for i = 1146, 1147 do
					player:addOutfitAddon(i, 1)
				end
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_13")
				npcHandler:setTopic(playerId, 0)
			end
		end
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.vanys.say_14")
	end
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.vanys.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.vanys.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.vanys.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
