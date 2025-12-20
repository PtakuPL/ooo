local quaidDen = MoveEvent()

function quaidDen.onStepIn(creature, item, position, fromPosition)
	if creature:isMonster() then
		return true
	end

	if creature:getStorageValue(Storage.Quest.U12_20.GraveDanger.CustodianKilled) < 1 then
		creature:teleportTo(Position(33401, 32658, 3))
		creature:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "quests.movements_quaidden.msg_1")
	end

	return true
end

quaidDen:id(31636)
quaidDen:register()
