local bigfootRepair = Action()
function bigfootRepair.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target:isMonster() then
		return false
	end

	if target:getName():lower() ~= "damaged crystal golem" then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.MissionTinkersBell) ~= 1 then
		return false
	end

	if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GolemCount) >= 4 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.golems_enough")
		return true
	end

	player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.GolemCount, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.GolemCount) + 1)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.bigfoot_burden.golem_returned")
	target:remove()
	player:getPosition():sendMagicEffect(CONST_ME_ENERGYHIT)

	return true
end

bigfootRepair:id(15832)
bigfootRepair:register()
