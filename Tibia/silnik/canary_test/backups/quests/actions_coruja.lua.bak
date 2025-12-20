local coruja = Action()

function coruja.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Nine.Owl) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_coruja.msg_1")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Nine.Owl, 2)
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sorry")
	end
	return true
end

coruja:uid(57525)
coruja:register()
