local addTutor = TalkAction("/addtutor")

function addTutor.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.manage_tutor.player_name_required")
		-- Distro log
		logger.error("[addTutor.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.manage_tutor.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[addTutor.onSay] - Player {} is not online", string.titleCase(name))
		return true
	end

	if targetPlayer:getAccountType() ~= ACCOUNT_TYPE_NORMAL then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.manage_tutor.only_promote_normal")
		return true
	end

	targetPlayer:setAccountType(ACCOUNT_TYPE_TUTOR)
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.manage_tutor.promoted_to_tutor", {player:getName()})
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_tutor.msg_1" .. targetPlayer:getName() .. " to a tutor.")
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.manage_tutor.player_name_required")
		-- Distro log
		logger.error("[removeTutor.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.manage_tutor.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[removeTutor.onSay] - Player {} is not online", string.titleCase(name))
		return true
	end

	if targetPlayer:getAccountType() ~= ACCOUNT_TYPE_TUTOR then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.manage_tutor.only_demote_tutor")
		return true
	end

	targetPlayer:setAccountType(ACCOUNT_TYPE_NORMAL)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_tutor.msg_2" .. targetPlayer:getName() .. " to a normal player.")
	return true
end

removeTutor:separator(" ")
removeTutor:groupType("god")
removeTutor:register()
