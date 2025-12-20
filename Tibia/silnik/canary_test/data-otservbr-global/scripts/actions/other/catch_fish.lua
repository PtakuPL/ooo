local catchFish = Action()

function catchFish.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid ~= 5553 then
		return false
	end

	if math.random(10) ~= 1 then
		player:sayLocalized("scripts.catch_fish.say_2", TALKTYPE_MONSTER_SAY)
		return true
	end
	player:sayLocalized("scripts.catch_fish.say_1", TALKTYPE_MONSTER_SAY)
	item:transform(5929)
	toPosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

catchFish:id(5928)
catchFish:register()
