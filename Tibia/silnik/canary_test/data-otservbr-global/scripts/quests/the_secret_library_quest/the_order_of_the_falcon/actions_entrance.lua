local actions_entrance = Action()

function actions_entrance.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if (target == nil) or not target:isItem() then
		return false
	end

	local currentTime = os.date("*t")
	local currentMinute = currentTime.min

	local isNightTime = (currentMinute >= 45 or currentMinute < 15)

	if isNightTime then
		if target:getPosition() == Position(33201, 31763, 1) then
			player:teleportTo(Position(33356, 31309, 4), true)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_entrance.msg_2")
			item:transform(2873, 0)
		end
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.actions_entrance.msg_1")
	end

	return true
end

actions_entrance:id(28468)
actions_entrance:register()
