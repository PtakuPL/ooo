local gravediggerCandles = Action()
function gravediggerCandles.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.actionid ~= 4640 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission31) == 1 and player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission32) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission32, 1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_candles.msg_1")
		player:addItem(18931, 3)
		item:remove(1)
	end
	return true
end

gravediggerCandles:id(19132)
gravediggerCandles:register()
