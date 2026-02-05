local ghost = TalkAction("/ghost")

function ghost.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local position = player:getPosition()
	local isGhost = not player:isInGhostMode()

	player:setGhostMode(isGhost)
	if isGhost then
		player:sendLocalizedTextMessage(MESSAGE_HOTKEY_PRESSED, "scripts.ghost.msg_1")
		position:sendMagicEffect(CONST_ME_YALAHARIGHOST)
	else
		player:sendLocalizedTextMessage(MESSAGE_HOTKEY_PRESSED, "scripts.ghost.msg_2")
		position.x = position.x + 1
		position:sendMagicEffect(CONST_ME_SMOKE)
	end
	return true
end

ghost:separator(" ")
ghost:groupType("gamemaster")
ghost:register()
