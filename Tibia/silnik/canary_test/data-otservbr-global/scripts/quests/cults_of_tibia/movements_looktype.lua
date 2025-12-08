local looktype = MoveEvent()

function looktype.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local firstCheck = Position(33135, 31859, 10)
	local secondCheck = Position(33128, 31885, 11)
	local thirdCheck = Position(33175, 31923, 12)
	if position == firstCheck or position == Position(firstCheck.x + 1, firstCheck.y, firstCheck.z) then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType) < 1 then
			if creature:getOutfit().lookType == 5 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_1")
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType, 1)
			else
				player:teleportTo(fromPosition, true)
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_2")
			end
		end
	end
	if position == secondCheck or position == Position(secondCheck.x + 1, secondCheck.y, secondCheck.z) then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType) < 2 then
			if creature:getOutfit().lookType == 2 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_3")
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType, 2)
			else
				player:teleportTo(fromPosition, true)
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_4")
			end
		end
	end
	if position == thirdCheck or position == Position(thirdCheck.x + 1, thirdCheck.y, thirdCheck.z) or position == Position(thirdCheck.x + 2, thirdCheck.y, thirdCheck.z) then
		if player:getStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType) < 3 then
			if creature:getOutfit().lookType == 6 then
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_5")
				player:setStorageValue(Storage.Quest.U11_40.CultsOfTibia.Orcs.LookType, 3)
			else
				player:teleportTo(fromPosition, true)
				player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_looktype.msg_6")
			end
		end
	end
	return true
end

looktype:type("stepin")
looktype:aid(5540)
looktype:register()
