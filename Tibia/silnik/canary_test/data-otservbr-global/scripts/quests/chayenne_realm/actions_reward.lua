local chayenneReward = Action()
function chayenneReward.onUse(player, item, fromPosition, itemEx, toPosition)
	if player:getStorageValue(Storage.ChayenneReward) < 1 then
		local backpack = player:addItem(5949, 1)
		backpack:addItem(16244, 1)
		backpack:addItem(3659, 1)
		backpack:addItem(9034, 1)
		backpack:addItem(3027, 1)
		backpack:addItem(5882, 1)
		backpack:addItem(5791, 1)
		backpack:addItem(2995, 1)
		backpack:addItem(6570, 1)
		player:setStorageValue(Storage.ChayenneReward, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_2")
	end
	return true
end

chayenneReward:aid(55023)
chayenneReward:register()
