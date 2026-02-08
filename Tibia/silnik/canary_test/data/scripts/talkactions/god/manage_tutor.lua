local addTutor = TalkAction("/addtutor")

function addTutor.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_param_required_dot")
		-- Distro log
		logger.error("[addTutor.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_is_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[addTutor.onSay] - Player {} is not online", string.titleCase(name))
		return true
	end

	if targetPlayer:getAccountType() ~= ACCOUNT_TYPE_NORMAL then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.tutor.msg_only_promote_normal")
		return true
	end

	targetPlayer:setAccountType(ACCOUNT_TYPE_TUTOR)
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.tutor.msg_promoted", {player:getName()})
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_tutor.msg_1", { targetPlayer:getName() })
	return true
end

addTutor:separator(" ")
addTutor:groupType("god")
addTutor:register()

---------------- // ----------------
local removeTutor = TalkAction("/removetutor")

function removeTutor.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_param_required_dot")
		-- Distro log
		logger.error("[removeTutor.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_is_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[removeTutor.onSay] - Player {} is not online", string.titleCase(name))
		return true
	end

	if targetPlayer:getAccountType() ~= ACCOUNT_TYPE_TUTOR then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.tutor.msg_only_demote_tutor")
		return true
	end

	targetPlayer:setAccountType(ACCOUNT_TYPE_NORMAL)
	--targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have been demoted to a normal player by " .. player:getName() .. ".")
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_tutor.msg_2", { targetPlayer:getName() })
	return true
end

removeTutor:separator(" ")
removeTutor:groupType("god")
removeTutor:register()
