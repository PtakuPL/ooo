local TheNewFrontier = Storage.Quest.U8_54.TheNewFrontier

local childrenZalamon = Action()

function childrenZalamon.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(TheNewFrontier.Mission08) >= 2 and player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission11) < 2 then
		if item.itemid == 9874 then
			player:teleportTo(toPosition, true)
			item:transform(item.itemid + 1)
		end
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_zalamon_door.msg_1")
	end
	return true
end

childrenZalamon:uid(3170)
childrenZalamon:register()
