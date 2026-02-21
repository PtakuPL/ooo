-- Arena PvP EventCallback: prevent death in arena
-- Uses creatureOnDrainHealth to intercept lethal damage
-- and playerOnLoseExperience to prevent exp loss
-- Uses i18n key for death message

-- Intercept damage that would kill an arena participant
local arenaHealth = EventCallback("ArenaPreventDeath")

function arenaHealth.creatureOnDrainHealth(creature, attacker, primaryDamage, primaryType, secondaryDamage, secondaryType, origin)
	if not creature then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local player = creature:getPlayer()
	if not player or not player:arenaIsInArena() then
		return primaryDamage, primaryType, secondaryDamage, secondaryType
	end

	local totalDamage = primaryDamage + secondaryDamage
	local currentHp = player:getHealth()

	-- If this damage would kill the player, prevent death
	if totalDamage >= currentHp then
		-- Notify the player
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.death.message")

		-- Record last match timestamp for cooldown
		player:setStorageValue(ArenaConfig.storage.lastArenaMatch, os.time())

		-- Set HP to 1 (prevent death) and return 0 damage
		player:addHealth(player:getMaxHealth())

		-- Trigger arena death logic (teleport out, count as death in match)
		if Arena and Arena.onPlayerDeath then
			Arena.onPlayerDeath(player, attacker)
		end

		return 0, primaryType, 0, secondaryType
	end

	return primaryDamage, primaryType, secondaryDamage, secondaryType
end

arenaHealth:register()

-- Prevent experience loss in arena
local arenaExpLoss = EventCallback("ArenaPreventExpLoss")

function arenaExpLoss.playerOnLoseExperience(player, experience)
	if not player then
		return experience
	end

	if player:arenaIsInArena() then
		return 0
	end

	return experience
end

arenaExpLoss:register()
