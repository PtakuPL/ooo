local clawOfTheNoxiousSpawn = MoveEvent()

function clawOfTheNoxiousSpawn.onEquip(player, item, slot, isCheck)
	if not isCheck then
		if not Tile(player:getPosition()):hasFlag(TILESTATE_PROTECTIONZONE) then
			doTargetCombatHealth(0, player, COMBAT_PHYSICALDAMAGE, -150, -200, CONST_ME_DRAWBLOOD)
			local msgKey = math.random(2) == 1 and "movement.claw_noxious.msg_tighten" or "movement.claw_noxious.msg_stab"
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, msgKey)
			return true
		end
	end
	return true
end

clawOfTheNoxiousSpawn:type("equip")
clawOfTheNoxiousSpawn:slot("ring")
clawOfTheNoxiousSpawn:id(9393)
clawOfTheNoxiousSpawn:level(100)
clawOfTheNoxiousSpawn:register()
