local rookVillage = MoveEvent()

function rookVillage.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	player:teleportTo(Position(player:getPosition().x, player:getPosition().y - 3, player:getPosition().z + 1))
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.rook_village.msg_1")

	return true
end

rookVillage:type("stepin")
rookVillage:id(7888)
rookVillage:register()
