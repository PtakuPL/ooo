local ban = TalkAction("/ban")

function ban.onSay(player, words, param)
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.usage")
		return true
	end

	local name, daysStr, reason = param:match("^%s*([^,]+)%s*,%s*([^,]+)%s*,?%s*(.*)$")
	if not name or not daysStr then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.invalid_format")
		return true
	end

	local banDays = tonumber(daysStr)
	if not banDays or banDays <= 0 then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.invalid_days")
		return true
	end

	if banDays > 350000 then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.duration_too_long")
		return true
	end

	local accountId = Game.getPlayerAccountId(name)
	if accountId == 0 then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.common.player_not_found")
		return true
	end

	local timeNow = os.time()
	local expiresAt = timeNow + (banDays * 86400)

	local resultId = db.storeQuery("SELECT `expires_at` FROM `account_bans` WHERE `account_id` = " .. accountId)
	if resultId then
		local currentExpires = result.getNumber(resultId, "expires_at")
		Result.free(resultId)
		if expiresAt > currentExpires then
			db.query("UPDATE `account_bans` SET `reason` = " .. db.escapeString(reason or "") .. ", `expires_at` = " .. expiresAt .. ", `banned_by` = " .. player:getGuid() .. " WHERE `account_id` = " .. accountId)
			player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkactions.gm.ban.extended", {name, tostring(banDays)})
		else
			player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.gm.ban.already_banned_longer")
		end
		return true
	else
		db.query("INSERT INTO `account_bans` (`account_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" .. accountId .. ", " .. db.escapeString(reason or "") .. ", " .. timeNow .. ", " .. expiresAt .. ", " .. player:getGuid() .. ")")
	end

	local target = Player(name)
	local text = name .. " has been banned for " .. banDays .. " days."
	if target then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkactions.gm.ban.banned_for_days", {name, tostring(banDays)})
		Webhook.sendMessage("Player Banned", text .. " Reason: " .. (reason or "Not provided") .. ". (by: " .. player:getName() .. ")", WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
		target:remove()
		local banGlobalMessage = "Player " .. text .. " (by: " .. player:getName() .. "), Reason: " .. (reason or "Not provided")
		logger.info(banGlobalMessage)
		Broadcast(banGlobalMessage)
	else
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkactions.gm.ban.banned_for_days", {name, tostring(banDays)})
	end

	return true
end

ban:separator(" ")
ban:groupType("gamemaster")
ban:register()
