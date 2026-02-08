local maxPlayersPerMessage = 10
local playersOnline = TalkAction("!online")
local onlineCategoryMessageKeys = {
	Training = "talkaction.online.msg_category_training",
	Idle = "talkaction.online.msg_category_idle",
	Active = "talkaction.online.msg_category_active",
}

local function formatOnlineEntry(player)
	return ("%s [%d|%s]"):format(player:getName(), player:getLevel(), player:vocationAbbrev())
end

function playersOnline.onSay(player, words, param)
	local hasAccess = player:getGroup():getAccess()
	local players = Game.getPlayers()
	local onlineList = {
		Training = {},
		Idle = {},
		Active = {},
	}

	for _, targetPlayer in ipairs(players) do
		if hasAccess or not targetPlayer:isInGhostMode() then
			if _G.OnExerciseTraining[targetPlayer:getId()] then
				table.insert(onlineList.Training, targetPlayer)
			elseif targetPlayer:getIdleTime() >= 5 * 60 * 1000 then
				table.insert(onlineList.Idle, targetPlayer)
			else
				table.insert(onlineList.Active, targetPlayer)
			end
		end
	end

	local onlineCount = #onlineList.Training + #onlineList.Idle + #onlineList.Active
	player:sendLocalizedTextMessage(MESSAGE_ATTENTION, "talkaction.online.msg_summary", {
		tostring(onlineCount),
		tostring(#onlineList.Training),
		tostring(#onlineList.Idle),
		tostring(#onlineList.Active),
	})

	for category, list in pairs(onlineList) do
		if #list > 0 then
			local categoryMessageKey = onlineCategoryMessageKeys[category]
			local sendCategoryLabel = true
			while #list > 0 do
				local msg = {}
				for _ = 1, maxPlayersPerMessage do
					local targetPlayer = list[1]
					if targetPlayer then
						table.insert(msg, formatOnlineEntry(targetPlayer))
						table.remove(list, 1)
					end
				end
				if sendCategoryLabel then
					player:sendLocalizedTextMessage(MESSAGE_ATTENTION, categoryMessageKey, {
						table.concat(msg, ", "),
					})
					sendCategoryLabel = false
				else
					player:sendLocalizedTextMessage(MESSAGE_ATTENTION, "talkaction.online.msg_players_only", {
						table.concat(msg, ", "),
					})
				end
			end
		end
	end
	return true
end

playersOnline:groupType("normal")
playersOnline:register()
