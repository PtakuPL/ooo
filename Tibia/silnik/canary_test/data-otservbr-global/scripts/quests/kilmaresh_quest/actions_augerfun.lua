local augerfun = Action()

function augerfun.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Eighth.Narsai) == 2 then
		if table.contains({ 31377 }, target.itemid) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_augerfun.msg_1")
			player:addItem(31335, 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "scripts.actions_augerfun.msg_2")
	end

	return true
end

augerfun:id(31334)
augerfun:register()
