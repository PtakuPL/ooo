local oramondSeacrest = MoveEvent()

function oramondSeacrest.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local headItem = player:getSlotItem(CONST_SLOT_HEAD)
	if headItem and table.contains({ 5460, 11585, 13995 }, headItem.itemid) then
		player:teleportTo(Position(33552, 31775, 13))
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.seacrest.msg_1")
	else
		player:teleportTo(Position(33544, 31861, 7))
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.seacrest.msg_2")
	end
	return true
end

oramondSeacrest:type("stepin")
oramondSeacrest:uid(1110)
oramondSeacrest:register()
