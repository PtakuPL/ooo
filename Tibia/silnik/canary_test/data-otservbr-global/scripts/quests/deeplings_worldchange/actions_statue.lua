local statuegod = Action()
function statuegod.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 6 then
		if table.contains({ 13827 }, target.itemid) then
			player:removeItem(14018, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_statue.msg_1")
			player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 6)
		end
	end
	return true
end

statuegod:id(14018)
statuegod:register()
