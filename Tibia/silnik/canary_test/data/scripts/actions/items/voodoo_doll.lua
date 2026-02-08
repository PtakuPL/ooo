local voodooDoll = Action()

function voodooDoll.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid ~= 1 or not target:isPlayer() then
		return false
	end

	local textKey = nil
	if math.random(100) <= 5 then
		textKey = "scripts.voodoo_doll.hit_success"
		player:addAchievement("Dark Voodoo Priest")
		toPosition:sendMagicEffect(CONST_ME_DRAWBLOOD, player)
	else
		textKey = "scripts.voodoo_doll.hit_fail"
	end

	player:sayLocalized(textKey, TALKTYPE_MONSTER_SAY, false, player)
	return true
end

voodooDoll:id(3002)
voodooDoll:register()
