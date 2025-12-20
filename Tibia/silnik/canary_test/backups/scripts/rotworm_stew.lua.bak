local rotwormStew = Action()

function rotwormStew.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.rotworm_stew.msg_1")
		return true
	end

	player:addHealth(player:getMaxHealth())
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.rotworm_stew.msg_2")
	player:say("Gulp.", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

rotwormStew:id(9079)
rotwormStew:register()
