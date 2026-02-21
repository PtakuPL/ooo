-- Arena PvP EventCallback: on player death in arena
-- Handles death logic: no penalty, respawn, match tracking
-- Uses i18n key for death message

local callback = EventCallback("ArenaOnPlayerDeath")

function callback.playerOnDeath(player, corpse, killer, mostDamageKiller, lastHitUnjustified, mostDamageUnjustified)
	-- Check if player is in an arena match
	if not player:arenaIsInArena() then
		return true  -- Not in arena, use normal death logic
	end

	-- In arena: prevent normal death penalties
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.death.message")

	-- Record last match timestamp for cooldown
	player:setStorageValue(ArenaConfig.storage.lastArenaMatch, os.time())

	-- Return false to prevent normal death
	return false
end

callback:register()
