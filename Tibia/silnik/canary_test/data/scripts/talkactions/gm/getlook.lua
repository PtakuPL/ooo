local getlook = TalkAction("/getlook")

function getlook.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local creature = Creature(param)
	if not creature then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_creature_not_found_verbose")
		return true
	end

	local lookt = creature:getOutfit()
	player:sendLocalizedTextMessage(MESSAGE_HOTKEY_PRESSED, "talkaction.gm.getlook.msg_result", {
		tostring(lookt.lookType),
		tostring(lookt.lookHead),
		tostring(lookt.lookBody),
		tostring(lookt.lookLegs),
		tostring(lookt.lookFeet),
		tostring(lookt.lookAddons),
		tostring(lookt.lookMount),
	})
	return true
end

getlook:separator(" ")
getlook:groupType("gamemaster")
getlook:register()
