-- /addmoney playername, 100000

local addMoney = TalkAction("/addmoney")

function addMoney.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.common.msg_player_name_param_required_dot")
		-- Distro log
		logger.error("[addMoney.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]:trim()

	local normalizedName = Game.getNormalizedPlayerName(name)
	if not normalizedName then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.money.msg_not_exists", {name})
		return true
	end
	name = normalizedName

	local amount = nil
	if split[2] then
		amount = tonumber(split[2])
	end

	-- Check if the coins is valid
	if amount <= 0 or amount == nil then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.money.msg_invalid_amount")
		return true
	end

	if not Bank.credit(name, amount) then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkaction.god.money.msg_failed", {name})
		-- Distro log
		logger.error("[addMoney.onSay] - Failed to add money to player")
		return true
	end

	player:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_money.msg_1" .. amount .. " gold coins to " .. name .. ".")
	local targetPlayer = Player(name)
	if targetPlayer then
		targetPlayer:sendLocalizedTextMessage(MESSAGE_EVENT_ADVANCE, "talkaction.god.money.msg_target", {player:getName(), amount})
	end
	-- Distro log
	logger.info("{} added {} gold coins to {} player", player:getName(), amount, name)
	return true
end

addMoney:separator(" ")
addMoney:groupType("god")
addMoney:register()
