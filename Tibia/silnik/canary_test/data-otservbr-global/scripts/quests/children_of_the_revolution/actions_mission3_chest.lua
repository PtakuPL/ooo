local childrenMission3 = Action()

function childrenMission3.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline) == 9 then
		player:setStorageValue(Storage.Quest.U8_54.ChildrenOfTheRevolution.Questline, 10)
		player:addItem(10183, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mission3_chest.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mission3_chest.msg_2")
	end

	return true
end

childrenMission3:uid(3164)
childrenMission3:register()
