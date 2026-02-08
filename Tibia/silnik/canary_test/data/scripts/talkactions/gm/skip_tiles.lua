local skipTiles = TalkAction("/a")

function skipTiles.onSay(player, words, param)
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local steps = tonumber(param)
	if not steps then
		return true
	end

	local position = player:getPosition()
	position:getNextPosition(player:getDirection(), steps)

	position = player:getClosestFreePosition(position, false)
	if position.x == 0 then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.skip_tiles.msg_cannot_teleport")
		return true
	end

	player:teleportTo(position)
	return true
end

skipTiles:separator(" ")
skipTiles:groupType("gamemaster")
skipTiles:register()
