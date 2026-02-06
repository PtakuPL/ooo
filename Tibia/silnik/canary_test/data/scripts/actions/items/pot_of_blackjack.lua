local potOfBlackjack = Action()

function potOfBlackjack.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.pot_of_blackjack.msg_1")
		return true
	end

	local remainingGulps = player:kv():get("pot-of-blackjack") or math.random(2, 4)

	if remainingGulps > 0 then
		remainingGulps = remainingGulps - 1
		player:kv():set("pot-of-blackjack", remainingGulps)

		local messageKey
		if remainingGulps > 0 then
			messageKey = "scripts.pot_of_blackjack.gulp_more"
		else
			messageKey = "scripts.pot_of_blackjack.gulp_last"
		end

		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, messageKey)
	end

	player:addHealth(5000)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.pot_of_blackjack.msg_2")
	player:sayLocalized("scripts.pot_of_blackjack.say_1", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

potOfBlackjack:id(11586)
potOfBlackjack:register()
