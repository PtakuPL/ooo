local necrometerTileAccess = MoveEvent()

function necrometerTileAccess.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	if player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission04) == 1 and player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission05) < 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_necrometer_tile_access.msg_1")
		player:setStorageValue(Storage.Quest.U10_50.DarkTrails.Mission05, 1) -- Start mission 5
	elseif player:getStorageValue(Storage.Quest.U10_50.DarkTrails.Mission10) >= 1 and player:getItemCount(21124) > 0 then
		player:teleportTo({ x = 33419, y = 32106, z = 10 })
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_necrometer_tile_access.msg_2")
	end

	return true
end

necrometerTileAccess:aid(25001)
necrometerTileAccess:register()
