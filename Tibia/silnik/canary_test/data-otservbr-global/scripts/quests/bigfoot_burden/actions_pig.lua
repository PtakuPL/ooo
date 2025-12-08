local bigfootPig = Action()
function bigfootPig.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.itemid ~= 15830 then
		return false
	end

	local mushroomCount = player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount)
	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionMushroomDigger) ~= 1 then
		return false
	end

	if mushroomCount == 3 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.pig_stuffed")
		return true
	end

	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.MushroomCount, mushroomCount + 1)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.pig_eating")
	target:transform(15701)
	toPosition:sendMagicEffect(CONST_ME_GROUNDSHAKER)
	return true
end

bigfootPig:id(15828)
bigfootPig:register()
