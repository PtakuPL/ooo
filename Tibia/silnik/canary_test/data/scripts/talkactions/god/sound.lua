local areasound = TalkAction("/areasound")

function areasound.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_area_single", {primaryEffect})
		player:getPosition():sendSingleSoundEffect(primaryEffect, player:isInGhostMode() and nil or player)
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_area_dual", {primaryEffect, secondaryEffect})
	player:getPosition():sendDoubleSoundEffect(primaryEffect, secondaryEffect, player:isInGhostMode() and nil or player)
	return true
end

areasound:separator(" ")
areasound:groupType("god")
areasound:register()

---------------- // ----------------
local internalsound = TalkAction("/internalsound")

function internalsound.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_internal_single", {primaryEffect})
		player:sendSingleSoundEffect(primaryEffect)
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_internal_dual", {primaryEffect, secondaryEffect})
	player:sendDoubleSoundEffect(primaryEffect, secondaryEffect)
	return true
end

internalsound:separator(" ")
internalsound:groupType("god")
internalsound:register()

---------------- // ----------------
local globalsound = TalkAction("/globalsound")

function globalsound.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_command_param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_global_single", {primaryEffect})
		for _, pid in ipairs(Game.getPlayers()) do
			pid:sendSingleSoundEffect(primaryEffect, false)
		end
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_invalid_command_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.sound.msg_global_dual", {primaryEffect, secondaryEffect})
	for _, pid in ipairs(Game.getPlayers()) do
		pid:sendDoubleSoundEffect(primaryEffect, secondaryEffect)
	end
	return true
end

globalsound:separator(" ")
globalsound:groupType("god")
globalsound:register()
