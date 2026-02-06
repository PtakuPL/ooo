local UniqueTable = {
	[14024] = {
		itemId = 6125,
		name = "tortoise egg from Nargor",
		count = 1,
	},
}

local tortoiseEggNargor = Action()

function tortoiseEggNargor.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local setting = UniqueTable[item.uid]
	if not setting then
		return true
	end

	if player:getStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorTime) < os.time() then
		player:addItem(setting.name, setting.count, true)
		player:setStorageValue(Storage.Quest.U7_8.TheShatteredIsles.TortoiseEggNargorTime, os.time() + 24 * 3600)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.shattered_isles.found_items", { setting.count, setting.name })
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.common.item_is_empty", { getItemName(setting.itemId) })
	end
	return true
end

tortoiseEggNargor:uid(14024)
tortoiseEggNargor:register()
