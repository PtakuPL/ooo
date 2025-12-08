local darkCorpse = Action()

function darkCorpse.onUse(player)
	if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission14) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_corpse.msg_1")
		player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission14, 2)
	elseif player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission14) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_corpse.msg_2")
	end
	return true
end

darkCorpse:uid(20001)
darkCorpse:register()
