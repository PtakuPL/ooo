local get = TalkAction("/getkv")

function get.onSay(player, words, param)
	local key, playerName = string.splitFirst(param, ",")
	if not playerName then
		playerName = player:getName()
	end

	local targetPlayer = Player(playerName)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_player_not_found", {playerName})
		return
	end

	local value = targetPlayer:kv():get(key)
	if value then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_value", {key, playerName, PrettyString(value)})
	else
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_key_not_found", {key, playerName})
	end
end

get:separator(" ")
get:groupType("god")
get:register()

local getAllKV = TalkAction("/getallkv")

function getAllKV.onSay(player, words, param)
	local playerName = param
	if not playerName or playerName == "" then
		playerName = player:getName()
	end

	local targetPlayer = Player(playerName)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_player_not_found", {playerName})
		return
	end

	local kv = targetPlayer:kv()
	if not kv then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_1")
		return
	end

	local found = false
	local keys = kv:keys()
	if not keys then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_2")
		return
	end

	for _, key in ipairs(keys) do
		local value = kv:get(key)
		if type(value) == "number" and value >= 0 then
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_allkv_value", {key, PrettyString(value)})
			found = true
		end
	end

	if not found then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_3", { playerName })
	end
end

getAllKV:separator(" ")
getAllKV:groupType("god")
getAllKV:register()

local set = TalkAction("/setkv")

function set.onSay(player, words, param)
	local key, rest = string.splitFirst(param, ",")
	if not key or not rest then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_4")
		return false
	end

	local value, playerName = string.splitFirst(rest, ",")
	local targetPlayer = player
	if playerName then
		local creature = Creature(playerName)
		if creature and creature:isPlayer() then
			targetPlayer = creature:getPlayer()
		else
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_player_invalid", {playerName})
			return false
		end
	end
	local success, parsedValue = pcall(load("return " .. value))
	if not success then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_5")
		return false
	end
	local kv = targetPlayer:kv()
	if not kv then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_6")
		return false
	end
	kv:set(key, parsedValue)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_set", {key, PrettyString(parsedValue), targetPlayer:getName()})
	return true
end

set:separator(" ")
set:groupType("god")
set:register()

local bossCooldown = TalkAction("/clearcooldown")

function bossCooldown.onSay(player, words, param)
	local boss, playerName = string.splitFirst(param, ",")
	if not playerName then
		playerName = player:getName()
	end
	local targetPlayer = Player(playerName)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_player_not_found", {playerName})
		return
	end
	targetPlayer:setBossCooldown(boss, 0)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.manage_kv.msg_7", { playerName })
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.kv.msg_cooldown_cleared", {boss})
end

bossCooldown:separator(" ")
bossCooldown:groupType("god")
bossCooldown:register()
