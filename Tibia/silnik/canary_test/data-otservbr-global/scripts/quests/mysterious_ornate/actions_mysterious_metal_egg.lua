local mysterious = Action()

function mysterious.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:sayLocalized("scripts.actions_mysterious_metal_egg.say_1", TALKTYPE_MONSTER_SAY)
end

mysterious:id(19065, 22739)
mysterious:register()
