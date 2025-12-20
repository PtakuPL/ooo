local scissors = Action()

function scissors.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Set.Ritual) == 1 then
		player:addItem(31327, 1)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Set.Ritual, 2)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_scissors.msg_1")
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_scissors.msg_1")
	end

	return true
end

scissors:uid(uniqueid)
scissors:register()
