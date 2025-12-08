local calassa = MoveEvent()

function calassa.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local headItem = player:getSlotItem(CONST_SLOT_HEAD)
	if headItem and table.contains({ 5460, 11585, 13995 }, headItem.itemid) then
		player:teleportTo(Position(31914, 32713, 12))
		player:getPosition():sendMagicEffect(CONST_ME_WATERSPLASH)
		player:getPosition():sendMagicEffect(CONST_ME_LOSEENERGY)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_calassa.msg_1")
	else
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_calassa.msg_2")
	end
	return true
end

calassa:type("stepin")
calassa:aid(2070)
calassa:register()
