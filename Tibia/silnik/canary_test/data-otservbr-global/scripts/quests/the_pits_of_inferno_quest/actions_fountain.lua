local pitsOfInfernoFountain = Action()
function pitsOfInfernoFountain.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.FountainOfLife) == 1 then
		return false
	end

	player:addHealth(player:getMaxHealth())
	player:addMana(player:getMaxMana())
	player:addAchievement("Fountain of Life")
	player:setStorageValue(Storage.FountainOfLife, 1)
	player:sayLocalized("scripts.actions_fountain.say_1", TALKTYPE_MONSTER_SAY)
	return true
end

pitsOfInfernoFountain:aid(8815)
pitsOfInfernoFountain:register()
