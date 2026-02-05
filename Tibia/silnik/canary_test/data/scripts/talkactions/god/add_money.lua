-- /addmoney playername, 100000

local addMoney = TalkAction("/addmoney")

function addMoney.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Check the first param (player name) exists
	if param == "" then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.god.add_money.param_required")
		-- Distro log
		logger.error("[addMoney.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")
	local name = split[1]:trim()

	local normalizedName = Game.getNormalizedPlayerName(name)
	if not normalizedName then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.god.add_money.player_not_exist")
		return true
	end
	name = normalizedName

	local amount = nil
	if split[2] then
		amount = tonumber(split[2])
	end

	-- Check if the coins is valid
	if amount <= 0 or amount == nil then
		player:sendLocalizedMessage(MESSAGE_FAILURE, "talkactions.god.add_money.invalid_amount")
		return true
	end

	if not Bank.credit(name, amount) then
		player:sendLocalizedTextMessage(MESSAGE_FAILURE, "talkactions.god.add_money.failed", {name})
		-- Distro log
		logger.error("[addMoney.onSay] - Failed to add money to player")
		return true
	end

	player:sendLocalizedMessage(MESSAGE_EVENT_ADVANCE, "scripts.add_money.msg_1")
	local targetPlayer = Player(name)
	if targetPlayer then
		targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE, "" .. player:getName() .. " added " .. amount .. " gold coins to your character.")
	end
	-- Distro log
	logger.info("{} added {} gold coins to {} player", player:getName(), amount, name)
	return true
end

addMoney:separator(" ")
addMoney:groupType("god")
addMoney:register()
