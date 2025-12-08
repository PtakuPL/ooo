local schrodingersIslandTeleportLvl999 = MoveEvent()

function schrodingersIslandTeleportLvl999.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	if player:getLevel() < 999 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.schrodingers_island_teleport_lvl_999.msg_1")
		creature:teleportTo(fromPosition)
		fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.schrodingers_island_teleport_lvl_999.msg_2")

	local accessPosition = Position(32832, 32435, 7)
	player:teleportTo(accessPosition)
	fromPosition:sendMagicEffect(CONST_ME_TELEPORT)
	accessPosition:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

schrodingersIslandTeleportLvl999:type("stepin")
schrodingersIslandTeleportLvl999:aid(15998)
schrodingersIslandTeleportLvl999:register()
