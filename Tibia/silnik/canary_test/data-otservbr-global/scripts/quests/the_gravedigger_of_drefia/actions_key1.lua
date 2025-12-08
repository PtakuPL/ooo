local gravediggerKey1 = Action()
function gravediggerKey1.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.actionid ~= 4639 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Mission31) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_key1.msg_1")
		item:remove(1)
		Tile(Position(33071, 32442, 11)):getItemById(8708):transform(8709)
	end
	return true
end

gravediggerKey1:id(19166)
gravediggerKey1:register()
