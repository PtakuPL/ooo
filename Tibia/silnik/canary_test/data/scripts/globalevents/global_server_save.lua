local function ServerSave()
	if configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_CLEAN_MAP) then
		cleanMap()
	end

	if configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_CLOSE) then
		Game.setGameState(GAME_STATE_CLOSED)
	end
	if configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_SHUTDOWN) then
		Game.setGameState(GAME_STATE_SHUTDOWN)
	end

	-- Update daily reward next server save timestamp
	UpdateDailyRewardGlobalStorage(DailyReward.storages.lastServerSave, os.time())
end

local function ServerSaveWarning(time)
	-- Calculate remaining time, minus one minute
	local remainingTime = tonumber(time) - 60000
	if configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_NOTIFY_MESSAGE) then
		local minutesLeft = tostring(remainingTime / 60000)
		-- Webhook still uses English
		local webhookMsg = "Server is saving the game in " .. minutesLeft .. " minute(s). Please logout."
		Webhook.sendMessage("Server save", webhookMsg, WEBHOOK_COLOR_WARNING)
		Game.broadcastLocalizedMessageLua("globalevents.server_save.warning", MESSAGE_GAME_HIGHLIGHT, { minutesLeft })
	end

	if remainingTime > 60000 then
		addEvent(ServerSaveWarning, 60000, remainingTime)
	else
		addEvent(ServerSave, 60000)
	end
end

local globalServerSave = GlobalEvent("GlobalServerSave")

-- Function that is called by the global events when it reaches the time configured
-- Interval is the time between the event start and the effective save, it will send a notify message every minute
function globalServerSave.onTime(interval)
	local remainingTime = configManager.getNumber(configKeys.GLOBAL_SERVER_SAVE_NOTIFY_DURATION) * 60000
	if configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_NOTIFY_MESSAGE) then
		local minutesLeft = tostring(remainingTime / 60000)
		local webhookMsg = "Server is saving the game in " .. minutesLeft .. " minute(s). Please logout."
		Webhook.sendMessage("Server save", webhookMsg, WEBHOOK_COLOR_WARNING)
		Game.broadcastLocalizedMessageLua("globalevents.server_save.warning", MESSAGE_GAME_HIGHLIGHT, { minutesLeft })
	end

	-- Schedule the next warning event in 1 minute (60000 milliseconds)
	addEvent(ServerSaveWarning, 60000, remainingTime)
	return not configManager.getBoolean(configKeys.GLOBAL_SERVER_SAVE_SHUTDOWN)
end

globalServerSave:time(configManager.getString(configKeys.GLOBAL_SERVER_SAVE_TIME))
globalServerSave:register()
