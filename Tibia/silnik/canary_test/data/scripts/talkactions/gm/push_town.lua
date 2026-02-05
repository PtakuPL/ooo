local pushTown = TalkAction("/t")

function pushTown.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:teleportTo(player:getTown():getTemplePosition())
	else
		local targetPlayer = Player(param)
		if not targetPlayer then
			player:sendCancelMessage("A player with that name is not online.")
			return true
		end
		player:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.push_town.msg_1" .. targetPlayer:getName() .. " to temple.")
		targetPlayer:teleportTo(targetPlayer:getTown():getTemplePosition())
		targetPlayer:sendLocalizedTextMessage(MESSAGE_STATUS, "scripts.talkactions.gm.push_town_1")
		targetPlayer:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
		local text = "Player " .. targetPlayer:getName() .. " has been teleported to temple by " .. player:getName() .. "."
		logger.info("[pushTown.onSay] - {}", text)
		Webhook.sendMessage("Player Teleported", text, WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
	end
	return true
end

pushTown:separator(" ")
pushTown:groupType("gamemaster")
pushTown:register()
