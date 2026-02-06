local config = {
	[24939] = { storage = Storage.Quest.U11_02.TheFirstDragon.Scale },
	[24940] = { storage = Storage.Quest.U11_02.TheFirstDragon.Tooth },
	[24941] = { storage = Storage.Quest.U11_02.TheFirstDragon.Horn },
	[24942] = { storage = Storage.Quest.U11_02.TheFirstDragon.Bones },
}

local sacrificeItems = Action()

function sacrificeItems.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local setting = config[item.itemid]
	if not setting then
		return true
	end

	if player:getStorageValue(setting.storage) >= 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice_items.msg_1")
		return true
	end

	if player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.AccessCave) >= 4 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice_items.msg_2", { item:getName() })
		return true
	end

	if player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.AccessCave) < 0 then
		player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.AccessCave, 0)
	end
	local targetPosition = Position(33047, 32712, 3)
	if toPosition == targetPosition then
		local targetId = Tile(targetPosition):getItemById(25160)
		if targetId then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sacrifice_items.msg_3", { item:getName() })
			player:setStorageValue(Storage.Quest.U11_02.TheFirstDragon.AccessCave, player:getStorageValue(Storage.Quest.U11_02.TheFirstDragon.AccessCave) + 1)
			player:setStorageValue(setting.storage, 1)
			item:remove(1)
			return true
		end
	end
	return false
end

for itemId, itemInfo in pairs(config) do
	sacrificeItems:id(itemId)
end

sacrificeItems:register()
