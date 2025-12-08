local dangerousDepthChest = Action()

function dangerousDepthChest.onUse(player, item)
	if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.GnomishChest) == 1 then
		player:addItem(27498, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnomish_chest.msg_1")
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.GnomishChest, 2)
	elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Scouts.GnomishChest) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_gnomish_chest.msg_2")
	end
	return true
end

dangerousDepthChest:uid(57234)
dangerousDepthChest:register()
