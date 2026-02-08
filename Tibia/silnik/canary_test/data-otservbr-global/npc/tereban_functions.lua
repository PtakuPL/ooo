local topic = {}

local storages = {
	Storage.Quest.U8_6.AFathersBurden.Sinew,
	Storage.Quest.U8_6.AFathersBurden.Wood,
	Storage.Quest.U8_6.AFathersBurden.Cloth,
	Storage.Quest.U8_6.AFathersBurden.Silk,
	Storage.Quest.U8_6.AFathersBurden.Crystal,
	Storage.Quest.U8_6.AFathersBurden.Root,
	Storage.Quest.U8_6.AFathersBurden.Iron,
	Storage.Quest.U8_6.AFathersBurden.Scale,
}

TerebanConfig = {
	["strong sinew"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Sinew,
		messages = {
			deliever = "npc.tereban.sinew_deliver",
			success = "npc.tereban.sinew_success",
			failure = {"npc.tereban.sinew_failure"},
			no = {"npc.tereban.sinew_no"},
			done = "npc.tereban.sinew_done",
		},
		itemId = 11548, -- Strong sinew
	},
	["exquisite wood"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Wood,
		messages = {
			deliever = "npc.tereban.wood_deliver",
			success = "npc.tereban.wood_success",
			failure = {"npc.tereban.wood_failure_1", "npc.tereban.wood_failure_2"},
			no = {"npc.tereban.wood_no"},
			done = "npc.tereban.wood_done",
		},
		itemId = 11547, -- Exquisite wood
	},
	["spectral cloth"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Cloth,
		messages = {
			deliever = "npc.tereban.cloth_deliver",
			success = "npc.tereban.cloth_success",
			failure = {"npc.tereban.cloth_failure"},
			no = {"npc.tereban.cloth_no"},
			done = "npc.tereban.cloth_done",
		},
		itemId = 11546, -- Spectral cloth
	},
	["exquisite silk"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Silk,
		messages = {
			deliever = "npc.tereban.silk_deliver",
			success = "npc.tereban.silk_success",
			failure = {"npc.tereban.silk_failure"},
			no = {"npc.tereban.silk_no"},
			done = "npc.tereban.silk_done",
		},
		itemId = 11545, -- Exquisite silk
	},
	["magic crystal"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Crystal,
		messages = {
			deliever = "npc.tereban.crystal_deliver",
			success = "npc.tereban.crystal_success",
			failure = {"npc.tereban.crystal_failure_1", "npc.tereban.crystal_failure_2"},
			no = {"npc.tereban.crystal_no_1", "npc.tereban.crystal_no_2"},
			done = "npc.tereban.crystal_done",
		},
		itemId = 11552, -- Magical crystal
	},
	["mystic root"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Root,
		messages = {
			deliever = "npc.tereban.root_deliver",
			success = "npc.tereban.root_success",
			failure = {"npc.tereban.root_failure"},
			no = {"npc.tereban.root_no"},
			done = "npc.tereban.root_done",
		},
		itemId = 11551, -- Mystic root
	},
	["old iron"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Iron,
		messages = {
			deliever = "npc.tereban.iron_deliver",
			success = "npc.tereban.iron_success",
			failure = {"npc.tereban.iron_failure"},
			no = {"npc.tereban.iron_no"},
			done = "npc.tereban.iron_done",
		},
		itemId = 11549, -- Old iron
	},
	["flexible dragon scale"] = {
		storage = Storage.Quest.U8_6.AFathersBurden.Scale,
		messages = {
			deliever = "npc.tereban.scale_deliver",
			success = "npc.tereban.scale_success",
			failure = {"npc.tereban.scale_failure"},
			no = {"npc.tereban.scale_no"},
			done = "npc.tereban.scale_done",
		},
		itemId = 11550, -- Flexibe dragon scale
	},
}
local ThreatenedDreams = Storage.Quest.U11_40.ThreatenedDreams

function ClearTerebanMessages(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()
	topic[playerId] = nil
end

function ParseTerebanSay(npc, creature, message, npcHandler)
	local player = Player(creature)
	local playerId = player:getId()
	if npcHandler:getTopic(playerId) == 0 then
		if MsgContains(message, "cloak") then
			if player:getStorageValue(ThreatenedDreams.Mission01[1]) == 12 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_10")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_11")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_12")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_13")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_14")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_15")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_16")
				player:setStorageValue(ThreatenedDreams.Mission01[1], 13)
				player:setStorageValue(ThreatenedDreams.Mission01.FeathersCount, 0) -- Start Mission 'Tattered Swan Feathers'
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.say_1")
				npcHandler:setTopic(playerId, 0)
			end
		elseif MsgContains(message, "mission") then
			if player:getStorageValue(Storage.Quest.U8_6.AFathersBurden.Status) == 1 then
				if player:getStorageValue(Storage.Quest.U8_6.AFathersBurden.Progress) ~= 8 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.say_2")
					return true
				end

				player:setStorageValue(Storage.Quest.U8_6.AFathersBurden.Status, 2)
				player:addItem(oldCape, 1)
				player:addExperience(8000, true)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_8")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_9")
			elseif player:getStorageValue(Storage.Quest.U8_6.AFathersBurden.Status) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.say_3")
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.multi_7")
				npcHandler:setTopic(playerId, 1)
			end
		elseif TerebanConfig[message:lower()] then
			local targetMessage = TerebanConfig[message:lower()]
			if player:getStorageValue(targetMessage.storage) == 2 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messages.done)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messages.deliever)
			npcHandler:setTopic(playerId, 2)
			topic[playerId] = targetMessage
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.say_4")
			player:setStorageValue(Storage.Quest.U8_6.AFathersBurden.QuestLog, 1)
			player:setStorageValue(Storage.Quest.U8_6.AFathersBurden.Progress, 0)
			player:setStorageValue(Storage.Quest.U8_6.AFathersBurden.Status, 1)
			for i = 1, #storages do
				player:setStorageValue(storages[i], 1)
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.tereban_functions.say_5")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		local targetMessage = topic[playerId]
		if MsgContains(message, "yes") then
			if not player:removeItem(targetMessage.itemId, 1) then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, targetMessage.messages.failure, 10)
				return true
			end

			player:setStorageValue(targetMessage.storage, 2)
			player:setStorageValue(Storage.Quest.U8_6.AFathersBurden.Progress, player:getStorageValue(Storage.Quest.U8_6.AFathersBurden.Progress) + 1)
			player:addExperience(2500, true)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messages.success)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, targetMessage.messages.no, 10)
		end
		npcHandler:setTopic(playerId, 0)
	end
end
