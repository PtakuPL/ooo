local pickenchanted = Action()

function pickenchanted.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Eighth.Yonan) == 2 then
		if table.contains({ 30438 }, target.itemid) then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_pickenchanted.msg_1")
			player:addItem(31333, 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "scripts.actions_pickenchanted.msg_2")
	end

	return true
end

pickenchanted:id(31613)
pickenchanted:register()
