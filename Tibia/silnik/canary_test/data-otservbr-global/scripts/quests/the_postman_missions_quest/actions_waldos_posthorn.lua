local postmanWaldos = Action()
function postmanWaldos.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08) == 1 then
		player:setStorageValue(Storage.Quest.U7_24.ThePostmanMissions.Mission08, 2)
		player:addItem(3219, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_waldos_posthorn.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_waldos_posthorn.msg_2")
	end
	return true
end

postmanWaldos:uid(3118)
postmanWaldos:register()
