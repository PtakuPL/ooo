local config = {
	[2285] = { -- The Djinn War Quest - lamp
		items = {
			{ itemId = 3243 },
		},
		storage = Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission03,
		formerValue = 1,
		newValue = 2,
		needItem = { itemId = 3231 },
		effect = CONST_ME_MAGIC_BLUE,
	},
	[3018] = {
		items = {
			{ itemId = 3219 },
		},
		storage = Storage.Quest.U7_24.ThePostmanMissions.Mission08,
		formerValue = 1,
		newValue = 2,
	},
	[3020] = {
		items = {
			{ itemId = 145 },
		},
		storage = Storage.Quest.U8_1.TheTravellingTrader.Mission02,
		formerValue = 3,
		newValue = 4,
	},
	[3024] = {
		items = {
			{ itemId = 3243 },
		},
		storage = Storage.Quest.U7_4.DjinnWar.MaridFaction.Mission03,
		formerValue = 1,
		newValue = 2,
		needItem = { itemId = 3231 },
		effect = CONST_ME_MAGIC_RED,
	},
	[3084] = {
		items = {
			{ itemId = 8829 },
		},
		storage = Storage.Quest.U8_4.InServiceOfYalahar.MatrixReward,
	},
	[3085] = {
		items = {
			{ itemId = 8828 },
		},
		storage = Storage.Quest.U8_4.InServiceOfYalahar.MatrixReward,
	},
	[3112] = {
		items = {
			{ itemId = 2820, text = "#i18n:book.quest_system2.the_paper_is_old_and_tattered" },
		},
		storage = Storage.Quest.U8_0.TheIceIslands.Questline,
		formerValue = 35,
		newValue = 36,
		missionStorage = { key = Storage.Quest.U8_0.TheIceIslands.Mission09, value = 2 },
	},
	[3116] = {
		items = {
			{ itemId = 3217 },
		},
		storage = Storage.Quest.U7_24.ThePostmanMissions.Mission09,
		formerValue = 1,
		newValue = 2,
	},
	[3120] = {
		items = {
			{ itemId = 3218 },
		},
		storage = Storage.Quest.U7_24.ThePostmanMissions.Mission05,
		formerValue = 1,
		newValue = 2,
	},
	[3162] = {
		items = {
			{ itemId = 637 },
		},
		storage = Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline,
		formerValue = 1,
		newValue = 2,
		say = "quests.quest_system2.say_1",
		effect = CONST_ME_POFF,
	},
	[4010] = {
		items = {
			{ itemId = 4832 },
		},
		storage = Storage.Quest.U7_6.TheApeCity.HolyApeHair,
	},
	[9136] = {
		items = {
			{ itemId = 2972, actionId = 3980 },
		},
		storage = Storage.Quest.U5_0.DeeperFibulaKey,
	},
	[9226] = {
		items = {
			{ itemId = 3397 },
		},
		storage = Storage.Quest.U7_5.SamsOldBackpack.SamsOldBackpackNpc,
		formerValue = 2,
		newValue = 3,
	},
	-- Hydra Egg Quest
	[9255] = {
		items = {
			{ itemId = 4839 },
		},
		storage = Storage.Quest.U7_6.HydraEggQuest,
	},
	[9256] = {
		items = {
			{ itemId = 4829, decay = true },
		},
		storage = Storage.Quest.U7_6.TheApeCity.WitchesCapSpot,
		time = true,
	},
	[9259] = {
		items = {
			{ itemId = 10159 },
		},
		storage = Storage.Quest.U8_54.UnnaturalSelection.Mission01,
		formerValue = 1,
		newValue = 2,
		say = "quests.quest_system2.say_2",
	},
	[9266] = {
		items = {
			{ itemId = 7936 },
		},
		storage = Storage.Quest.U8_2.TheThievesGuildQuest.Mission06,
		formerValue = 2,
		newValue = 3,
		say = "quests.quest_system2.say_3",
	},
	[9277] = {
		items = {
			{ itemId = 652 },
		},
		storage = Storage.Quest.U8_1.SecretService.RottenTree,
	},
	[50112] = {
		items = {
			{ itemId = 3725, count = 10 },
		},
		storage = Storage.Quest.U8_4.TheHiddenCityOfBeregar.BrownMushrooms,
	},
	[50125] = {
		items = {
			{ itemId = 8777 },
		},
		storage = Storage.Quest.U8_4.TheHiddenCityOfBeregar.JusticeForAll,
		formerValue = 3,
		newValue = 4,
	},
	[65201] = {
		items = {
			{ itemId = 2968, actionId = 3980 },
		},
		storage = 857440,
	},
	[65207] = {
		items = {
			{ itemId = 3551, count = 1 },
		},
		storage = 857445,
	},
	[65208] = {
		items = {
			{ itemId = 3377, count = 1 },
		},
		storage = 857446,
	},
	[65210] = {
		items = {
			{ itemId = 3147, count = 3 },
		},
		storage = 857448,
	},
	[14037] = {
		items = {
			{
				itemId = 2820,
				text = "#i18n:book.quest_system2.history_of_the_augur_part_ii",
				name = "History of the Augur, Part II",
			},
			{
				itemId = 2820,
				text = "#i18n:book.quest_system2.history_of_the_augur_part_i",
				name = "History of the Augur, Part I",
			},
		},
		storage = Storage.Quest.U8_4.InServiceOfYalahar.NotesPalimuth,
		formerValue = 0,
		newValue = 1,
	},
	[14038] = {
		items = {
			{
				itemId = 2820,
				text = "#i18n:book.quest_system2.manifest_of_the_yalahari_part_ii",
				name = "Manifest of the Yalahari, Part II",
			},
			{
				itemId = 2820,
				text = "#i18n:book.quest_system2.manifest_of_the_yalahari_part_i",
				name = "Manifest of the Yalahari, Part I",
			},
		},
		storage = Storage.Quest.U8_4.InServiceOfYalahar.NotesAzerus,
		formerValue = 0,
		newValue = 1,
	},
	[14039] = {
		items = {
			{ itemId = 8818 },
		},
		storage = Storage.Quest.U8_4.InServiceOfYalahar.AlchemistFormula,
		formerValue = 0,
		newValue = 1,
	},
	[14040] = {
		items = {
			{
				itemId = 2832,
				text = "#i18n:book.quest_system2.tunnelling_guide",
				name = "Tunnelling Guide",
			},
		},
		storage = Storage.Quest.U8_4.TheHiddenCityOfBeregar.TunnellingGuide,
	},
	[20003] = {
		items = {
			{
				itemId = 2822,
				text = "#i18n:book.quest_system2.the_map_shows_the_original_floor",
			},
		},
		storage = Storage.Quest.U8_0.TheIceIslands.FormorgarMinesHoistSkeleton,
	},
	[14041] = {
		items = {
			{
				itemId = 28461,
				text = "#i18n:book.quest_system2.this_page_seems_to_be_part",
				name = "Falcon Bastion Access",
			},
		},
		storage = Storage.Quest.U11_80.TheSecretLibrary.FalconBastion.FalconBastionAccess,
	},
	[20002] = {
		items = {
			{
				itemId = 21413,
				text = "#i18n:book.quest_system2.still_it_is_hard_to_believe",
			},
		},
		storage = Storage.Quest.U10_70.LionsRock.OuterSanctum.Skeleton,
	},
	-- 65203 reservado
}

