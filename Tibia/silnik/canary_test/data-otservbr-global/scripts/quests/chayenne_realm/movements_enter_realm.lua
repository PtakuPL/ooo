local enterRealm = MoveEvent()

function enterRealm.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if item.actionid == 55022 then
		if player:getItemCount(14682) >= 1 and player:getLevel() >= 40 then
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:teleportTo(Position(32829, 31451, 8))
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_enter_realm.msg_1")
		else
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_enter_realm.msg_2")
			player:teleportTo(fromPosition, true)
		end
	elseif item.actionid == 55024 then
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:teleportTo(Position(33117, 32604, 6))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_enter_realm.msg_3")
	end
	return true
end

enterRealm:type("stepin")
enterRealm:aid(55022, 55024)
enterRealm:register()
