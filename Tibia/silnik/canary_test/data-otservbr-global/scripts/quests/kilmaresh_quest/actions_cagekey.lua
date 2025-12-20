local cagekey = Action()

function cagekey.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourteen.Remains) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_cagekey.msg_1")
		player:addItem(31379, 1) -- Wooden Cage Key
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourteen.Remains, 3)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_cagekey.msg_1")
	end

	return true
end

cagekey:uid(57530)
cagekey:register()
