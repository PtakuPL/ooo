local boxRamp = Action()

function boxRamp.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 12 then
		player:removeItem(14165, 1)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_boxramp.msg_1")
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 13)
		return true
	end
	return false
end

boxRamp:uid(1106)
boxRamp:register()
