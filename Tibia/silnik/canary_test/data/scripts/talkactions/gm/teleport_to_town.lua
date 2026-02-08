local teleportToTown = TalkAction("/town")

function teleportToTown.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local town = Town(param) or Town(tonumber(param))
	if town then
		player:teleportTo(town:getTemplePosition())
	else
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.teleport.msg_town_not_found")
	end
	return true
end

teleportToTown:separator(" ")
teleportToTown:groupType("gamemaster")
teleportToTown:register()
