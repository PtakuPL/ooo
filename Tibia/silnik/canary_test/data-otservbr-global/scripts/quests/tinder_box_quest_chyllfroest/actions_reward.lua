local tinderReward = Action()

function tinderReward.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local currentDate = os.date("*t")
	local currentTime = os.time()

	if currentDate.month < 4 or currentDate.month > 5 or (currentDate.month == 5 and currentDate.day > 1) then
		return player:sendLocalizedCancelMessage("quests.tinder_box_quest_chyllfroest.this_can_only_be_used_between")
	end

	if player:getStorageValue(Storage.Quest.U10_37.TinderBoxQuestChyllfroest.Reward) >= currentTime then
		return player:sendLocalizedCancelMessage("quests.tinder_box_quest_chyllfroest.the_pile_of_bones_is_empty")
	end

	player:addItem(20357, 1)
	player:setStorageValue(Storage.Quest.U10_37.TinderBoxQuestChyllfroest.Reward, currentTime + 72000)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_reward.msg_1")

	return true
end

tinderReward:uid(3263)
tinderReward:register()
