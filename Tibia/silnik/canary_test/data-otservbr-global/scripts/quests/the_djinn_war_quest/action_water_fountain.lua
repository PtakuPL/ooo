local action_water_fountain = Action()

function action_water_fountain.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02) ~= 1 then
		return true
	end

	Game.createItem(3233, 1, fromPosition)
	player:setStorageValue(Storage.Quest.U7_4.DjinnWar.EfreetFaction.Mission02, 2)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.action_water_fountain.msg_1")
	return true
end

action_water_fountain:aid(12105)
action_water_fountain:register()
