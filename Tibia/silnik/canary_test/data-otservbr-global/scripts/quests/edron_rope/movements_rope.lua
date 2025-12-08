local rope = MoveEvent()

function rope.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	if player:getStorageValue(Storage.EdronRopeQuest) >= os.time() then
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.movements_rope.msg_1")
	player:setStorageValue(Storage.EdronRopeQuest, os.time() + 30)
	return true
end

rope:type("stepin")
rope:aid(4254)
rope:register()
