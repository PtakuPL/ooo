local internalNpcName = "Gerimor"
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
	lookHead = 60,
	lookBody = 22,
	lookLegs = 24,
	lookFeet = 32,
	lookAddons = 2,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gerimor.greet_msg_1")
	end

	return true
end

-- Keywords
keywordHandler:addKeyword({ "place" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_1",
})

keywordHandler:addKeyword({ "me" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_10",
})

keywordHandler:addKeyword({ "circle" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_2",
})

keywordHandler:addKeyword({ "persons" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_11",
})

keywordHandler:addKeyword({ "approaches" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_3",
})

keywordHandler:addKeyword({ "dawn" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_12",
})

keywordHandler:addKeyword({ "guidance" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_13",
})

keywordHandler:addKeyword({ "direct" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_14",
})

keywordHandler:addKeyword({ "interfere" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_4",
})

keywordHandler:addKeyword({ "feyrist" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_5",
})

keywordHandler:addKeyword({ "fae" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_15",
})

keywordHandler:addKeyword({ "fauns" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_16",
})

keywordHandler:addKeyword({ "pixies" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_17",
})

keywordHandler:addKeyword({ "pookas" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_18",
})

keywordHandler:addKeyword({ "swan maidens" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_19",
})

keywordHandler:addKeyword({ "nymphs" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_20",
})

keywordHandler:addKeyword({ "boogies" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_21",
})

keywordHandler:addKeyword({ "maelyrra" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_22",
})

keywordHandler:addKeyword({ "fae court" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_23",
})

keywordHandler:addKeyword({ "cults" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_24",
})

keywordHandler:addKeyword({ "worst" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_25",
})

keywordHandler:addKeyword({ "investigate" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_6",
})
keywordHandler:addKeyword({ "actions" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_7",
})
keywordHandler:addKeyword({ "fabric" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_8",
})

keywordHandler:addKeyword({ "works" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_26",
})

keywordHandler:addKeyword({ "ties" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.gerimor.stdmod_9",
})

local config = {
	missions = {
		["minotaurs"] = {
			textKey = {
				"npc.gerimor.minotaurs_text_1",
				"npc.gerimor.minotaurs_text_2",
			},
			completeTextKey = {
				"npc.gerimor.minotaurs_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Minotaurs.Mission,
			value = 5,
			rewardExp = 25000,
		},
		["prosperity"] = {
			textKey = {
				"npc.gerimor.prosperity_text_1",
				"npc.gerimor.prosperity_text_2",
			},
			completeTextKey = {
				"npc.gerimor.prosperity_complete_1",
				"npc.gerimor.prosperity_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.MotA.Mission,
			value = 14,
			rewardExp = 50000,
		},
		["barkless"] = {
			textKey = {
				"npc.gerimor.barkless_text_1",
				"npc.gerimor.barkless_text_2",
			},
			completeTextKey = {
				"npc.gerimor.barkless_complete_1",
				"npc.gerimor.barkless_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission,
			value = 6,
			rewardExp = 50000,
		},
		["orcs"] = {
			textKey = {
				"npc.gerimor.orcs_text_1",
			},
			completeTextKey = {
				"npc.gerimor.orcs_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Orcs.Mission,
			value = 2,
			rewardExp = 25000,
		},
		["life"] = {
			textKey = {
				"npc.gerimor.life_text_1",
			},
			completeTextKey = {
				"npc.gerimor.life_complete_1",
				"npc.gerimor.life_complete_2",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Life.Mission,
			value = 9,
			rewardExp = 50000,
		},
		["misguided"] = {
			textKey = {
				"npc.gerimor.misguided_text_1",
				"npc.gerimor.misguided_text_2",
			},
			completeTextKey = {
				"npc.gerimor.misguided_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission,
			value = 4,
			rewardExp = 50000,
		},
		["humans"] = {
			textKey = {
				"npc.gerimor.humans_text_1",
				"npc.gerimor.humans_text_2",
			},
			completeTextKey = {
				"npc.gerimor.humans_complete_1",
			},
			storage = Storage.Quest.U11_40.CultsOfTibia.Humans.Mission,
			value = 2,
			rewardExp = 25000,
		},
	},
}

local storage = {}
local value = {}
local rewardExperience = {}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "missions") then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) > 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_1")
			npcHandler:setTopic(playerId, 0)
		elseif
			player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Minotaurs.Mission) == 6
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 10
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 15
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Barkless.Mission) == 7
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Misguided.Mission) == 5
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.Mission) == 3
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Humans.Mission) == 3
			and player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) < 2
		then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_4")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_5")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_6")
			npcHandler:setTopic(playerId, 0)
			if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) < 1 then
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission, 1)
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.AccessDoor, 1)
			end
		elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_2")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.multi_3")
			npcHandler:setTopic(playerId, 4)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		local missionsTable = config.missions[message:lower()]
		if missionsTable then
			storage[playerId] = missionsTable.storage
			value[playerId] = missionsTable.value
			rewardExperience[playerId] = missionsTable.rewardExp
			if player:getStorageValue(storage[playerId]) > 0 and player:getStorageValue(storage[playerId]) == value[playerId] then
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, missionsTable.completeTextKey, 4000)
				player:setStorageValue(storage[playerId], player:getStorageValue(storage[playerId]) + 1)
				player:addExperience(rewardExperience[playerId])
				player:sendLocalizedTextMessage(MESSAGE_EXPERIENCE, "npc.gerimor.gained_experience", {rewardExperience[playerId]})
				npcHandler:setTopic(playerId, 0)
			elseif player:getStorageValue(storage[playerId]) > 0 and player:getStorageValue(storage[playerId]) > value[playerId] then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_2")
				npcHandler:setTopic(playerId, 2)
			else
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, missionsTable.textKey, 4000)
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 3 then
			if player:getStorageValue(storage[playerId]) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_3")
				player:setStorageValue(storage[playerId], 1)
				if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline) < 1 then
					player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Questline, 1)
				end
				npcHandler:setTopic(playerId, 2)
			elseif player:getStorageValue(storage[playerId]) > 0 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_4")
				npcHandler:setTopic(playerId, 2)
			end
		elseif npcHandler:getTopic(playerId) == 4 then
			local vocationRewards = {
				[VOCATION.BASE_ID.SORCERER] = { itemId = 26190, itemName = "reflecting crown" },
				[VOCATION.BASE_ID.DRUID] = { itemId = 26187, itemName = "leaf crown" },
				[VOCATION.BASE_ID.PALADIN] = { itemId = 26189, itemName = "incandescent crown" },
				[VOCATION.BASE_ID.KNIGHT] = { itemId = 26188, itemName = "iron crown" },
			}
			local vocationId = player:getVocation():getBaseId()
			local reward = vocationRewards[vocationId]
			local item = ""
			if reward then
				player:addItem(reward.itemId)
				item = reward.itemName
			end
			player:addExperience(50000)
			player:addItem(26186)
			player:addAchievement("Corruption Contained")
			player:sendLocalizedTextMessage(MESSAGE_EXPERIENCE, "system.experience.gained", {"50000"})
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "system.item.received", {"mystery box"})
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "npc.gerimor.gained_item", {item})
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.FinalBoss.Mission, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gerimor.say_6")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.gerimor.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
