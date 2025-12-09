function ParseAlesarSay(npc, creature, message, npcHandler)
	local player = Player(creature)
	local playerId = player:getId()

	local missionProgress = player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02)
	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission01) == 3 then
			if missionProgress < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_15")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_16")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_17")
				npcHandler:setTopic(playerId, 1)
			elseif table.contains({ 1, 2 }, missionProgress) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.say_1")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.say_2")
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_7")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_10")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_11")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_12")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_13")
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02, 1)
			player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.DoorToMaridTerritory, 1)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.say_3")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if player:getItemCount(3233) == 0 or missionProgress ~= 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.say_4")
				npcHandler:setTopic(playerId, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.multi_5")
				player:removeItem(3233, 1)
				player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02, 3)
				npcHandler:setTopic(playerId, 0)
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alesar_functions.say_5")
			npcHandler:setTopic(playerId, 1)
		end
	end
end