local questSystem2 = Action()

function questSystem2.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local useItem = config[item.uid]
	if not useItem then
		return true
	end

	if (useItem.time and player:getStorageValue(useItem.storage) > os.time()) or player:getStorageValue(useItem.storage) ~= (useItem.formerValue or -1) then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.item_is_empty", { ItemType(item.itemid):getName() })
		return true
	end

	if useItem.needItem then
		if player:getItemCount(useItem.needItem.itemId) < (useItem.needItem.count or 1) then
			return false
		end
	end

	local items, reward = useItem.items
	local size = #items
	if size == 1 then
		reward = Game.createItem(items[1].itemId, items[1].count or 1)
	end

	local result = ""
	if reward then
		local ret = ItemType(reward.itemid)
		if ret:isRune() then
			result = ret:getArticle() .. " " .. ret:getName() .. " (" .. reward.type .. " charges)"
		elseif reward:getCount() > 1 then
			result = reward:getCount() .. " " .. ret:getPluralName()
		elseif ret:getArticle() ~= "" then
			result = ret:getArticle() .. " " .. ret:getName()
		else
			result = ret:getName()
		end

		if items[1].actionId then
			reward:setActionId(items[1].actionId)
		end

		if items[1].text then
			reward:setText(items[1].text)
		end

		if items[1].name then
			reward:setName(items[1].name)
		end

		if items[1].decay then
			reward:decay()
		end
	else
		if size > 8 then
			reward = Game.createItem(2854, 1)
		else
			reward = Game.createItem(2853, 1)
		end

		for i = 1, size do
			local tmp = Game.createItem(items[i].itemId, items[i].count or 1)
			if reward:addItemEx(tmp) ~= RETURNVALUE_NOERROR then
				logger.warn("[questSystem2.onUse] - Could not add quest reward to container")
			else
				if items[i].actionId then
					tmp:setActionId(items[i].actionId)
				end

				if items[i].text then
					tmp:setText(items[i].text)
				end

				if items[i].name then
					tmp:setName(items[i].name)
				end

				if items[i].decay then
					tmp:decay()
				end
			end
		end
		local ret = ItemType(reward.itemid)
		result = ret:getArticle() .. " " .. ret:getName()
	end

	if player:addItemEx(reward) ~= RETURNVALUE_NOERROR then
		local weight = reward:getWeight()
		if player:getFreeCapacity() < weight then
			player:sendLocalizedCancelMessage("quests.common.found_item_too_heavy_v2", { result, string.format("%.2f", weight / 100) })
		else
			player:sendLocalizedCancelMessage("quests.common.found_item_no_room", { result })
		end
		return true
	end

	if useItem.say then
		player:sayLocalized(useItem.say, TALKTYPE_MONSTER_SAY)
	end

	if useItem.needItem then
		player:removeItem(useItem.needItem.itemId, useItem.needItem.count or 1)
	end

	if useItem.effect then
		toPosition:sendMagicEffect(useItem.effect)
	end

	if useItem.missionStorage then
		player:setStorageValue(useItem.missionStorage.key, useItem.missionStorage.value)
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.found_item", { result })
	if useItem.time then
		player:setStorageValue(useItem.storage, os.time() + 86400)
	else
		player:setStorageValue(useItem.storage, useItem.newValue or 1)
	end
	return true
end

questSystem2:aid(2001)
questSystem2:register()
