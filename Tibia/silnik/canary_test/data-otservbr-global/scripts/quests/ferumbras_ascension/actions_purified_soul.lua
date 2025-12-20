local ferumbrasAscendantPurifiedSoul = Action()
function ferumbrasAscendantPurifiedSoul.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local devourer = target:getName():lower() == "sin devourer" and target:isMonster()
	if not devourer then
		return false
	end

	target:getPosition():sendMagicEffect(CONST_ME_HOLYAREA)
	target:sayLocalized("scripts.actions_purified_soul.say_1", TALKTYPE_MONSTER_SAY)
	target:remove()
	item:remove()
	return true
end

ferumbrasAscendantPurifiedSoul:id(22698)
ferumbrasAscendantPurifiedSoul:register()
