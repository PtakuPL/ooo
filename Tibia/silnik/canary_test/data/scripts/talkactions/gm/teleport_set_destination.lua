-- Script for set teleport destination
-- /teleport xxxx, xxxx, x
local teleportSetDestination = TalkAction("/teleport", "/tp")

function teleportSetDestination.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local params = param:split(",")
	if params[3] then
		local position = player:getPosition()
		position:getNextPosition(player:getDirection(), 1)
		local destination = Position(params[1], params[2], params[3])
		if destination and destination:getTile() then
			local tp = Game.createItem(35502, 1, position)
			if tp then
				tp:setDestination(destination)
				player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.teleport_set_destination.msg_1", {param})
			end
		else
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.teleport.msg_invalid_destination")
		end
	else
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.teleport.msg_declare_xyz")
	end
	return true
end

teleportSetDestination:separator(" ")
teleportSetDestination:groupType("gamemaster")
teleportSetDestination:register()
