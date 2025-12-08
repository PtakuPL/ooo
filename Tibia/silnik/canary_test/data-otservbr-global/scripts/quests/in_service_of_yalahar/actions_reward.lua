local inServiceYalaharReward = Action()
function inServiceYalaharReward.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.uid == 3088 then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 53 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 54)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 5) -- StorageValue for Questlog "Mission 10: The Final Battle"
			player:addItem(8862, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_1")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_2")
		end
	elseif item.uid == 3089 then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 53 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 54)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 5) -- StorageValue for Questlog "Mission 10: The Final Battle"
			player:addItem(8864, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_3")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_4")
		end
	elseif item.uid == 3090 then
		if player:getStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline) == 53 then
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Questline, 54)
			player:setStorageValue(Storage.Quest.U8_4.InServiceOfYalahar.Mission10, 5) -- StorageValue for Questlog "Mission 10: The Final Battle"
			player:addItem(8863, 1)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_5")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_6")
		end
	end

	return true
end

inServiceYalaharReward:uid(3088, 3089, 3090)
inServiceYalaharReward:register()
