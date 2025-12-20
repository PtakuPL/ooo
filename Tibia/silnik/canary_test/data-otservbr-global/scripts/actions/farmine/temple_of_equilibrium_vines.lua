local templeOfEquilibriumVines = Action()

function templeOfEquilibriumVines.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.actionid == 12141 then
		local destination = Position(33187, 31206, 7)
		player:teleportTo(destination)
		destination:sendMagicEffect(CONST_ME_POFF)
		fromPosition:sendMagicEffect(CONST_ME_POFF)
		player:sayLocalized("scripts.temple_of_equilibrium_vines.say_2", TALKTYPE_MONSTER_SAY)
	else
		player:sayLocalized("scripts.temple_of_equilibrium_vines.say_1", TALKTYPE_MONSTER_SAY)
		fromPosition:sendMagicEffect(CONST_ME_SMALLPLANTS)
	end
	return true
end

templeOfEquilibriumVines:aid(12141, 12142)
templeOfEquilibriumVines:register()
