local bigfootExtractor = Action()
function bigfootExtractor.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local extractedCount = player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount)
	if extractedCount == 7 or player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionRaidersOfTheLostSpark) ~= 1 then
		return false
	end

	if target.itemid == 16197 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.body_not_ready")
		return true
	end

	if target.itemid ~= 16194 then
		return false
	end

	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.ExtractedCount, math.max(0, extractedCount) + 1)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.spark_gathered")
	target:transform(16195)
	toPosition:sendMagicEffect(CONST_ME_ENERGYHIT)
	return true
end

bigfootExtractor:id(15696)
bigfootExtractor:register()
