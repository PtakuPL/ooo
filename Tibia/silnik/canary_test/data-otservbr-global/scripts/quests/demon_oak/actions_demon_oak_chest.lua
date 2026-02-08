local chests = {
	[1002] = { itemid = 3389, count = 1 },
	[1003] = { itemid = 8077, count = 1 },
	[1004] = { itemid = 14768, count = 1 },
	[1005] = { itemid = 14769, count = 1 },
}

local demonOakChest = Action()
function demonOakChest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if chests[item.uid] then
		if player:getStorageValue(Storage.Quest.U8_2.TheDemonOak.Done) ~= 2 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_demon_oak_chest.msg_1")
			return true
		end

		local chest = chests[item.uid]
		local itemType = ItemType(chest.itemid)
		if itemType then
			local article = itemType:getArticle()
			local rewardName = (#article > 0 and article .. " " or "") .. itemType:getName()
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_demon_oak_chest.msg_2", { rewardName })
		end

		player:addItem(chest.itemid, chest.count)
		player:setStorageValue(Storage.Quest.U8_2.TheDemonOak.Done, 3)
	end
	return true
end

for unique, itemInfo in pairs(chests) do
	demonOakChest:uid(unique)
end

demonOakChest:register()
