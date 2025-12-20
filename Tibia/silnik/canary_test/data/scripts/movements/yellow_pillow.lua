local yellowPillow = MoveEvent()

function yellowPillow.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player or player:isInGhostMode() then
		return true
	end

	player:sayLocalized("scripts.yellow_pillow.say_1", TALKTYPE_MONSTER_SAY)
	item:getPosition():sendMagicEffect(CONST_ME_POFF)
	return true
end

yellowPillow:id(2397)
yellowPillow:type("stepin")
yellowPillow:register()
