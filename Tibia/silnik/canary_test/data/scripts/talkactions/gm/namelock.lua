local namelock = TalkAction("/namelock")

function namelock.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
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
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.namelock.msg_reason_required")
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
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.gm.namelock.msg_namelocked", {target:getName()})
		Webhook.sendMessage("Player Namelocked", text .. " reason: " .. reason .. ".", WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
		if online then
			CheckNamelock(target)
		end
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.gm.namelock.msg_not_found", {name})
	end
end

namelock:separator(" ")
namelock:groupType("gamemaster")
namelock:register()
