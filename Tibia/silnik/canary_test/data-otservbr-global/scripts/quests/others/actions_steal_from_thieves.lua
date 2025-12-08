local chests = {
	[19910] = { itemid = 235 },
}

local othersSteal = Action()
function othersSteal.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if chests[item.uid] then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.StealFromThieves) > 1 then
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_steal_from_thieves.msg_1")
			return true
		end

		local chest = chests[item.uid]
		player:addItem(chest.itemid, 1)
		player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.StealFromThieves, 2)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_steal_from_thieves.msg_2")
	end

	return true
end

othersSteal:aid(19910)
othersSteal:register()
