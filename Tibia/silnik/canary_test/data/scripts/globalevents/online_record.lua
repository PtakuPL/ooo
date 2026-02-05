local onlineRecord = GlobalEvent("OnlineRecord")

function onlineRecord.onRecord(current, old)
	-- broadcastLocalizedMessage via addEvent requires a wrapper
	addEvent(function()
		Game.broadcastLocalizedMessageLua("globalevents.online_record", MESSAGE_LOGIN, { tostring(current) })
	end, 150)
	return true
end

onlineRecord:register()
