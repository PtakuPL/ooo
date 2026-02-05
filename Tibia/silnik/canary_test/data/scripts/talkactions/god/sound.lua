local areasound = TalkAction("/areasound")

function areasound.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_area_single", {tostring(primaryEffect)})
		player:getPosition():sendSingleSoundEffect(primaryEffect, player:isInGhostMode() and nil or player)
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_area_dual", {tostring(primaryEffect), tostring(secondaryEffect)})
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_internal_single", {tostring(primaryEffect)})
		player:sendSingleSoundEffect(primaryEffect)
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_internal_dual", {tostring(primaryEffect), tostring(secondaryEffect)})
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
		player:sendLocalizedMessage(MESSAGE_FAILURE, "gm.common.param_required")
		return true
	end

	local split = param:split(",")
	if not split[2] then
		local primaryEffect = tonumber(param)
		if primaryEffect == nil or primaryEffect == 0 then
			player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_param")
			return true
		end

		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_global_single", {tostring(primaryEffect)})
		for _, pid in ipairs(Game.getPlayers()) do
			pid:sendSingleSoundEffect(primaryEffect, false)
		end
		return true
	end

	local primaryEffect = tonumber(split[1])
	local secondaryEffect = tonumber(split[2])
	if primaryEffect == nil or secondaryEffect == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.sound.invalid_params")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.sound.playing_global_dual", {tostring(primaryEffect), tostring(secondaryEffect)})
	for _, pid in ipairs(Game.getPlayers()) do
		pid:sendDoubleSoundEffect(primaryEffect, secondaryEffect)
	end
	return true
end

globalsound:separator(" ")
globalsound:groupType("god")
globalsound:register()
