local tunnel = MoveEvent()

function tunnel.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	player:teleportTo(Position(32616, 31514, 9))
	player:sayLocalized("scripts.moviments_tunnel.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

tunnel:type("stepin")
tunnel:aid(40029)
tunnel:register()
