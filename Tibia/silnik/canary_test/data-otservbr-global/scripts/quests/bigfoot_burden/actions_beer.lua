local bigfootBeer = Action()
function bigfootBeer.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer) == 1 then
		player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.NeedsBeer, 0)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.mind_refreshed")
	end

	player:sayLocalized("scripts.actions_beer.say_1", TALKTYPE_MONSTER_SAY)
	item:remove(1)
	return true
end

bigfootBeer:id(15794)
bigfootBeer:register()
