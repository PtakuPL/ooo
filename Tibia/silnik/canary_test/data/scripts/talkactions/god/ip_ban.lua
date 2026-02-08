local ipBanDays = 7

local ipBan = TalkAction("/ipban")

function ipBan.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local resultId = db.storeQuery("SELECT `name`, `lastip` FROM `players` WHERE `name` = " .. db.escapeString(param))
	if resultId == false then
		return true
	end

	local targetName = Result.getString(resultId, "name")
	local targetIp = Result.getNumber(resultId, "lastip")
	Result.free(resultId)

	local targetPlayer = Player(param)
	if targetPlayer then
		targetIp = targetPlayer:getIp()
		targetPlayer:remove()
	end

	if targetIp == 0 then
		return true
	end

	resultId = db.storeQuery("SELECT 1 FROM `ip_bans` WHERE `ip` = " .. targetIp)
	if resultId ~= false then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.god.ip_ban.msg_already_banned", {targetName})
		Result.free(resultId)
		return true
	end

	local timeNow = os.time()
	db.query("INSERT INTO `ip_bans` (`ip`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (" .. targetIp .. ", '', " .. timeNow .. ", " .. timeNow + (ipBanDays * 86400) .. ", " .. player:getGuid() .. ")")
	player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.god.ip_ban.msg_banned", {targetName})
	return true
end

ipBan:separator(" ")
ipBan:groupType("god")
ipBan:register()
