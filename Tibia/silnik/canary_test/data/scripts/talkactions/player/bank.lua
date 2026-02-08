local config = {
	enabled = true,
	messageStyle = MESSAGE_LOOK,
}

if not config.enabled then
	return
end

local balance = TalkAction("!balance")

function balance.onSay(player, words, param)
	player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.balance", { FormatNumber(Bank.balance(player)) })
	return true
end

balance:separator(" ")
balance:groupType("normal")
balance:register()

local deposit = TalkAction("!deposit")

function deposit.onSay(player, words, param)
	local amount
	if param == "all" then
		amount = player:getMoney()
	else
		amount = tonumber(param)
		if not amount or amount <= 0 and isValidMoney(amount) then
			player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_2")
			return true
		end
	end

	if not Bank.deposit(player, amount) then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_3")
		return true
	end

	player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.deposit_success", { FormatNumber(amount) })
	return true
end

deposit:separator(" ")
deposit:groupType("normal")
deposit:register()

local withdraw = TalkAction("!withdraw")

function withdraw.onSay(player, words, param)
	local amount = tonumber(param)
	if not amount or amount <= 0 and isValidMoney(amount) then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_5")
		return true
	end

	if not Bank.withdraw(player, amount) then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_6")
		return true
	end

	player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.withdraw_success", { FormatNumber(amount) })
	return true
end

withdraw:separator(" ")
withdraw:groupType("normal")
withdraw:register()

local transfer = TalkAction("!transfer")

function transfer.onSay(player, words, param)
	local split = param:split(",")
	local amount = tonumber(split[2])
	if not amount or amount <= 0 and isValidMoney(amount) then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_8")
		return true
	end

	local name = split[1]
	if not name then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_9")
		return true
	end
	name = name:trim()
	local normalizedName = Game.getNormalizedPlayerName(name)
	if not normalizedName then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.player_not_exists", { name })
		return true
	end
	name = normalizedName

	if not player:transferMoneyTo(name, amount) then
		player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.msg_11")
		return true
	end

	player:sendLocalizedTextMessage(config.messageStyle, "scripts.bank.transfer_success", { FormatNumber(amount), name })
	return true
end

transfer:separator(" ")
transfer:groupType("normal")
transfer:register()
