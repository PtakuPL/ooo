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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.add_bosstiary_kills.invalid_kill_count")
		return true
	end

	local target = targetName ~= "" and Player(targetName) or player
	if not target then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.add_bosstiary_kills.target_not_found")
		return true
	end

	if target == player then
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "god.add_bosstiary_kills.added_to_self", {tostring(kills), monsterName})
	else
		player:sendLocalizedTextMessage(MESSAGE_ADMINISTRATOR, "god.add_bosstiary_kills.added_to_player", {tostring(kills), monsterName, targetName})
		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.add_bosstiary_kills.received_kills", {tostring(kills), monsterName})
	end
	target:addBosstiaryKill(monsterName, kills)
	return true
end

talkaction:separator(" ")
talkaction:groupType("god")
talkaction:register()
