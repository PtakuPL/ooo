local teleportToTown = TalkAction("/town")

function teleportToTown.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.param_required")
		return true
	end

	local town = Town(param) or Town(tonumber(param))
	if town then
		player:teleportTo(town:getTemplePosition())
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.town_not_found")
	end
	return true
end

teleportToTown:separator(" ")
teleportToTown:groupType("gamemaster")
teleportToTown:register()
