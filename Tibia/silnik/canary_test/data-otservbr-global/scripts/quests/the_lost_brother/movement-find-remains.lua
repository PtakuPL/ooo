local findRemains = MoveEvent()

function findRemains.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest) == 1 then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movement-find-remains.msg_1")
		player:setStorageValue(Storage.Quest.U10_80.TheLostBrotherQuest, 2)
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end

	return true
end

findRemains:position(Position(32959, 32674, 4))
findRemains:register()
