local kick = TalkAction("/kick")

function kick.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local target = Player(param)
	if not target then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.player_not_found")
		return true
	end

	if target:getGroup():getAccess() then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.kick.cannot_kick")
		return true
	end

	Webhook.sendMessage("Player Kicked", target:getName() .. " has been kicked by " .. player:getName(), WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
	target:remove()
	return true
end

kick:separator(" ")
kick:groupType("gamemaster")
kick:register()
