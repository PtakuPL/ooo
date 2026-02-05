local addAchievement = TalkAction("/addachievement")

function addAchievement.onSay(player, words, param)
	logCommand(player, words, param)
	local params = param:split(",")
	if #params < 2 then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.achievement_functions.usage_add")
		return true
	end

	local targetPlayerName, achievementIdentifier = params[1], params[2]
	local targetPlayer = Player(targetPlayerName)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.achievement_functions.player_not_online", {targetPlayerName})
		return true
	end

	local achievementId = tonumber(achievementIdentifier)
	local achievementName = tostring(achievementIdentifier):lower():trimSpace():titleCase()
	local achievementInfo = achievementId and Game.getAchievementInfoById(achievementId) or Game.getAchievementInfoByName(achievementName)
	if achievementInfo.id == 0 or achievementInfo.name == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.achievement_functions.invalid_achievement")
		return true
	end

	targetPlayer:addAchievement(achievementInfo.id, true)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.achievement_functions.msg_1" .. achievementInfo.name .. " added successfully to " .. targetPlayerName .. ".")
	return true
end

addAchievement:separator(" ")
addAchievement:groupType("god")
addAchievement:register()

local removeAchievement = TalkAction("/removeachievement")

function removeAchievement.onSay(player, words, param)
	logCommand(player, words, param)
	local params = param:split(",")
	if #params < 2 then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.achievement_functions.usage_remove")
		return true
	end

	local targetPlayerName, achievementIdentifier = params[1], params[2]
	local targetPlayer = Player(targetPlayerName)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.achievement_functions.player_not_online", {targetPlayerName})
		return true
	end

	local achievementId = tonumber(achievementIdentifier)
	local achievementName = tostring(achievementIdentifier):lower():trimSpace():titleCase()
	local achievementInfo = achievementId and Game.getAchievementInfoById(achievementId) or Game.getAchievementInfoByName(achievementName)
	if not achievementInfo then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.achievement_functions.invalid_identifier")
		return true
	end

	targetPlayer:removeAchievement(achievementInfo.id)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.achievement_functions.msg_2" .. achievementInfo.name .. " removed successfully.")
	return true
end

removeAchievement:separator(" ")
removeAchievement:groupType("god")
removeAchievement:register()

local checkAchievements = TalkAction("/checkachievements")

function checkAchievements.onSay(player, words, param)
	logCommand(player, words, param)
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.achievement_functions.usage_check")
		return true
	end

	local targetPlayer = Player(param)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.achievement_functions.player_not_online", {param})
		return true
	end

	local ACHIEVEMENTS = targetPlayer:getAchievements()
	local message = "Achievements: "
	for _, achievementId in pairs(ACHIEVEMENTS) do
		local achievementInfo = Game.getAchievementInfoById(achievementId)
		message = message .. achievementInfo.name .. ", "
	end
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, message)
	return true
end

checkAchievements:separator(" ")
checkAchievements:groupType("god")
checkAchievements:register()
