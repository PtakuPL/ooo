local gravediggerTincture = Action()
function gravediggerTincture.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.actionid ~= 4635 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission23) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission24) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission24, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_tincture.msg_1")
		item:remove()
	end
	return true
end

gravediggerTincture:id(18928)
gravediggerTincture:register()
