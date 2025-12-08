local wrathEmperorMiss12Just = Action()

function wrathEmperorMiss12Just.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission12) == 0 then
		player:addOutfit(366, 0)
		player:addOutfit(367, 0)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mission12_just_rewards.msg_1")
		player:setStorageValue(Storage.Quest.U8_6.WrathOfTheEmperor.Mission12, 1) --Questlog, Wrath of the Emperor "Mission 12: Just Rewards"
		player:setStorageValue(1150, 1)
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mission12_just_rewards.msg_2")
		player:setStorageValue(1150, 1)
	end
	return true
end

wrathEmperorMiss12Just:uid(3200)
wrathEmperorMiss12Just:register()
