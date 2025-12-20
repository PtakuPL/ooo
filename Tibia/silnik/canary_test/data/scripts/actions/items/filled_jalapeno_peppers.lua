local speedCondition = Condition(CONDITION_HASTE)
speedCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
speedCondition:setParameter(CONDITION_PARAM_SPEED, 729)

local filledJalapenoPeppers = Action()

function filledJalapenoPeppers.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("special-foods-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.filled_jalapeno_peppers.msg_1")
		return true
	end

	player:addCondition(speedCondition)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.filled_jalapeno_peppers.msg_2")
	player:sayLocalized("scripts.filled_jalapeno_peppers.say_1", TALKTYPE_MONSTER_SAY)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	player:setExhaustion("special-foods-cooldown", 10 * 60)
	item:remove(1)
	return true
end

filledJalapenoPeppers:id(9085)
filledJalapenoPeppers:register()
