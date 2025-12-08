local glasshoneyfun = Action()

function glasshoneyfun.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Eighth.Narsai) == 2 then
		if table.contains({ 31376 }, target.itemid) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_glasshoneyfun.msg_1")
			player:removeItem(31331, 1)
			player:addItem(31332, 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "scripts.actions_glasshoneyfun.msg_2")
	end

	return true
end

glasshoneyfun:id(31331)
glasshoneyfun:register()
