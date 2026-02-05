local tutorPosition = TalkAction("!position")

function tutorPosition.onSay(player, words, param)
	local position = player:getPosition()
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkactions.player.tutor.position", {position.x, position.y, position.z})
	return true
end

tutorPosition:groupType("senior tutor")
tutorPosition:register()
