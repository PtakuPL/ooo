local servantTeleport = MoveEvent()

function servantTeleport.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return
	end

	if not player:canFightBoss("LLoyd") then
		player:teleportTo(Position(32815, 32872, 13))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_servant_teleport.msg_1")
		return true
	end
	if player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.GoldenServantCounter) >= 5 and player:getStorageValue(Storage.Quest.U11_02.ForgottenKnowledge.DiamondServantCounter) >= 5 then
		player:teleportTo(Position(32760, 32876, 14))
		player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)
		return true
	else
		player:teleportTo(Position(32815, 32872, 13))
		player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
		position:sendMagicEffect(CONST_ME_TELEPORT)
		player:sayLocalized("scripts.movements_servant_teleport.say_1", TALKTYPE_MONSTER_SAY, false, nil, position)
	end
	return true
end

servantTeleport:type("stepin")
servantTeleport:aid(26665)
servantTeleport:register()
