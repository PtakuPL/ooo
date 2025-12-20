local gravediggerBook = Action()
function gravediggerBook.onUse(player, item, fromPosition, itemEx, toPosition)
	if player:getStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Bookcase) < 1 then
		player:setStorageValue(Storage.Quest.U10_10.TheGravediggerOfDrefia.Bookcase, 1)
		player:addItem(19158, 1)
		player:sayLocalized("scripts.actions_bookcase.say_2", TALKTYPE_MONSTER_SAY)
	else
		player:sayLocalized("scripts.actions_bookcase.say_1", TALKTYPE_MONSTER_SAY)
		return true
	end
	return true
end

gravediggerBook:aid(4669)
gravediggerBook:register()
