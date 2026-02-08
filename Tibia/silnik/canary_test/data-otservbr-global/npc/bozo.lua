local internalNpcName = "Bozo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 273,
	lookHead = 0,
	lookBody = 77,
	lookLegs = 80,
	lookFeet = 79,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.bozo.voice_1" },
	{ i18nKey = "npc.bozo.voice_2" },
	{ i18nKey = "npc.bozo.voice_3" },
	{ i18nKey = "npc.bozo.voice_4" },
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

local config = {
	[1] = {
		i18nKey = "npc.bozo.stdmod_81",
		yes = true,
		removeItem = { itemId = 102 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission1, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 2 },
		},
	},
	[2] = {
		i18nKey = "npc.bozo.stdmod_82",
		},
		addItem = { itemId = 135 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission2, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 3 },
		},
	},
	[3] = {
		i18nKey = "npc.bozo.stdmod_83",
		yes = true,
		removeItem = { itemId = 107 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission2, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 4 },
		},
	},
	[4] = {
		i18nKey = "npc.bozo.stdmod_84",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission3, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 5 },
		},
	},
	[5] = {
		i18nKey = "npc.bozo.stdmod_85",
		},
		yes = true,
		removeItem = { itemId = 119 },
		pie = true,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission3, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 6 },
		},
	},
	[6] = {
		i18nKey = "npc.bozo.stdmod_86",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission4, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 7 },
		},
	},
	[7] = {
		i18nKey = "npc.bozo.stdmod_87",
		},
		yes = true,
		removeItem = { itemId = 2874, count = 18, subType = 2 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission4, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 8 },
		},
		addItem = { itemId = 117 },
	},
	[8] = {
		i18nKey = "npc.bozo.stdmod_88",
		yes = true,
		removeItem = { itemId = 118 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission4, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 9 },
		},
	},
	[9] = {
		i18nKey = "npc.bozo.stdmod_89",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission5, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.TriangleTowerDoor, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 10 },
		},
	},
	[10] = {
		i18nKey = "npc.bozo.stdmod_90",
		},
		yes = true,
		checkItemCount = 112,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission5, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 11 },
		},
	},
	[11] = {
		i18nKey = "npc.bozo.stdmod_91",
		},
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.EmperorBeardShave,
		removeItem = { itemId = 113 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission5, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 12 },
		},
	},
	[12] = {
		i18nKey = "npc.bozo.stdmod_92",
	},
	[13] = {
		i18nKey = "npc.bozo.stdmod_93",
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission6, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 14 },
		},
	},
	[14] = {
		i18nKey = "npc.bozo.stdmod_94",
		yes = true,
		removeItem = { itemId = 5878, count = 4 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission6, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 15 },
		},
	},
	[15] = {
		i18nKey = "npc.bozo.stdmod_95",
		yes = true,
		removeItem = { itemId = 5879 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission6, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 16 },
		},
		effect = CONST_ME_POFF,
	},
	[16] = {
		i18nKey = "npc.bozo.stdmod_96",
		},
		addItem = { itemId = 121 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission6, value = 4 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 17 },
		},
	},
	[17] = {
		i18nKey = "npc.bozo.stdmod_97",
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.WhoopeeCushion,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission6, value = 5 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 18 },
		},
	},
	[18] = {
		i18nKey = "npc.bozo.stdmod_98",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission7, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.QueenEloiseCatDoor, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 19 },
		},
	},
	[19] = {
		i18nKey = "npc.bozo.stdmod_99",
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.ScaredCarina,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission7, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 20 },
		},
	},
	[20] = {
		i18nKey = "npc.bozo.stdmod_100",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission8, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 21 },
		},
	},
	[21] = {
		i18nKey = "npc.bozo.stdmod_101",
		yes = true,
		removeItem = { itemId = 124 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission8, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 22 },
		},
	},
	[22] = {
		i18nKey = "npc.bozo.stdmod_102",
		yes = true,
		removeItem = { itemId = 3129 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission8, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 23 },
		},
	},
	[23] = {
		i18nKey = "npc.bozo.stdmod_103",
		},
		addItem = { itemId = 141 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission8, value = 4 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 24 },
		},
	},
	[24] = {
		i18nKey = "npc.bozo.stdmod_104",
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.Cigar,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission8, value = 5 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 25 },
		},
		addItem = { itemId = 895 },
		addon = 1,
	},
	[25] = {
		i18nKey = "npc.bozo.stdmod_105",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission9, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 26 },
		},
		addItem = { itemId = 135 },
	},
	[26] = {
		i18nKey = "npc.bozo.stdmod_106",
		},
		yes = true,
		removeItem = { itemId = 125 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission9, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 27 },
		},
		addItem = { itemId = 135 },
	},
	[27] = {
		i18nKey = "npc.bozo.stdmod_107",
		yes = true,
		removeItem = { itemId = 9149 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission9, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 28 },
		},
	},
	[28] = {
		i18nKey = "npc.bozo.stdmod_108",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission9, value = 4 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 29 },
		},
		addItem = { itemId = 127 },
	},
	[29] = {
		i18nKey = "npc.bozo.stdmod_109",
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.Contract,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission9, value = 5 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 30 },
		},
	},
	[30] = {
		i18nKey = "npc.bozo.stdmod_110",
			[3] = {
				"npc.bozo.mission_30_t3_1",
				"npc.bozo.mission_30_t3_2",
				"npc.bozo.mission_30_t3_3",
				"npc.bozo.mission_30_t3_4",
				"npc.bozo.mission_30_t3_5",
			},
		},
		yes = true,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission10, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 31 },
		},
		addItem = { itemId = 130, count = 10 },
	},
	[31] = {
		i18nKey = "npc.bozo.stdmod_111",
		yes = true,
		cookiesDelivery = true,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission10, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 32 },
		},
	},
	[32] = {
		i18nKey = "npc.bozo.stdmod_112",
		},
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission11, value = 1 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 33 },
		},
	},
	[33] = {
		i18nKey = "npc.bozo.stdmod_113",
		},
		yes = true,
		removeItem = { itemId = 5909, count = 5 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission11, value = 2 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 34 },
		},
		addItem = { itemId = 142 },
	},
	[34] = {
		i18nKey = "npc.bozo.stdmod_114",
		},
		yes = true,
		removeItem = { itemId = 143 },
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission11, value = 3 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 35 },
		},
		addItem = { itemId = 144 },
	},
	[35] = {
		i18nKey = "npc.bozo.stdmod_115",
		yes = true,
		checkStorage = Storage.Quest.U8_1.WhatAFoolishQuest.ScaredKazzan,
		updateStorages = {
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Mission11, value = 4 },
			{ key = Storage.Quest.U8_1.WhatAFoolishQuest.Questline, value = 36 },
		},
		addItem = { itemId = 894 },
		addon = 2,
		last = true,
	},
	[36] = {
		i18nKey = "npc.bozo.stdmod_116",
	},
}

