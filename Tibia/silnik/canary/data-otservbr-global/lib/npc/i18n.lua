if not NPC_LIB then
	NPC_LIB = {}
end

NPC_LIB.i18n = NPC_LIB.i18n or {}

local DEFAULT_MESSAGE_CLASS = MESSAGE_EVENT_ADVANCE

local function normalizeArgs(args)
	if args == nil then
		return nil
	end

	if type(args) == "table" then
		return args
	end

	return { tostring(args) }
end

---Sends a localized message to the player on behalf of an NPC.
-- @param player The target player instance.
-- @param key i18n key (e.g. "npc.a_beautiful_girl.greet").
-- @param args Table or single value passed to the translator.
-- @param messageClass Optional MessageClasses value (defaults to MESSAGE_EVENT_ADVANCE).
function NPC_LIB.i18n.sayLocalized(player, key, args, messageClass)
	if not player or not key then
		return false
	end

	player:sendLocalizedTextMessage(messageClass or DEFAULT_MESSAGE_CLASS, key, normalizeArgs(args))
	return true
end

---Utility helper for NPC scripts: resolves whether an interaction should
-- fallback to default English text or already has a localized key.
-- For now it simply checks that the key exists and logs a warning.
function NPC_LIB.i18n.ensureKeyExists(key)
	if not key or key == "" then
		print("[NPC I18N] Missing key reference.")
		return false
	end

	-- TODO: once Translator bindings are available in Lua, query translator to verify presence.
	return true
end

return NPC_LIB.i18n
