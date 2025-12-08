local portalReward = MoveEvent()

function portalReward.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return false
	end

	local soulWarQuest = player:soulWarQuestKV()
	-- Checks if the boss has already been defeated
	if not soulWarQuest:get("goshnar's-megalomania-killed") then
		player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.moveevent-teleport_entrance_reward.msg_1")
		player:teleportTo(fromPosition, true)
		return false
	end

	player:teleportTo(Position(33621, 31411, 10))
	player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

portalReward:position({ x = 33621, y = 31416, z = 10 })
portalReward:register()
