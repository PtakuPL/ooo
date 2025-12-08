local heartDestructionReward = Action()
function heartDestructionReward.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid == 1038 then
		if player:getStorageValue(14337) < 1 then
			local container = player:addItem(23525)
			container:addItem(23512, 1)
			container:addItem(23538, 1)
			container:addItem(23536, 1)
			container:addItem(23509, 1)
			container:addItem(3043, 20)
			container:addItem(22721, 5)
			player:setStorageValue(14337, 1)
			player:addAchievement("Ender of the End")
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_1")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_2")
		end
	end

	return true
end

heartDestructionReward:uid(1038)
heartDestructionReward:register()
