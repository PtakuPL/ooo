local gap = MoveEvent()

function gap.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	player:teleportTo(Position(32569, 31507, 9))
	player:sayLocalized("scripts.moviments_gap.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

gap:type("stepin")
gap:aid(50111)
gap:register()
