local function serverSave(interval)
	if configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL_CLEAN_MAP) then
		cleanMap()
	end

	saveServer()
	local key = SAVE_INTERVAL_CONFIG_TIME > 1 and "globalevents.save_interval.complete_plural" or "globalevents.save_interval.complete_singular"
	Game.broadcastLocalizedMessageLua(key, MESSAGE_GAME_HIGHLIGHT, { tostring(SAVE_INTERVAL_CONFIG_TIME), SAVE_INTERVAL_TYPE })
	local logMessage = string.format("Server save complete. Next save in %d %s%s!", SAVE_INTERVAL_CONFIG_TIME, SAVE_INTERVAL_TYPE, SAVE_INTERVAL_CONFIG_TIME > 1 and "s" or "")
	logger.info(logMessage)
	Webhook.sendMessage("Server save", logMessage, WEBHOOK_COLOR_WARNING)
end

local save = GlobalEvent("save")

function save.onTime(interval)
	local remainingTime = 60 * 1000
	if configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL) then
		Game.broadcastLocalizedMessageLua("globalevents.save_interval.warning", MESSAGE_GAME_HIGHLIGHT, { tostring(remainingTime / 1000) })
		logger.info(string.format("The server will save all accounts within %d seconds.", remainingTime / 1000))
		addEvent(serverSave, remainingTime, interval)
		return true
	end
	return not configManager.getBoolean(configKeys.TOGGLE_SAVE_INTERVAL)
end

if SAVE_INTERVAL_TIME ~= 0 then
	save:interval(SAVE_INTERVAL_CONFIG_TIME * SAVE_INTERVAL_TIME)
else
	return logger.error(string.format("[save.onTime] - Save interval type '%s' is not valid, use 'second', 'minute' or 'hour'", SAVE_INTERVAL_TYPE))
end

save:register()
