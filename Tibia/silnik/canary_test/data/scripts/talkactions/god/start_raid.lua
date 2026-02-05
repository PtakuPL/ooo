local startRaid = TalkAction("/raid")

function startRaid.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.param_required")
		return true
	end

	local returnValue = Game.startRaid(param)
	if returnValue ~= RETURNVALUE_NOERROR then
		player:sendTextMessage(MESSAGE_ADMINISTRATOR, Game.getReturnMessage(returnValue))
	else
		player:sendLocalizedMessage(MESSAGE_ADMINISTRATOR, "scripts.start_raid.msg_1")
	end
	return true
end

startRaid:separator(" ")
startRaid:groupType("god")
startRaid:register()
