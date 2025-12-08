local questFirst = Action()

function questFirst.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 7 then
		player:addItem(3035, 10)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_questfirst.msg_1")
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 8)
		return true
	end
	return false
end

questFirst:uid(1105)
questFirst:register()
