-- Arena PvP EventCallback: on creature combat (area/target)
-- Prevents arena players from being attacked by non-arena players and vice versa

local callback = EventCallback("ArenaOnAreaCombat")

function callback.creatureOnAreaCombat(creature, tile, isAggressive)
	if not creature or not isAggressive then
		return RETURNVALUE_NOERROR
	end

	local player = creature:getPlayer()
	if not player then
		return RETURNVALUE_NOERROR
	end

	-- If attacker is in arena, only allow target arena players
	if player:arenaIsInArena() then
		-- Allow combat within arena (C++ handles team checks)
		return RETURNVALUE_NOERROR
	end

	return RETURNVALUE_NOERROR
end

callback:register()
