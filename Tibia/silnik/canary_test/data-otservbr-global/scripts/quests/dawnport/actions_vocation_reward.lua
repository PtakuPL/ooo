local adventurersGuildText = "#i18n:book.dawnport.adventurers_guild_letter"

local reward = {
	container = 2854,
	commonItems = {
		{ id = 16277, amount = 1 }, -- Adventurer's stone
		-- Parchment
		{ id = 2819, amount = 1, text = adventurersGuildText },
	},
	vocationItems = {
		-- Sorcerer
		[14025] = {
			{ id = 7992, amount = 1 }, -- Mage hat
			{ id = 7991, amount = 1 }, -- Magician's robe
			{ id = 3559, amount = 1 }, -- Leather legs
			{ id = 3552, amount = 1 }, -- Leather boots
			{ id = 3074, amount = 1 }, -- Wand of vortex
			{ id = 3059, amount = 1 }, -- Spellbook
		},
		-- Druid
		[14026] = {
			{ id = 7992, amount = 1 }, -- Mage hat
			{ id = 7991, amount = 1 }, -- Magician's robe
			{ id = 3559, amount = 1 }, -- Leather legs
			{ id = 3552, amount = 1 }, -- Leather boots
			{ id = 3066, amount = 1 }, -- Snakebite rod
			{ id = 3059, amount = 1 }, -- Spellbook
		},
		-- Paladin
		[14027] = {
			{ id = 3355, amount = 1 }, -- Leader helmet
			{ id = 3571, amount = 1 }, -- Ranger's cloak
			{ id = 8095, amount = 1 }, -- Ranger legs
			{ id = 3552, amount = 1 }, -- Leather boots
			{ id = 3350, amount = 1 }, -- Bow
			{ id = 3277, amount = 1 }, -- Spear
			{ id = 35562, amount = 1 }, -- Quiver
			{ id = 3447, amount = 100 }, -- Arrows
		},
		-- Knight
		[14028] = {
			{ id = 3375, amount = 1 }, -- Soldier helmet
			{ id = 3359, amount = 1 }, -- Brass armor
			{ id = 3372, amount = 1 }, -- Brass legs
			{ id = 3552, amount = 1 }, -- Leather boots
			{ id = 7774, amount = 1 }, -- Jagged sword
			{ id = 17824, amount = 1 }, -- Swampling club
			{ id = 7773, amount = 1 }, -- steel axe
			{ id = 3409, amount = 1 }, -- Steel shield
		},
	},
}

local vocationReward = Action()

function vocationReward.onUse(player, item, fromPosition, itemEx, toPosition)
	local vocationItems = reward.vocationItems[item.uid]
	-- Check there is items for item.uid
	if not vocationItems then
		return true
	end
	-- Check quest storage
	if player:getStorageValue(Storage.Quest.U10_55.Dawnport.VocationReward) == 1 then
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The " .. item:getName() .. " is empty.")
		return true
	end
	-- Calculate reward weight
	local rewardsWeight = ItemType(reward.container):getWeight()
	for i = 1, #vocationItems do
		rewardsWeight = rewardsWeight + (ItemType(vocationItems[i].id):getWeight() * vocationItems[i].amount)
	end
	for i = 1, #reward.commonItems do
		rewardsWeight = rewardsWeight + (ItemType(reward.commonItems[i].id):getWeight() * reward.commonItems[i].amount)
	end
	-- Check if enough weight capacity
	if player:getFreeCapacity() < rewardsWeight then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_vocation_reward.msg_1" .. getItemName(reward.container) .. ". Weighing " .. (rewardsWeight / 100) .. " oz it is too heavy.")
		return true
	end
	-- Check if enough free slots
	if player:getFreeBackpackSlots() < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_vocation_reward.msg_2" .. getItemName(reward.container) .. ". There is no room.")
		return true
	end
	-- Create reward container
	local container = Game.createItem(reward.container)
	-- Iterate in inverse order due on addItem/addItemEx by default its added at first index
	-- Add common items
	for i = #reward.commonItems, 1, -1 do
		if reward.commonItems[i].text then
			-- Create item to customize
			local document = Game.createItem(reward.commonItems[i].id)
			document:setAttribute(ITEM_ATTRIBUTE_TEXT, reward.commonItems[i].text)
			container:addItemEx(document)
		else
			container:addItem(reward.commonItems[i].id, reward.commonItems[i].amount)
		end
	end
	-- Add vocation items
	for i = #vocationItems, 1, -1 do
		container:addItem(vocationItems[i].id, vocationItems[i].amount)
	end
	-- Ensure reward was added properly to player
	if player:addItemEx(container, false, CONST_SLOT_WHEREEVER) == RETURNVALUE_NOERROR then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_vocation_reward.msg_3" .. container:getName() .. ".")
		player:setStorageValue(Storage.Quest.U10_55.Dawnport.VocationReward, 1)
	end
	return true
end

for index, value in pairs(reward.vocationItems) do
	vocationReward:uid(index)
end

vocationReward:register()
