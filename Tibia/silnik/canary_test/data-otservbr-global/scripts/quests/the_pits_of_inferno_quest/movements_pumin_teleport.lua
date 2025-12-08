local puminTeleport = MoveEvent()

function puminTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U7_9.ThePitsOfInferno.ThronePumin) >= 9 then
		player:teleportTo(Position(32786, 32308, 15))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:teleportTo(fromPosition)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_pumin_teleport.msg_1")
	end
	return true
end

puminTeleport:type("stepin")
puminTeleport:aid(50087)
puminTeleport:register()
