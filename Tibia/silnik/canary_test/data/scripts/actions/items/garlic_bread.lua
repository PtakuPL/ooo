local garlicBread = Action()

function garlicBread.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:sayLocalized("scripts.garlic_bread.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

garlicBread:id(8194)
garlicBread:register()
