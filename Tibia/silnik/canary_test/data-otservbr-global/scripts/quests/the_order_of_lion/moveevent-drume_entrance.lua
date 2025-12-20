local drumeEntrance = MoveEvent()
function drumeEntrance.onStepIn(creature, item, position, fromPosition)
	if creature:isPlayer() and not creature:canFightBoss("Drume") then
		creature:teleportTo(fromPosition, true)
		creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.moveevent_drume_entrance.msg_1")
	end
	return true
end

drumeEntrance:aid(59601)
drumeEntrance:register()
