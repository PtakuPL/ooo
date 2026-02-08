local afk = TalkAction("/afk")

playersAFKs = {}

local function checkIsAFK(id)
	for index, item in pairs(playersAFKs) do
		if id == item.id then
			return { afk = true, index = index }
		end
	end
	return { afk = false }
end

local function showAfkMessage(playerPosition)
	local spectators = Game.getSpectators(playerPosition, false, true, 8, 8, 8, 8)
	if #spectators > 0 then
		for _, spectator in ipairs(spectators) do
			spectator:sayLocalized("scripts.afk.say_1", TALKTYPE_MONSTER_SAY, false, spectator, playerPosition)
		end
	end
end

function afk.onSay(player, words, param)
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_on_off_required")
		return true
	end

	local id, playerPosition = player:getId(), player:getPosition()
	local isAfk = checkIsAFK(id)
	if param == "on" then
		if isAfk.afk then
			player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.gm.afk.msg_already_afk")
			return true
		end

		table.insert(playersAFKs, { id = id, position = playerPosition })
		if player:isInGhostMode() then
			player:setGhostMode(false)
		end
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.afk.msg_1")
		playerPosition:sendMagicEffect(CONST_ME_REDSMOKE)
		showAfkMessage(playerPosition)
	elseif param == "off" then
		if isAfk.afk then
			table.remove(playersAFKs, isAfk.index)
			player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.afk.msg_2")
			playerPosition:sendMagicEffect(CONST_ME_REDSMOKE)
		end
	end

	return true
end

afk:separator(" ")
afk:groupType("gamemaster")
afk:register()

------------------ AFK Effect Message ------------------
local afkEffect = GlobalEvent("GodAfkEffect")
function afkEffect.onThink(interval)
	for _, player in ipairs(playersAFKs) do
		showAfkMessage(player.position)
	end
	return true
end

afkEffect:interval(5000)
afkEffect:register()

------------------ Stop AFK Message when moves ------------------
local callback = EventCallback("PlayerOnWalk")
function callback.playerOnWalk(player, creature, creaturePos, toPos)
	local isAfk = checkIsAFK(player:getId())
	if isAfk.afk then
		table.remove(playersAFKs, isAfk.index)
		player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.afk.msg_3")
	end
	return true
end

callback:register()

------------------ Player Logout ------------------
local godAfkLogout = CreatureEvent("GodAfkLogout")
function godAfkLogout.onLogout(player)
	local isAfk = checkIsAFK(player:getId())
	if isAfk.afk then
		table.remove(playersAFKs, isAfk.index)
	end
	return true
end

godAfkLogout:register()
