local iceCure = Action()
function iceCure.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid ~= 7106 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U8_0.TheIceIslands.Questline) >= 21 then
		toPosition:sendMagicEffect(CONST_ME_MAGIC_BLUE)
		player:sayLocalized("scripts.actions_cure.say_1", TALKTYPE_MONSTER_SAY)
		item:transform(7246)
	end
	return true
end

iceCure:id(7286)
iceCure:register()
