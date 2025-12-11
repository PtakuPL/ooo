-- data/libs/i18n_wrappers.lua
-- Wrappers for i18n functionality to be used by worker-migrated files
-- This file provides NPC_LIB.i18n functions that the worker generates code for

-- Initialize NPC_LIB global if not exists
NPC_LIB = NPC_LIB or {}
NPC_LIB.i18n = NPC_LIB.i18n or {}

--- Send a localized NPC message to player
-- @param npcHandler The NPC handler object
-- @param npc The NPC entity
-- @param player The player to send message to
-- @param key The i18n key (e.g., "npc.oracle.greeting")
-- @param args Optional table of arguments for string formatting
function NPC_LIB.i18n.npcSay(npcHandler, npc, player, key, args)
	if not npcHandler or not npc or not player or not key then
		return false
	end
	
	-- Use npcHandler:sayLocalized if available (recommended)
	if npcHandler.sayLocalized then
		npcHandler:sayLocalized(key, npc, player, args or {})
		return true
	end
	
	-- Fallback: use player:sendLocalizedTextMessage directly
	local targetPlayer = Player(player)
	if targetPlayer then
		targetPlayer:sendLocalizedTextMessage(MESSAGE_NPC_FROM, key, args or {})
		return true
	end
	
	return false
end

--- Send multiple localized NPC messages to player (table of keys)
-- @param npcHandler The NPC handler object
-- @param npc The NPC entity
-- @param player The player to send message to
-- @param keys Table of i18n keys to send sequentially
-- @param args Optional table of arguments for string formatting
function NPC_LIB.i18n.npcSayTable(npcHandler, npc, player, keys, args)
	if not npcHandler or not npc or not player or not keys then
		return false
	end
	
	for _, key in ipairs(keys) do
		NPC_LIB.i18n.npcSay(npcHandler, npc, player, key, args)
	end
	
	return true
end

--- Get translated text for a key (useful for non-say operations)
-- @param key The i18n key
-- @param player The player (to get their language preference)
-- @param args Optional table of arguments for string formatting
-- @return The translated string
function NPC_LIB.i18n.get(key, player, args)
	-- This uses the server_i18n.lua t() function if available
	if t then
		return t(key, args, player)
	end
	
	-- Fallback: return the key itself
	return key
end

-- ============================================
-- Item i18n wrappers (for items with localized names/descriptions)
-- ============================================

--- Set localized description on an item
-- Uses player's language preference to translate
-- @param item The item to set description on
-- @param key The i18n key for the description
-- @param player The player viewing the item (for language preference)
function Item:setLocalizedDescription(key, player)
	if not self or not key then
		return false
	end
	
	local text = key
	if t and player then
		text = t(key, nil, player)
	end
	
	-- Use setAttribute for description
	self:setAttribute(ITEM_ATTRIBUTE_DESCRIPTION, text)
	return true
end

--- Set localized name on an item
-- @param item The item to set name on
-- @param key The i18n key for the name
-- @param player The player viewing the item (for language preference)
function Item:setLocalizedName(key, player)
	if not self or not key then
		return false
	end
	
	local text = key
	if t and player then
		text = t(key, nil, player)
	end
	
	self:setAttribute(ITEM_ATTRIBUTE_NAME, text)
	return true
end

-- ============================================
-- Creature i18n wrappers (if C++ sayLocalized not available)
-- ============================================

-- Note: creature:sayLocalized is now implemented in C++
-- This Lua wrapper is kept as fallback

--- Say localized message from creature
-- @param creature The creature speaking
-- @param key The i18n key
-- @param talkType The talk type (default TALKTYPE_MONSTER_SAY)
-- @param player Optional specific player to send to
-- @param args Optional arguments for formatting
function Creature:sayLocalizedLua(key, talkType, player, args)
	if not self or not key then
		return false
	end
	
	talkType = talkType or TALKTYPE_MONSTER_SAY
	
	-- If there's a specific player target
	if player then
		local targetPlayer = Player(player)
		if targetPlayer then
			targetPlayer:sendLocalizedTextMessage(MESSAGE_STATUS_DEFAULT, key, args or {})
			return true
		end
	end
	
	-- Broadcast to spectators
	local pos = self:getPosition()
	local spectators = Game.getSpectators(pos, false, true, 7, 7, 5, 5)
	
	for _, spectator in ipairs(spectators) do
		local specPlayer = spectator:getPlayer()
		if specPlayer then
			specPlayer:sendLocalizedTextMessage(MESSAGE_STATUS_DEFAULT, key, args or {})
		end
	end
	
	return true
end

-- ============================================
-- Game i18n wrappers
-- ============================================

-- Note: Game.broadcastLocalizedMessage is now implemented in C++
-- This Lua wrapper is kept as fallback

--- Broadcast localized message to all players (Lua fallback)
-- @param key The i18n key
-- @param messageType The message type (default MESSAGE_STATUS_WARNING)
-- @param args Optional arguments for formatting
function Game.broadcastLocalizedMessageLua(key, messageType, args)
	messageType = messageType or MESSAGE_STATUS_WARNING
	args = args or {}
	
	for _, player in ipairs(Game.getPlayers()) do
		player:sendLocalizedTextMessage(messageType, key, args)
	end
	
	return true
end

-- Log that i18n wrappers are loaded
print("[i18n] Wrappers loaded: NPC_LIB.i18n.npcSay, Item:setLocalizedDescription, creature:sayLocalized")
