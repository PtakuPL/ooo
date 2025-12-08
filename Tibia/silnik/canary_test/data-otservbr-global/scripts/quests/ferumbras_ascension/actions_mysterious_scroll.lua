local ferumbrasAscendantMysterious = Action()
function ferumbrasAscendantMysterious.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.RiftRunner) >= 1 or player:getStorageValue(24850) < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mysterious_scroll.msg_1")
		return true
	else
		player:addMount(87)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_mysterious_scroll.msg_2")
		player:setStorageValue(Storage.Quest.U10_90.FerumbrasAscension.RiftRunner, 1)
	end
	return true
end

ferumbrasAscendantMysterious:id(22865)
ferumbrasAscendantMysterious:register()
