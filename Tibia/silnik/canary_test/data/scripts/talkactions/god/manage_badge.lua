local addBadge = TalkAction("/addbadge")

function addBadge.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.manage_badge.msg_insufficient")
		return true
	end

	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()
	local id = tonumber(split[2])
	if target:addBadge(id) then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_badge.msg_2", {id, target:getName()})
		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_badge.msg_1", {player:getName()})
	end
	return true
end

addBadge:separator(" ")
addBadge:groupType("god")
addBadge:register()
