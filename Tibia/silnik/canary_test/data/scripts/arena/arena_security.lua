-- Arena PvP - Security & Anti-Cheat Rules
-- Phase 8.1: In-match restrictions
-- Blocks: party changes, item movement of banned items during match,
--         AFK detection, exp/item loss
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json
--
-- NOTE: Some restrictions (spell blocking, item use blocking, skull blocking,
-- logout blocking) require EventCallback types that do not exist in Canary yet
-- (playerOnSpellCheck, playerOnItemUse, playerOnGainSkullTicks, playerOnLogout).
-- These will be implemented when C++ support for those callbacks is added.
-- For now we use the available callbacks: partyOnJoin, playerOnMoveItem,
-- playerOnMoveCreature, creatureOnTargetCombat.

-- ============================================
-- 1. Block party join during arena match
-- ============================================
local blockParty = EventCallback("ArenaBlockPartyJoin")

function blockParty.partyOnJoin(party, player)
	if not player or not player:arenaIsInArena() then
		return true
	end

	-- In arena: block party changes
	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.security.party_blocked")
	return false
end

blockParty:register()

-- ============================================
-- 2. Block moving banned items during arena match
-- ============================================
local blockItems = EventCallback("ArenaBlockItemMove")

-- Items that cannot be moved/equipped during arena matches
local bannedItemIds = {
	-- Teleport items
	[2195] = true, -- Magic Carpet
	[19202] = true, -- Sweet Smelling Bait
	-- Training weapons (unfair advantage if used for healing exploit)
	[28552] = true, -- Exercise Sword
	[28553] = true, -- Exercise Axe
	[28554] = true, -- Exercise Club
	[28555] = true, -- Exercise Bow
	[28556] = true, -- Exercise Rod
	[28557] = true, -- Exercise Wand
}

function blockItems.playerOnMoveItem(player, item, count, fromPosition, toPosition, fromCylinder, toCylinder)
	if not player or not player:arenaIsInArena() then
		return true
	end

	if bannedItemIds[item:getId()] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.security.item_blocked")
		return false
	end

	return true
end

blockItems:register()

-- ============================================
-- 3. AFK Detection & Force-Loss Timer
-- ============================================
local ArenaAFK = {}
ArenaAFK.playerLastAction = {} -- playerId -> timestamp
ArenaAFK.warnings = {} -- playerId -> warning count

local afkChecker = GlobalEvent("ArenaAFKChecker")

function afkChecker.onThink(interval)
	-- ArenaConfig is defined in data/libs/systems/arena.lua
	if not ArenaConfig or not ArenaConfig.enabled then
		return true
	end

	local afkTimeout = ArenaConfig.afkTimeout or 60

	for _, player in ipairs(Game.getPlayers()) do
		if player:arenaIsInArena() then
			local playerId = player:getGuid()
			local lastAction = ArenaAFK.playerLastAction[playerId]

			if not lastAction then
				ArenaAFK.playerLastAction[playerId] = os.time()
			else
				local idle = os.time() - lastAction

				-- Warning at 30s
				if idle >= (afkTimeout / 2) and (ArenaAFK.warnings[playerId] or 0) < 1 then
					local remaining = afkTimeout - idle
					player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE,
						"arena.security.afk_warning", {tostring(remaining)})
					ArenaAFK.warnings[playerId] = 1

				-- Force-loss at timeout
				elseif idle >= afkTimeout then
					player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.security.afk_loss")

					-- Trigger arena logout (counts as loss)
					Arena.onPlayerLogout(player)

					-- Cleanup
					ArenaAFK.playerLastAction[playerId] = nil
					ArenaAFK.warnings[playerId] = nil
				end
			end
		else
			-- Cleanup if not in arena
			local playerId = player:getGuid()
			ArenaAFK.playerLastAction[playerId] = nil
			ArenaAFK.warnings[playerId] = nil
		end
	end
	return true
end

afkChecker:interval(5000) -- Check every 5 seconds
afkChecker:register()

-- Track player actions to reset AFK timer
local afkTracker = EventCallback("ArenaAFKTracker")

function afkTracker.playerOnMoveCreature(player, creature, fromPosition, toPosition)
	if player and player:arenaIsInArena() then
		ArenaAFK.playerLastAction[player:getGuid()] = os.time()
		ArenaAFK.warnings[player:getGuid()] = 0
	end
	return true
end

afkTracker:register()

-- Track combat actions for AFK
local afkCombatTracker = EventCallback("ArenaAFKCombatTracker")

function afkCombatTracker.creatureOnTargetCombat(creature, target)
	if creature then
		local player = creature:getPlayer()
		if player and player:arenaIsInArena() then
			ArenaAFK.playerLastAction[player:getGuid()] = os.time()
			ArenaAFK.warnings[player:getGuid()] = 0
		end
	end
	return RETURNVALUE_NOERROR
end

afkCombatTracker:register()

-- ============================================
-- 5. Prevent experience loss in arena (replaces skull blocking)
-- ============================================
local blockExpLoss = EventCallback("ArenaBlockExpLoss")

function blockExpLoss.playerOnLoseExperience(player, experience)
	if not player then
		return experience
	end

	-- No experience lost in arena
	if player:arenaIsInArena() then
		return 0
	end

	return experience
end

blockExpLoss:register()

-- ============================================
-- 6. Warn player on logout during arena match
-- (playerOnLogout callback does not exist in Canary;
--  Arena.onPlayerLogout in C++ handles the actual loss logic)
-- ============================================

-- Export for use by other scripts
_G.ArenaAFK = ArenaAFK
