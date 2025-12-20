local statusTime = TalkAction("!time")
function statusTime.onSay(player, words, param)
	local formattedTime = getFormattedWorldTime(getWorldTime())
	local dayOrNight = getTibiaTimerDayOrNight(formattedTime)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.tibia_timer.msg_1", {dayOrNight, formattedTime})
	return true
end

statusTime:groupType("normal")
statusTime:register()
