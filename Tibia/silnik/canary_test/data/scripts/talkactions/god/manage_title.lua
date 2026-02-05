local addTitle = TalkAction("/addtitle")

function addTitle.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.title.msg_addtitle_usage")
		return true
	end

	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()
	local id = tonumber(split[2])
	if target:addTitle(id) then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_title.msg_2", {id, target:getName()})
		target:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_title.msg_1", {player:getName()})
	end

	return true
end

addTitle:separator(" ")
addTitle:groupType("god")
addTitle:register()

-----------------------------------------
local setTitle = TalkAction("/settitle")

function setTitle.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.title.msg_settitle_usage")
		return true
	end

	local target = Player(split[1])
	if not target then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_not_online")
		return true
	end

	split[2] = split[2]:trimSpace()
	local id = tonumber(split[2])
	target:setCurrentTitle(id)
	return true
end

setTitle:separator(" ")
setTitle:groupType("god")
setTitle:register()
