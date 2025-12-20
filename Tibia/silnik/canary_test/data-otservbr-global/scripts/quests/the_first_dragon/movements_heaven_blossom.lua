local heavenBlossom = MoveEvent()

function heavenBlossom.onStepIn(creature, item, position, fromPosition)
	if creature:isPlayer() then
		return true
	end

	if item.uid == 1066 then
		if creature:getName() == "Spirit of Fertility" then
			creature:sayLocalized("scripts.movements_heaven_blossom.say_2", TALKTYPE_MONSTER_SAY)
			creature:remove()
			Game.createMonster("Angry Plant", position, true, true)
			item:remove()
			creature:sayLocalized("scripts.movements_heaven_blossom.say_1", TALKTYPE_MONSTER_SAY)
		end
	end
	return true
end

heavenBlossom:id(3657)
heavenBlossom:register()
