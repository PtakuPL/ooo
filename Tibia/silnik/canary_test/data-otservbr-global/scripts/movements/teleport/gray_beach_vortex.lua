local config = {
	[9238] = Position(33456, 31346, 8),
	[9239] = Position(33199, 31978, 8),
}

local grayBeachVortex = MoveEvent()

function grayBeachVortex.onStepIn(creature, item, position, fromPosition)
	local player = creature:getPlayer()
	if not player then
		return true
	end

	local targetPosition = config[item.uid]
	if not targetPosition then
		return true
	end

	player:teleportTo(targetPosition)
	targetPosition:sendMagicEffect(CONST_ME_WATERSPLASH)
	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.gray_beach_vortex.msg_1")
	return true
end

grayBeachVortex:type("stepin")

for index, value in pairs(config) do
	grayBeachVortex:uid(index)
end

grayBeachVortex:register()
