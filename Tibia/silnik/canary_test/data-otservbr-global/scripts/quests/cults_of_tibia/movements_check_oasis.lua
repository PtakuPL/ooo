local checkOasis = MoveEvent()

function checkOasis.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission) == 2 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_check_oasis.msg_1")
		player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Life.Mission, 3)
	end
	return true
end

checkOasis:type("stepin")
checkOasis:aid(5560)
checkOasis:register()
