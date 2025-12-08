local peelerfun = Action()

function peelerfun.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Eighth.Tefrit) == 2 then
		if table.contains({ 31376 }, target.itemid) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_peelerfun.msg_1")
			player:addItem(31329, 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "scripts.actions_peelerfun.msg_2")
	end

	return true
end

peelerfun:id(31328)
peelerfun:register()
