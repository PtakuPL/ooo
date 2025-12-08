local dangerousDepthItems = Action()

function dangerousDepthItems.onUse(player, item)
	if item.uid == 57235 then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartPaper) == 1 then
			player:addItem(27308, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnome_items.msg_1")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartPaper, 2)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartPaper) == 2 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnome_items.msg_2")
		end
	elseif item.uid == 57236 then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartChest) == 1 then
			player:addItem(27307, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnome_items.msg_3")
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartChest, 2)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.GnomeChartChest) == 2 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnome_items.msg_4")
		end
	end

	return true
end

dangerousDepthItems:uid(57235, 57236)
dangerousDepthItems:register()
