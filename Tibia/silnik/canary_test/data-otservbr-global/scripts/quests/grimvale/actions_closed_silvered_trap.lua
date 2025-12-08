local grimValeClosed = Action()
function grimValeClosed.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if toPosition.x == CONTAINER_POSITION then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_closed_silvered_trap.msg_1")
		return true
	end
	if player:getPosition():getDistance(Position(33390, 31540, 11)) >= 30 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_closed_silvered_trap.msg_2")
		return true
	end
	item:transform(22059)
	item:decay()
	toPosition:sendMagicEffect(CONST_ME_POFF)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_closed_silvered_trap.msg_3")
	return true
end

grimValeClosed:id(22074)
grimValeClosed:register()
