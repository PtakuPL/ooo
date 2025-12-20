local sangra = Action()

function sangra.onUse(player, item, frompos, item2, topos)
	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Nine.Owl) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_sangra.msg_1")
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Tem.Bleeds, 1)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_sangra.msg_1")
	end
	return true
end

sangra:uid(57526)
sangra:register()
