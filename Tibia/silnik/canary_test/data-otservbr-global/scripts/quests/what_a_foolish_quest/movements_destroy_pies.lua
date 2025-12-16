local destroyPies = MoveEvent()

function destroyPies.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer) > os.time() then
		player:getStorageValue(Storage.Quest.U8_1.WhatAFoolishQuest.PieBoxTimer, 1)
	end

	local pieBox = player:getItemById(7484, true)
	if not pieBox then
		return true
	end

	pieBox:transform(3135)
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:sayLocalized("scripts.movements_destroy_pies.say_2", TALKTYPE_MONSTER_SAY, false, player, Position(33189, 31788, 7))
	player:sayLocalized("scripts.movements_destroy_pies.say_1", TALKTYPE_MONSTER_SAY, false, player, Position(33193, 31788, 7))
	return true
end

destroyPies:type("stepin")
destroyPies:aid(4201)
destroyPies:register()
