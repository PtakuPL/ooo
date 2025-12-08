local chest = Action()

function chest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(405492) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.chest.msg_1")
		return true
	end

	player:addItem(12673, 1)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.chest.msg_2")
	player:setStorageValue(405492, 1)
	return true
end

chest:aid(30492)
chest:register()
