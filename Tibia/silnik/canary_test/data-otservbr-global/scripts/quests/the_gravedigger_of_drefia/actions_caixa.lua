local gravediggerCaixa = Action()
function gravediggerCaixa.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission67) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission68) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission68, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_caixa.msg_1")
		player:addItem(18933, 1)
	end
	return true
end

gravediggerCaixa:uid(4663)
gravediggerCaixa:register()
