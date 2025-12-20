local blueberryCupcake = Action()

function blueberryCupcake.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:hasExhaustion("blueberry-cupcake-cooldown") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.blueberry_cupcake.msg_1")
		return true
	end

	player:addMana(player:getMaxMana())
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.blueberry_cupcake.msg_2")
	player:sayLocalized("scripts.blueberry_cupcake.say_1", TALKTYPE_MONSTER_SAY)
	player:setExhaustion("blueberry-cupcake-cooldown", 10 * 60)
	item:remove(1)
	return true
end

blueberryCupcake:id(28484)
blueberryCupcake:register()
