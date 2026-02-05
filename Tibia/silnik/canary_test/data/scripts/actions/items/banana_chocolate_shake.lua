local bananaChocolateShake = Action()

function bananaChocolateShake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.banana_chocolate_shake.msg_1")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.banana_chocolate_shake.msg_2")
	player:sayLocalized("scripts.banana_chocolate_shake.say_1", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_HEARTS)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

bananaChocolateShake:id(9083)
bananaChocolateShake:register()
