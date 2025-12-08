local sacrificeTeleport = MoveEvent()

function sacrificeTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U10_55.SanctuaryOfTheLizardGod.LizardGodTeleport) == 1 then
		player:teleportTo({ x = 32124, y = 31938, z = 8 })
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	else
		player:teleportTo(fromPosition, true)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_legion_helmet.msg_1")
	end
	return true
end

sacrificeTeleport:uid(35010)
sacrificeTeleport:register()
