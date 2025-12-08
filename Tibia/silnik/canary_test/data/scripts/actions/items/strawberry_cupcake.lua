local strawberryCupcake = Action()

function strawberryCupcake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("strawberry-cupcake-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.strawberry_cupcake.msg_1")
		return true
	end

	player:addHealth(player:getMaxHealth())
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.strawberry_cupcake.msg_2")
	player:say("Mmmm.", TALKTYPE_MONSTER_SAY)
	player:setExhaustion("strawberry-cupcake-cooldown", 10 * 60)
	item:remove(1)
	return true
end

strawberryCupcake:id(28485)
strawberryCupcake:register()
