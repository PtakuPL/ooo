local destination = {
	[24869] = { position = Position(33740, 31940, 15) },
	[24870] = { position = Position(33534, 31955, 15) },
	[24871] = { position = Position(33611, 32055, 15) },
}

local fastWay = MoveEvent()

function fastWay.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end

	local teleport = destination[item.actionid]
	if not teleport then
		return
	end

	if player:getStorageValue(Storage.HeroRathleton.FastWay) >= 1 then
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:teleportTo(teleport.position)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_fast_way.msg_1")
	else
		local pos = position
		pos.y = pos.y + 2
		player:teleportTo(pos)
		player:sayLocalized("scripts.movements_fast_way.say_1", TALKTYPE_MONSTER_SAY, false, nil, position)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	end
	return true
end

fastWay:type("stepin")

for index, value in pairs(destination) do
	fastWay:aid(index)
end

fastWay:register()
