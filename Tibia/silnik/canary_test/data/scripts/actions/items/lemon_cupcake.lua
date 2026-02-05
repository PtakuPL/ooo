local distanceCondition = Condition(CONDITION_ATTRIBUTES)
distanceCondition:setParameter(CONDITION_PARAM_BUFF_SPELL, 1)
distanceCondition:setParameter(CONDITION_PARAM_TICKS, 60 * 60 * 1000)
distanceCondition:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 10)
distanceCondition:setParameter(CONDITION_PARAM_FORCEUPDATE, true)

local lemonCupcake = Action()

function lemonCupcake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("lemon-cupcake-cooldown") then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.lemon_cupcake.msg_1")
		return true
	end

	player:addCondition(distanceCondition)
	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "scripts.lemon_cupcake.msg_2")
	player:sayLocalized("scripts.lemon_cupcake.say_1", TALKTYPE_MONSTER_SAY)
	player:setExhaustion("lemon-cupcake-cooldown", 10 * 60)
	item:remove(1)
	return true
end

lemonCupcake:id(28486)
lemonCupcake:register()
