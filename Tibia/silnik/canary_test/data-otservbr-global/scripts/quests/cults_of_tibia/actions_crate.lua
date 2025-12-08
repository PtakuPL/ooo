local cultsOfTibiaCrate = Action()
function cultsOfTibiaCrate.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local posCrate = Position(33300, 32277, 12)
	-- Document
	if item:getPosition() == posCrate then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) == 7 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crate.msg_1")
			player:addItem(25306, 1)
			player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission, 8)
		elseif player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.MotA.Mission) > 7 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crate.msg_2")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crate.msg_3")
		end
	end
	return true
end

cultsOfTibiaCrate:aid(5523)
cultsOfTibiaCrate:register()
