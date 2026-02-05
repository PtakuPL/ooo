local namelock = TalkAction("/namelock")

function namelock.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.param_required")
		return true
	end

	local name = param
	local reason = ""

	local separatorPos = param:find(",")
	if separatorPos then
		name = param:sub(0, separatorPos - 1)
		reason = string.trim(param:sub(separatorPos + 1))
	end

	if reason == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.must_specify_reason")
		return true
	end

	local target = Player(name)
	local online = true
	if not target then
		target = Game.getOfflinePlayer(name)
		online = false
	end
	if target and target:isPlayer() then
		target:kv():set("namelock", reason)
		local text = target:getName() .. " has been namelocked"
		logger.info(text .. ", reason: " .. reason)
		player:sendTextMessage(MESSAGE_ADMINISTRATOR, text)
		Webhook.sendMessage("Player Namelocked", text .. " reason: " .. reason .. ".", WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
		if online then
			CheckNamelock(target)
		end
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkactions.gm.common.player_not_found")
	end
end

namelock:separator(" ")
namelock:groupType("gamemaster")
namelock:register()
