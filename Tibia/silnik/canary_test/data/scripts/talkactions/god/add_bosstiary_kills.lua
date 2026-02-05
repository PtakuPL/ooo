local talkaction = TalkAction("/addbosskill")

function talkaction.onSay(player, words, param)
	local usage = "Usage: /addbosskill <kills>,<monster name>,<optional target name>"
	if not HasValidTalkActionParams(player, param, usage) then
		return false
	end

	local split = param:split(",")
	local kills = tonumber(split[1])
	local monsterName = string.capitalize(string.trimSpace(tostring(split[2])))
	local targetName = string.capitalize(string.trimSpace(tostring(split[3])))

	if not kills or kills < 1 then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.bosstiary.msg_invalid_kills")
		return true
	end

	local target = targetName ~= "" and Player(targetName) or player
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.bosstiary.msg_target_not_found")
		return true
	end

	local message = "Added received kills: " .. kills .. ", for boss: " .. monsterName
	if target == player then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.god.bosstiary.msg_to_self", {kills, monsterName})
	else
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "talkaction.god.bosstiary.msg_to_player", {kills, monsterName, targetName})
		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.bosstiary.msg_target_received", {kills, monsterName})
	end
	target:addBosstiaryKill(monsterName, kills)
	return true
end

talkaction:separator(" ")
talkaction:groupType("god")
talkaction:register()
