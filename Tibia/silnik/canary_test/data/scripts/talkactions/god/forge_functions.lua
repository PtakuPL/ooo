local addDusts = TalkAction("/adddusts")
function addDusts.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.player_name_required")
		-- Distro log
		logger.error("[addDusts.onSay] - Player name param not found.")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.forge_functions.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[addDusts.onSay] - Player {} is not online.", string.titleCase(name))
		return true
	end

	local dustAmount = nil
	if split[2] then
		dustAmount = tonumber(split[2])
	end

	-- Check if the dustAmount is valid
	if dustAmount <= 0 or dustAmount == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.invalid_dust_count")
		return true
	end

	-- Check dust level
	local finalDustAmount = targetPlayer:getForgeDusts() + dustAmount
	if finalDustAmount > targetPlayer:getForgeDustLevel() then
		dustAmount = targetPlayer:getForgeDustLevel() - targetPlayer:getForgeDusts()
	end

	targetPlayer:addForgeDusts(dustAmount)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.added_dusts_admin", {tostring(dustAmount), targetPlayer:getName()})
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.added_dusts_player", {player:getName(), tostring(dustAmount)})
	-- Distro log
	logger.info("{} added {} dusts to {} player.", player:getName(), dustAmount, targetPlayer:getName())
	return true
end

addDusts:separator(" ")
addDusts:groupType("god")
addDusts:register()

---------------- // ----------------
local removeDusts = TalkAction("/removedusts")

function removeDusts.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.player_name_required")
		-- Distro log
		logger.error("[removeDusts.onSay] - Player name param not found.")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.forge_functions.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[removeDusts.onSay] - Player {} is not online.", string.titleCase(name))
		return true
	end

	local dustAmount = nil
	if split[2] then
		dustAmount = tonumber(split[2])
	end

	-- Check if the dustAmount is valid
	if dustAmount <= 0 or dustAmount == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.invalid_dust_count")
		return true
	end

	-- Check dust level
	finalDustAmount = targetPlayer:getForgeDusts() - dustAmount
	if finalDustAmount < 0 then
		dustAmount = targetPlayer:getForgeDusts()
	end

	targetPlayer:removeForgeDusts(dustAmount)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.removed_dusts_admin", {tostring(dustAmount), targetPlayer:getName()})
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.removed_dusts_player", {player:getName(), tostring(dustAmount)})
	-- Distro log
	logger.info("{} removed {} dusts to {} player.", player:getName(), dustAmount, targetPlayer:getName())
	return true
end

removeDusts:separator(" ")
removeDusts:groupType("god")
removeDusts:register()

---------------- // ----------------
local getDusts = TalkAction("/getdusts")

function getDusts.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.player_name_required")
		-- Distro log
		logger.error("[getDusts.onSay] - Player name param not found.")
		return true
	end

	-- Check if player is online
	local split = param:split(",")
	local name = split[1]
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.forge_functions.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[getDusts.onSay] - Player {} is not online.", string.titleCase(name))
		return true
	end

	local dustAmount = targetPlayer:getForgeDusts()
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.player_has_dusts", {targetPlayer:getName(), tostring(dustAmount)})
	-- Distro log
	logger.info("{} has {} dusts.", targetPlayer:getName(), dustAmount)
	return true
end

getDusts:separator(" ")
getDusts:groupType("god")
getDusts:register()

---------------- // ----------------
local setDusts = TalkAction("/setdusts")

function setDusts.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.player_name_required")
		-- Distro log
		logger.error("[setDusts.onSay] - Player name param not found.")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.forge_functions.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[setDusts.onSay] - Player {} is not online.", string.titleCase(name))
		return true
	end

	local dustAmount = nil
	if split[2] then
		dustAmount = tonumber(split[2])
	end

	-- Check if the dustAmount is valid
	if dustAmount <= 0 or dustAmount == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.invalid_dust_count")
		return true
	end

	-- Check dust level
	if dustAmount > targetPlayer:getForgeDustLevel() then
		dustAmount = targetPlayer:getForgeDustLevel()
	end

	targetPlayer:setForgeDusts(dustAmount)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.set_dusts_admin", {tostring(dustAmount), targetPlayer:getName()})
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.set_dusts_player", {player:getName(), tostring(dustAmount)})
	-- Distro log
	logger.info("{} set {} dusts to {} player.", player:getName(), dustAmount, targetPlayer:getName())
	return true
end

setDusts:separator(" ")
setDusts:groupType("god")
setDusts:register()

---------------- // ----------------
-- Goto fiendish monster
local gotoFiendish = TalkAction("/fiendish")

function gotoFiendish.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local monster = Monster(ForgeMonster:pickFiendish())
	if monster then
		player:teleportTo(monster:getPosition())
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.no_fiendish_monsters")
	end
	return true
end

gotoFiendish:groupType("god")
gotoFiendish:register()

---------------- // ----------------
-- Goto influenced monster
local gotoInfluenced = TalkAction("/influenced")

function gotoInfluenced.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local monster = Monster(ForgeMonster:pickInfluenced())
	if monster then
		player:teleportTo(monster:getPosition())
	else
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.no_influenced_monsters")
	end
	return true
end

gotoInfluenced:groupType("god")
gotoInfluenced:register()

---------------- // ----------------
-- Set a new fiendish monster
local setFiendish = TalkAction("/setfiendish")

function setFiendish.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	return player:setFiendish()
end

setFiendish:groupType("god")
setFiendish:register()

---------------- // ----------------
-- Open forge window
local forge = TalkAction("/openforge")

function forge.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	return player:openForge()
end

forge:groupType("god")
forge:register()

---------------- // ----------------
-- Add dust level
local addDustLevel = TalkAction("/adddustlevel")

function addDustLevel.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.player_name_required")
		-- Distro log
		logger.error("[addDustLevel.onSay] - Player name param not found.")
		return true
	end

	local split = param:split(",")
	local name = split[1]

	-- Check if player is online
	local targetPlayer = Player(name)
	if not targetPlayer then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "god.forge_functions.player_not_online", {string.titleCase(name)})
		-- Distro log
		logger.error("[addDustLevel.onSay] - Player {} is not online.", string.titleCase(name))
		return true
	end

	local dustLevel = nil
	if split[2] then
		dustLevel = tonumber(split[2])
	end

	-- Check if the dustAmount is valid
	if dustLevel <= 0 or dustLevel == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "god.forge_functions.invalid_dust_level")
		return true
	end

	targetPlayer:addForgeDustLevel(dustLevel)
	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.added_dust_level_admin", {tostring(dustLevel), targetPlayer:getName()})
	targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "god.forge_functions.added_dust_level_player", {player:getName(), tostring(dustLevel)})
	-- Distro log
	logger.info("{} added {} dust level to {} player.", player:getName(), dustLevel, targetPlayer:getName())
	return true
end

addDustLevel:separator(" ")
addDustLevel:groupType("god")
addDustLevel:register()
