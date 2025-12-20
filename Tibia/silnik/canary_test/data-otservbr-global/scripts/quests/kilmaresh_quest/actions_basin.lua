local basin = Action()

function basin.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Tem.Bleeds) == 1 then
		player:addItem(31431, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_basin.msg_1")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Eleven.Basin, 1)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_basin.msg_1")
	end
	return true
end

basin:uid(57527)
basin:register()
