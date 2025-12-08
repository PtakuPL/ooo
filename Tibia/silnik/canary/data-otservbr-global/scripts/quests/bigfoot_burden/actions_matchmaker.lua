local bigfootMatch = Action()
function bigfootMatch.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid < 15809 and target.itemid > 15815 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MatchmakerStatus) == 1 or player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMatchmaker) ~= 1 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MatchmakerIdNeeded) ~= target.itemid then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.wrong_crystal")
		return true
	end

	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MatchmakerStatus, 1)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.matchmaker_complete")
	toPosition:sendMagicEffect(CONST_ME_HEARTS)
	item:remove()
	return true
end

bigfootMatch:id(15801)
bigfootMatch:register()
