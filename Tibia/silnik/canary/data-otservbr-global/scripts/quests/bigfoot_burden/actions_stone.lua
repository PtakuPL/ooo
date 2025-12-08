local bigfootStone = Action()
function bigfootStone.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GrindstoneStatus) == 1 or player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionGrindstoneHunt) ~= 1 then
		return false
	end

	toPosition:sendMagicEffect(CONST_ME_HITBYFIRE)
	item:transform(15824)

	if math.random(15) <= 12 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.stone_no_luck")
		return true
	end

	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.GrindstoneStatus, 1)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.stone_success")
	player:addItem(15826, 1)
	return true
end

bigfootStone:id(15825)
bigfootStone:register()
