local shulgraxLever = MoveEvent()

function shulgraxLever.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.FlowerPuzzleTimer) >= 1 then
		player:teleportTo(Position(33436, 32800, 13))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		local pos = position
		pos.y = pos.y + 1
		player:teleportTo(pos)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_shulgrax_lever.msg_1")
		item:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

shulgraxLever:type("stepin")
shulgraxLever:aid(34301)
shulgraxLever:register()
