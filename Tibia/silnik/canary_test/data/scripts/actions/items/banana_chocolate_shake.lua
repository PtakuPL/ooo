local bananaChocolateShake = Action()

function bananaChocolateShake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.banana_chocolate_shake.msg_1")
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.banana_chocolate_shake.msg_2")
	player:say("Slurp.", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

bananaChocolateShake:id(9083)
bananaChocolateShake:register()
