if not NPC_LIB then
	NPC_LIB = {}
end

NPC_LIB.i18n = NPC_LIB.i18n or {}

local DEFAULT_MESSAGE_CLASS = MESSAGE_EVENT_ADVANCE

local function defaultPlayerNameArgs()
	return function(player)
		if not player then
			return nil
		end
		return { player:getName() }
	end
end

local function normalizeArgs(args)
	if args == nil then
		return nil
	end

	if type(args) == "table" then
		return args
	end

	return { tostring(args) }
end

function NPC_LIB.i18n.sayLocalized(player, key, args, messageClass)
	if not player or not key then
		return false
	end

	player:sendLocalizedTextMessage(messageClass or DEFAULT_MESSAGE_CLASS, key, normalizeArgs(args))
	return true
end

function NPC_LIB.i18n.ensureKeyExists(key)
	if not key or key == "" then
		print("[NPC I18N] Missing key reference.")
		return false
	end
	return true
end

-- Helper function for NPC to say localized message through npcHandler
-- Resolves translation server-side, then uses npc:say() for proper NPC dialog window
-- Usage: NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key, args)
function NPC_LIB.i18n.npcSay(npcHandler, npc, creature, key, args)
	if not npcHandler or not npc or not creature then
		return false
	end

	local player = Player(creature)
	if not player then
		return false
	end

	-- Resolve translation server-side (strip language tags)
	local translatedMessage = stripI18nLanguageTags(player:getTranslation(key, normalizeArgs(args)))
	if not translatedMessage or translatedMessage == "" then
		translatedMessage = key -- fallback to key
	end

	-- Replace |PLAYERNAME| tag (normally done in SayEvent, but npcSay bypasses it)
	translatedMessage = translatedMessage:gsub("|PLAYERNAME|", player:getName() or "")

	-- Use npc:say with TALKTYPE_PRIVATE_NP to open NPC dialog window
	npc:say(translatedMessage, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
	return true
end

local function resolveSequenceEntry(entry)
	if type(entry) == "string" then
		return entry, nil, nil, nil
	end

	if type(entry) == "table" then
		local entryKey = entry.key or entry[1]
		local entryArgs = entry.args or entry[2]
		local entryClass = entry.messageClass or entry.class or entry[3]
		local entryDelay = entry.delay
		return entryKey, entryArgs, entryClass, entryDelay
	end

	return nil, nil, nil, nil
end

function NPC_LIB.i18n.setLocalizedMessage(npcHandler, messageId, key, options)
	if not npcHandler or not messageId or not key or key == "" then
		return false
	end

	options = options or {}
	if not npcHandler.setLocalizedMessage then
		return false
	end

	npcHandler:setLocalizedMessage(messageId, key, options)
	if not options.keepFallback then
		npcHandler:setMessage(messageId, options.fallback or "")
	end
	return true
end

function NPC_LIB.i18n.setLocalizedGreet(npcHandler, key, options)
	options = options or {}
	options.args = options.args or defaultPlayerNameArgs()
	return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, key, options)
end

function NPC_LIB.i18n.setLocalizedFarewell(npcHandler, key, options)
	options = options or {}
	options.args = options.args or defaultPlayerNameArgs()
	return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, key, options)
end

function NPC_LIB.i18n.setLocalizedWalkaway(npcHandler, key, options)
	options = options or {}
	options.args = options.args or defaultPlayerNameArgs()
	return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, key, options)
end

function NPC_LIB.i18n.setLocalizedTradeMessage(npcHandler, key, options)
	return NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_SENDTRADE, key, options)
end

-- Helper for NPC dialogue with multiple messages
-- Resolves translations server-side, then uses npc:say() for proper NPC dialog window
-- Usage: NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, keys, delay)
function NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, keys, delay)
	if not npcHandler or not npc or not creature or not keys then
		return false
	end

	local player = Player(creature)
	if not player then
		return false
	end

	for i, entry in ipairs(keys) do
		local key, args, messageClass, entryDelay = resolveSequenceEntry(entry)
		if key then
			local scheduledDelay = entryDelay
			if scheduledDelay == nil then
				scheduledDelay = (i - 1) * (delay or 100)
			end

			if scheduledDelay <= 0 then
				-- Resolve translation server-side and use npc:say (strip language tags)
				local translatedMessage = stripI18nLanguageTags(player:getTranslation(key, normalizeArgs(args)))
				if not translatedMessage or translatedMessage == "" then
					translatedMessage = key
				end
				translatedMessage = translatedMessage:gsub("|PLAYERNAME|", player:getName() or "")
				npc:say(translatedMessage, TALKTYPE_PRIVATE_NP, false, player, npc:getPosition())
			else
				addEvent(function(npcId, playerId, msgKey, msgArgs)
					local p = Player(playerId)
					local npcEntity = Npc(npcId)
					if p and npcEntity then
						local translatedMsg = stripI18nLanguageTags(p:getTranslation(msgKey, msgArgs))
						if not translatedMsg or translatedMsg == "" then
							translatedMsg = msgKey
						end
						translatedMsg = translatedMsg:gsub("|PLAYERNAME|", p:getName() or "")
						npcEntity:say(translatedMsg, TALKTYPE_PRIVATE_NP, false, p, npcEntity:getPosition())
					end
				end, scheduledDelay, npc:getId(), player:getId(), key, normalizeArgs(args))
			end
		end
	end
	return true
end

return NPC_LIB.i18n
