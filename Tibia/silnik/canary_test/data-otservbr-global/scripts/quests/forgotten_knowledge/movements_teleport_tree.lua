local teleportTree = MoveEvent()

function teleportTree.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end

	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.PlantCounter) < 5 or player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.BirdCounter) < 3 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_teleport_tree.msg_1")
		player:teleportTo(Position(32737, 32117, 10))
		position:sendMagicEffect(CONST_ME_TELEPORT)
		player:setDirection(SOUTH)
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		return true
	end
	player:teleportTo(Position(32720, 32927, 14))
	player:getPosition():sendMagicEffect(CONST_ME_SMALLPLANTS)
	return true
end

teleportTree:type("stepin")
teleportTree:aid(27830)
teleportTree:register()
