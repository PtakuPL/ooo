local warzoneEntrance = MoveEvent()

function warzoneEntrance.onStepIn(creature, item, position, fromPosition, toPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local warzoneVI = Position(33367, 32307, 15)
	if item:getPosition() == Position(33829, 32128, 14) then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneVI) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneVI) <= os.time() then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneVI, 0)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneVI, os.time() + 8 * 60 * 60)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_1")
			player:teleportTo(warzoneVI)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneVI) ~= 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneVI) <= os.time() then
			player:teleportTo(Position(fromPosition.x + 1, fromPosition.y, fromPosition.z))
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_2")
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneVI) > os.time() then
			player:teleportTo(warzoneVI)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_3")
		end
	end

	local warzoneV = Position(33208, 32119, 15)
	if item:getPosition() == Position(33777, 32192, 14) then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneV) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneV) <= os.time() then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneV, 0)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneV, os.time() + 8 * 60 * 60)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_4")
			player:teleportTo(warzoneV)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneV) ~= 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneV) <= os.time() then
			player:teleportTo(Position(fromPosition.x, fromPosition.y + 1, fromPosition.z))
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_5")
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneV) > os.time() then
			player:teleportTo(warzoneV)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_6")
		end
	end

	local warzoneIV = Position(33534, 32184, 15)
	if item:getPosition() == Position(33827, 32172, 14) then
		if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneIV) == 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneIV) <= os.time() then
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneIV, 0)
			player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneIV, os.time() + 8 * 60 * 60)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_7")
			player:teleportTo(warzoneIV)
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.LavaPumpWarzoneIV) ~= 1 and player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneIV) <= os.time() then
			player:teleportTo(Position(fromPosition.x, fromPosition.y + 1, fromPosition.z))
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_8")
		elseif player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Access.TimerWarzoneIV) > os.time() then
			player:teleportTo(warzoneIV)
			player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_warzone_entrance.msg_9")
		end
	end

	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)

	return true
end

warzoneEntrance:type("stepin")
warzoneEntrance:aid(57230)
warzoneEntrance:register()
