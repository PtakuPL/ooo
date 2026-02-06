local items = {
	{ description = "a platinum coins", items = { { id = ITEM_PLATINUM_COIN, count = 5 } } },
	{
		description = "some gems",
		items = {
			{ id = 3029, count = 1 },
			{ id = 3032, count = 1 },
			{ id = 3030, count = 1 },
		},
	},
	{ description = "a life ring", items = { { id = 3089, count = 1 } } },
	{ description = "a red gem", items = { { id = 3039, count = 1 } } },
	{ description = "a mana potion", items = { { id = 237, count = 10 } } },
	{ description = "a health potion", items = { { id = 236, count = 8 } } },
}

local adventurersTreasure = Action()

function adventurersTreasure.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.DragonCounter) >= 50 then
		local treasure = items[math.random(#items)]
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_treasure.msg_1", { treasure.description })
		for _, item in ipairs(treasure.items) do
			player:addItem(item.id, item.count)
		end

		player:setStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.DragonCounter, 0)

		local times = player:getStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.Achievement)
		if times < 0 then
			times = 0
		end
		times = times + 1
		player:setStorageValue(Storage.Quest.U10_80.TheGreatDragonHunt.Achievement, times)

		if times == 10 then
			player:addAchievement("Hoard of the Dragon")
		end
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_treasure.msg_2")
	end

	return true
end

adventurersTreasure:aid(50808)
adventurersTreasure:register()
