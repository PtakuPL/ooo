local blessedSteak = Action()

function blessedSteak.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.blessed_steak.msg_1")
		return true
	end

	player:addMana(player:getMaxMana())
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.blessed_steak.msg_2")
	player:sayLocalized("scripts.blessed_steak.say_1", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

blessedSteak:id(9086)
blessedSteak:register()
