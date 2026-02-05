local watch = Action()

function watch.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.watch.msg_1" .. getFormattedWorldTime() .. ".")
	return true
end

watch:id(2445, 2446, 2447, 2448, 2906, 2771, 6091)
watch:register()
