local FireWall = MoveEvent()

function FireWall.onStepIn(creature, item, position, fromPosition)
	if creature:isMonster() then
		return true
	end

	if fromPosition.y == 32691 then
		if creature:getStorageValue(Storage.Quest.U12_20.GraveDanger.FireWall) >= 1 then
			creature:teleportTo(Position(position.x, position.y + 2, position.z))
		else
			creature:teleportTo(fromPosition)
		end
	elseif fromPosition.y == 32693 then
		creature:teleportTo(Position(position.x, position.y - 2, position.z))
	elseif fromPosition.x == 33385 then
		if creature:getStorageValue(Storage.Quest.U12_20.GraveDanger.CustodianKilled) >= 1 then
			creature:setStorageValue(Storage.Quest.U12_20.GraveDanger.FireWall, 1)
			creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_cobra_mini_bosses.msg_1")
		else
			creature:teleportTo(fromPosition)
		end
		creature:teleportTo(Position(position.x + 2, position.y, position.z))
	elseif fromPosition.x == 33387 then
		creature:teleportTo(Position(position.x - 2, position.y, position.z))
	end
	creature:getPosition():sendMagicEffect(CONST_ME_HITBYFIRE)

	return true
end

FireWall:aid(36568)
FireWall:register()
