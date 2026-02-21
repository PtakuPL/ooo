-- Arena PvP EventCallback: on player death in arena
-- Handles death logic: no penalty, respawn, match tracking

local callback = EventCallback("ArenaOnPlayerDeath")

function callback.playerOnDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	-- Check if player is in an arena match
	if not player:arenaIsInArena() then
		return true  -- Not in arena, use normal death logic
	end

	-- In arena: prevent normal death penalties
	-- The C++ hooks (onArenaDeath/onArenaKill) handle match state
	-- Here we handle Lua-side: block item loss, block exp loss, notify

	-- Send arena death message
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "[Arena] You have been slain!")

	-- Record last match timestamp for cooldown
	player:setStorageValue(ArenaConfig.storage.lastArenaMatch, os.time())

	-- Return false to prevent normal death (no corpse, no item drop, no exp loss)
	-- The C++ arena system handles respawn/teleport
	return false
end

callback:register()
