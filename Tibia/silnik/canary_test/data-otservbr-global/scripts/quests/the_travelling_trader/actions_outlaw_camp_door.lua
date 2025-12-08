local outlawCamp = Action()
function outlawCamp.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_1.TheTravellingTrader.Mission02) == 3 then
		if item.itemid == 1642 then
			player:teleportTo(toPosition, true)
			item:transform(item.itemid + 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_outlaw_camp_door.msg_1")
	end
	return true
end

outlawCamp:aid(1108)
outlawCamp:register()
