local lyre = Action()

function lyre.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_lyre.msg_1")
		player:addItem(31447, 1)
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre, 3)
	else
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_lyre.msg_2")
	end

	return true
end

lyre:uid(57529)
lyre:register()
