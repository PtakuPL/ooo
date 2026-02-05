local tutorPosition = TalkAction("!position")

function tutorPosition.onSay(player, words, param)
	local position = player:getPosition()
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.position.msg_position", {tostring(position.x), tostring(position.y), tostring(position.z)})
	return true
end

tutorPosition:groupType("senior tutor")
tutorPosition:register()
