local crystaldeepling = Action()
function crystaldeepling.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local posMonster = player:getPosition()
	if player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crystal.msg_1")
		Game.createMonster("Deepling Guard", posMonster)
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 2)
	elseif player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crystal.msg_2")
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 3)
	elseif player:getStorageValue(Storage.DeeplingsWorldChange.Crystal) == 3 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.actions_crystal.msg_3")
		player:addItem(14162, 1)
		player:setStorageValue(Storage.DeeplingsWorldChange.Crystal, 4)
	else
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Sorry.")
	end
	return true
end

crystaldeepling:aid(28570)
crystaldeepling:register()
