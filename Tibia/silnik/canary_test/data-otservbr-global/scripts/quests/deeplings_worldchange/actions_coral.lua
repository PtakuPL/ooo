local crystaldeepling = Action()
function crystaldeepling.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local posMonster = player:getPosition()
	if player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 9 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_coral.msg_1")
		Game.createMonster("Deepling Worker", posMonster)
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 10)
	elseif player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 10 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_coral.msg_3")
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 11)
	elseif player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 11 then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_coral.msg_2")
		player:addItem(14165, 1)
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 12)
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_coral.msg_1")
	end
	return true
end

crystaldeepling:aid(28572)
crystaldeepling:register()