local jesterOutfit = {
	[-1] = {
		i18nKey = "npc.bozo.stdmod_117",
		removeItemId = 5911,
		newValue = 1,
		choice = 1,
	},
	[1] = {
		i18nKey = "npc.bozo.stdmod_118",
		removeItemId = 5912,
		newValue = 2,
		choice = 2,
	},
	[2] = {
		i18nKey = "npc.bozo.stdmod_119",
		removeItemId = 5910,
		newValue = 3,
		choice = 3,
	},
	[3] = {
		i18nKey = "npc.bozo.stdmod_120",
		removeItemId = 5914,
		newValue = 4,
		addOutfit = true,
		last = true,
	},
}

local value = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	if Player(creature):getSex() == PLAYERSEX_MALE then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.bozo.greet_msg_1")
	else
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.bozo.greet_msg_2")
	end
	value[playerId] = nil
	return true
end


local function sayBozoText(npcHandler, npc, creature, textValue)
	if type(textValue) == "table" then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, textValue)
	else
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, textValue)
	end
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) ~= -1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_1")
			return true
		end

		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_2")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") then
		local targetValue = config[player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline)]
		if not targetValue then
			return true
		end

		if not targetValue.yes then
			if targetValue.updateStorages then
				for i = 1, #targetValue.updateStorages do
					local storage = targetValue.updateStorages[i]
					player:setStorageValue(storage.key, storage.value)
				end
			end

			if targetValue.addItem then
				player:addItem(targetValue.addItem.itemId, targetValue.addItem.count or 1)
			end
		end

		sayBozoText(npcHandler, npc, creature, targetValue.text[1])
		if targetValue.yes then
			npcHandler:setTopic(playerId, 3)
			value[playerId] = targetValue
		end
	elseif MsgContains(message, "jester outfit") then
		if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 12 then
			local targetValue = jesterOutfit[player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.JesterOutfit)]
			if not targetValue then
				return true
			end

			sayBozoText(npcHandler, npc, creature, targetValue.text[1])
			npcHandler:setTopic(playerId, 4)
			value[playerId] = targetValue
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_3")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_8")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_9")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_10")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline, 1)
			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questlog, 1)
			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Mission1, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_3")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_6")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_7")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 3 then
			local targetValue = value[playerId]
			if targetValue.checkStorage then
				if player:getStorageValue(targetValue.checkStorage) ~= 1 then
					sayBozoText(npcHandler, npc, creature, targetValue.text[2])
					npcHandler:setTopic(playerId, 0)
					return true
				end
			end

			if targetValue.removeItem then
				if not player:removeItem(targetValue.removeItem.itemId, targetValue.removeItem.count or 1, targetValue.removeItem.subType or -1) then
					sayBozoText(npcHandler, npc, creature, targetValue.text[2])
					npcHandler:setTopic(playerId, 0)
					return true
				end
			end

			if targetValue.checkItemCount then
				if player:getItemCount(targetValue.checkItemCount) == 0 then
					sayBozoText(npcHandler, npc, creature, targetValue.text[2])
					npcHandler:setTopic(playerId, 0)
					return true
				end
			end

			if targetValue.cookiesDelivery then
				if player:getCookiesDelivered() ~= 10 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_4")
					npcHandler:setTopic(playerId, 0)
					return true
				end
			end

			if targetValue.pie then
				if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer) > 0 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer) < os.time() then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_5")
					npcHandler:setTopic(playerId, 0)
					return true
				end
			end

			if targetValue.updateStorages then
				for i = 1, #targetValue.updateStorages do
					local storage = targetValue.updateStorages[i]
					player:setStorageValue(storage.key, storage.value)
				end
			end

			if targetValue.addItem then
				player:addItem(targetValue.addItem.itemId, targetValue.addItem.count or 1)
			end

			if targetValue.addon then
				player:addOutfitAddon(270, targetValue.addon)
				player:addOutfitAddon(273, targetValue.addon)
				player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			end

			if targetValue.effect then
				npc:getPosition():sendMagicEffect(targetValue.effect)
			end

			if targetValue.last then
				player:addAchievement("Perfect Fool")
				player:addAchievement("Fool at Heart")
			end

			sayBozoText(npcHandler, npc, creature, targetValue.text[3])
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			local targetValue = value[playerId]
			if not player:removeItem(targetValue.removeItemId, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_6")
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.JesterOutfit, targetValue.newValue)
			if targetValue.addOutfit then
				player:addOutfit(270)
				player:addOutfit(273)
				player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline, 13)
			end
			sayBozoText(npcHandler, npc, creature, targetValue.text[2])
			if not targetValue.last then
				value[playerId] = jesterOutfit[targetValue.choice]
			else
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "no") and npcHandler:getTopic(playerId) ~= 0 then
		if table.contains({ 1, 2 }, npcHandler:getTopic(playerId)) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_7")
		elseif table.contains({ 3, 4 }, npcHandler:getTopic(playerId)) then
			if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 11 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.EmperorBeardShave) == 1 then
				player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline, 12)
				player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Mission5, 3)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.multi_2")
			elseif player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 30 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_8")
			elseif player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.Questline) == 35 and player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.LostDisguise) ~= 1 then
				player:addItem(144, 1)
				player:setStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.LostDisguise, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.bozo.say_10")
			end
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_1" }, function(player)
	return player:isSorcerer()
