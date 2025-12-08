local gnomeOrdnance = MoveEvent()

function gnomeOrdnance.onStepIn(creature, position, fromPosition, toPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance) == 1 then
		player:setStorageValue(Storage.Quest.U11_50.DangerousDepths.Gnomes.Ordnance, 2)
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_gnome_ordnance.msg_1")
	end
	return true
end

gnomeOrdnance:type("stepin")
gnomeOrdnance:aid(57241)
gnomeOrdnance:register()
