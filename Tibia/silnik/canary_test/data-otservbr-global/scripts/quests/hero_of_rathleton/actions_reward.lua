local heroRathletonReward = Action()
function heroRathletonReward.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(24850) < 1 then
		player:addItem(21203, 5)
		player:addItem(3035, 4)
		player:addItem(21897)
		player:addItem(9058)
		player:addItem(836)
		player:addAchievement("The Professors Nut")
		player:setStorageValue(24850, 1) -- storage da recompensa
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_1")
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_2")
	end
	return true
end

heroRathletonReward:uid(24850)
heroRathletonReward:register()
