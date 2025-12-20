local peeler = Action()

function peeler.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Set.Ritual) == 2 then
		player:addItem(31328, 1)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Set.Ritual, 3)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_peeler.msg_1")
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_peeler.msg_1")
	end

	return true
end

peeler:uid(57518)
peeler:register()
