local lockPick = Action()

function lockPick.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if target.actionid ~= 12503 then
		return false
	end

	if math.random(100) <= 30 then
		if player:getStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02) == 1 then
			player:addItem(227, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheThievesGuildQuest.Mission02, 2)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.lock_pick.msg_1")
		end
	else
		item:remove(1)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.lock_pick.msg_2")
	end
	return true
end

lockPick:id(7889)
lockPick:register()