end)
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_2" }, function(player)
	return player:isDruid()
end)
keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_3" }, function(player)
	return player:isPaladin()
end)
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_4" }, function(player)
	return player:isKnight()
end)
keywordHandler:addKeyword({ "sorcerer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_5" })
keywordHandler:addKeyword({ "druid" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_6" })
keywordHandler:addKeyword({ "paladin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_7" })
keywordHandler:addKeyword({ "knight" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_8" })

keywordHandler:addKeyword({ "here" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_9" })
keywordHandler:addKeyword({ "king" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_10" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_11" })
keywordHandler:addKeyword({ "castle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_12" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_13" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_14" })
keywordHandler:addKeyword({ "bozo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_15" })
keywordHandler:addKeyword({ "guild" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_16" })
keywordHandler:addKeyword({ "sell" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_17" })
keywordHandler:addKeyword({ "joke" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_18" })
keywordHandler:addKeyword({ "news" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_19" })
keywordHandler:addKeyword({ "how", "are", "you" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_20" })
keywordHandler:addKeyword({ "necromant", "nectar" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_21" })
keywordHandler:addKeyword({ "necromant" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_22" })
keywordHandler:addKeyword({ "dog" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_23" })
keywordHandler:addKeyword({ "poodle" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_24" })
keywordHandler:addKeyword({ "noodles" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_25" })
keywordHandler:addKeyword({ "muriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_26" })
keywordHandler:addKeyword({ "elane" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_27" })
keywordHandler:addKeyword({ "marvik" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_28" })
keywordHandler:addKeyword({ "gregor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_29" })
keywordHandler:addKeyword({ "quentin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_30" })
keywordHandler:addKeyword({ "gorn" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_31" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_32" })
keywordHandler:addKeyword({ "sam" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_33" })
keywordHandler:addKeyword({ "benjamin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_34" })
keywordHandler:addKeyword({ "monster" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_35" })
keywordHandler:addKeyword({ "demon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_36" })
keywordHandler:addKeyword({ "ghoul" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_37" })
keywordHandler:addKeyword({ "dragon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_38" })
keywordHandler:addKeyword({ "orc" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_39" })
keywordHandler:addKeyword({ "cyclops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_40" })
keywordHandler:addKeyword({ "oswald" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_41" })
keywordHandler:addKeyword({ "dungeon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_42" })
keywordHandler:addKeyword({ "mino" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_43" })
keywordHandler:addKeyword({ "troll" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_44" })
keywordHandler:addKeyword({ "bonelord" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_45" })
keywordHandler:addKeyword({ "rat" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_46" })
keywordHandler:addKeyword({ "spider" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_47" })
keywordHandler:addKeyword({ "hugo" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_48" })
keywordHandler:addKeyword({ "cousin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_49" })
keywordHandler:addKeyword({ "durin" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_50" })
keywordHandler:addKeyword({ "stephan" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_51" })
keywordHandler:addKeyword({ "steve" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_52" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_53" })
keywordHandler:addKeyword({ "wall", "carving" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_54" })
keywordHandler:addKeyword({ "demon", "carving" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_55" })
keywordHandler:addKeyword({ "flaming", "pit" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_56" })

local jobKeyword = keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_57" })
jobKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_58", reset = true }, function(player)
	return player:getMoney() < 50
end)
jobKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_59", reset = true }, nil, function(player)
	if player:removeMoneyBank(50) then
	end
end)
jobKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_60", reset = true })

local magicKeyword = keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_61" })
magicKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_62", reset = true }, function(player)
	return player:getMoney() < 200
end)
magicKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_63", reset = true }, nil, function(player)
	if player:removeMoneyBank(200) then
	end
end)
magicKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_64", reset = true })
keywordHandler:addAliasKeyword({ "spell" })

local weaponKeyword = keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_65" })
weaponKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_66", reset = true }, function(player)
	return player:getMoney() < 250
end)
weaponKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_67", reset = true }, nil, function(player)
	if player:removeMoneyBank(250) then
		player:addItem(3473, 1)
	end
end)
weaponKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_68", reset = true })

keywordHandler:addKeyword({ "kiss" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_69", ungreet = true }, function(player)
	return player:getSex() == PLAYERSEX_MALE
end)

local kissKeyword = keywordHandler:addKeyword({ "kiss" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_70" })
kissKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_71", reset = true }, nil, function(player)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
end)
kissKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_72", reset = true })

keywordHandler:addKeyword({ "lady" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_73" }, function(player)
	return player:getSex() == PLAYERSEX_MALE
end)

local ladyKeyword = keywordHandler:addKeyword({ "lady" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_74" })
ladyKeyword:addChildKeyword({ "yes" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_75", reset = true })
ladyKeyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.bozo.stdmod_76", reset = true })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.bozo.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.bozo.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
