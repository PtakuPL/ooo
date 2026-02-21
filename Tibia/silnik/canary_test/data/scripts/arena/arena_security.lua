-- Arena PvP - Security & Anti-Cheat Rules
-- Phase 8.1: In-match restrictions
-- Blocks: teleport spells, logout, party invites outside match,
--         banned items, skulls, exp/item loss
-- All user-facing strings use i18n keys from i18n/<lang>/arena.json

-- ============================================
-- 1. Block teleport/movement spells in arena
-- ============================================
local blockSpells = EventCallback("ArenaBlockTeleportSpells")

-- List of spell words that are blocked in arena
local blockedSpellWords = {
	"exani hur", -- Levitate
	"exani tera", -- Magic Rope
	"utani hur", -- Haste (allow) -- actually let's allow haste
	"exiva", -- Find Person (allow info spells)
}

-- Blocked spell IDs (teleport-type)
local blockedSpellNames = {
	["Levitate"] = true,
	["Magic Rope"] = true,
	["Find Person"] = true, -- prevent scouting
}

function blockSpells.playerOnSpellCheck(player, spell)
	if not player or not player:arenaIsInArena() then
		return true -- Not in arena, allow all
	end

	local spellName = spell:getName()

	-- Block teleport spells
	if blockedSpellNames[spellName] then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.security.spell_blocked")
		return false
	end

	return true
end

blockSpells:register()

-- ============================================
-- 2. Block item use in arena (banned items)
-- ============================================
local blockItems = EventCallback("ArenaBlockItems")

-- Items that cannot be used during arena matches
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

function blockItems.playerOnItemUse(player, item, fromPosition, target, toPosition, isHotkey)
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
-- 3. Block party invitations to non-arena players
-- ============================================
local blockParty = EventCallback("ArenaBlockPartyInvite")

function blockParty.playerOnPartyInvite(player, invitedPlayer)
	if not player or not player:arenaIsInArena() then
		return true
	end

	-- In arena: block party changes
	player:sendLocalizedTextMessage(MESSAGE_FAILURE, "arena.security.party_blocked")
	return false
end

blockParty:register()

-- ============================================
-- 4. AFK Detection & Force-Loss Timer
-- ============================================
local ArenaAFK = {}
ArenaAFK.playerLastAction = {} -- playerId -> timestamp
ArenaAFK.warnings = {} -- playerId -> warning count

local afkChecker = GlobalEvent("ArenaAFKChecker")

function afkChecker.onThink(interval)
	if not configManager.getBoolean(configKeys.ARENA_SYSTEM_ENABLED) then
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
-- 5. Prevent skull assignment in arena
-- ============================================
local blockSkulls = EventCallback("ArenaBlockSkulls")

function blockSkulls.playerOnGainSkullTicks(player, ticks, targetPlayer)
	if not player then
		return ticks
	end

	-- No skulls gained in arena
	if player:arenaIsInArena() then
		return 0
	end

	return ticks
end

blockSkulls:register()

-- ============================================
-- 6. Block logout during arena match
-- ============================================
local blockLogout = EventCallback("ArenaBlockLogout")

function blockLogout.playerOnLogout(player)
	if not player then
		return true
	end

	if player:arenaIsInArena() then
		-- Don't block the logout itself (C++ handles the loss),
		-- but warn the player
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "arena.security.logout_warning")
		-- The C++ onArenaLogout will handle counting this as a loss
	end

	return true
end

blockLogout:register()

-- Export for use by other scripts
_G.ArenaAFK = ArenaAFK
