local rapierQuest = Action()

function rapierQuest.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local rewardId = 3272
	if not player:canGetReward(rewardId, "rapier") then
		return true
	end
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.rapier_quest.msg_1")
	player:addItem(rewardId, 1)
	player:questKV("rapier"):set("completed", true)
	player:takeScreenshot(SCREENSHOT_TYPE_TREASUREFOUND)
	return true
end

rapierQuest:uid(14042)
rapierQuest:register()
