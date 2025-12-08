local gateOfDeathstruction = MoveEvent()

function gateOfDeathstruction.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U10_90.FerumbrasAscension.Statue) < 1 then
		position:sendMagicEffect(CONST_ME_TELEPORT)
		position.y = position.y + 2
		player:teleportTo(position)
		position:sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:teleportTo(Position(33414, 32379, 13))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		local gatePos = Position(33415, 32377, 13)
		gatePos:sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_gate_of_deathstruction.msg_1")
	end
	return true
end

gateOfDeathstruction:type("stepin")
gateOfDeathstruction:aid(53802)
gateOfDeathstruction:register()
