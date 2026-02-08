local count = {}
local transfer = {}
local receiptFormat = "Date: %s\nType: %s\nGold Amount: %d\nReceipt Owner: %s\nRecipient: %s\n\n%s"

local function GetReceipt(info)
	local receipt = Game.createItem(info.success and 19598 or 19599)
	receipt:setAttribute(ITEM_ATTRIBUTE_TEXT, receiptFormat:format(os.date("%d. %b %Y - %H:%M:%S"), info.type, info.amount, info.owner, info.recipient, info.message))

	return receipt
end

function Npc:parseBankMessages(message, npc, creature, npcHandler)
	local messagesTable = {
		["money"] = "We can {change} money for you. You can also access your {bank account}",
		["change"] = "There are three different coin types in Tibia: \z
                        100 gold coins equal 1 platinum coin, 100 platinum coins equal 1 crystal coin. \z
                        So if you'd like to change 100 gold into 1 platinum, \z
                        simply say '{change gold}' and then '1 platinum'",
		["bank"] = "We can {change} money for you. You can also access your {bank account}",
		["advanced"] = "Your bank account will be used automatically when you want to {rent} a house or place an offer \z
                            on an item on the {market}. Let me know if you want to know about how either one works",
		["help"] = "You can check the {balance} of your bank account, {deposit} money or {withdraw} it. \z
                        You can also {transfer} money to other characters, provided that they have a vocation",
		["functions"] = "You can check the {balance} of your bank account, {deposit} money or {withdraw} it. \z
                            You can also {transfer} money to other characters, provided that they have a vocation",
		["basic"] = "You can check the {balance} of your bank account, {deposit} money or {withdraw} it. \z
                        You can also {transfer} money to other characters, provided that they have a vocation",
		["job"] = "I work in this bank. I can {change money} for you and help you with your bank account",
		["bank account"] = {
			"Every Tibian has one. The big advantage is that you can access your money in every branch of the Tibian Bank! ...",
			"Would you like to know more about the {basic} functions of your bank account, the {advanced} functions, \z
                or are you already bored, perhaps?",
		},
	}

	npcHandler:sendMessages(message, messagesTable, npc, creature, true, 3000)
end

function Npc:parseBank(message, npc, creature, npcHandler)
	local player = Player(creature)
	local playerId = creature:getId()
	-- Balance
	if MsgContains(message, "guild") then
		return true
	end

	if MsgContains(message, "balance") then
		local balance = Bank.balance(player)
		if balance >= 100000000 then
			npcHandler:sayLocalized("npclib.bank_system.say_34", npc, creature, {balance})
			return true
		elseif balance >= 10000000 then
			npcHandler:sayLocalized("npclib.bank_system.say_33", npc, creature, {balance})
			return true
		elseif balance >= 1000000 then
			npcHandler:sayLocalized("npclib.bank_system.say_32", npc, creature, {balance})
			return true
		elseif balance >= 100000 then
			npcHandler:sayLocalized("npclib.bank_system.say_31", npc, creature, {balance})
			return true
		else
			npcHandler:sayLocalized("npclib.bank_system.say_30", npc, creature, {balance})
			return true
		end
		-- Deposit
	elseif MsgFind(message, "deposit all") then
		count[playerId] = player:getMoney()
		npcHandler:sayLocalized("npclib.bank_system.say_29", npc, creature, {count[playerId]})
		npcHandler:setTopic(playerId, 2)
	elseif MsgContains(message, "deposit") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:sayLocalized("npclib.bank_system.say_28", npc, creature, {count[playerId]})
				npcHandler:setTopic(playerId, 2)
			else
				npcHandler:sayLocalized("misc.bank_system.say_1", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		end
		count[playerId] = player:getMoney()
		npcHandler:sayLocalized("misc.bank_system.say_2", npc, creature)
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "all") then
		if npcHandler:getTopic(playerId) == 1 then
			count[playerId] = player:getMoney()
			npcHandler:sayLocalized("npclib.bank_system.say_27", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_26", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 2)
			return true
		else
			npcHandler:sayLocalized("misc.bank_system.say_3", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if Player.depositMoney(player, count[playerId]) then
				npcHandler:sayLocalized("npclib.bank_system.say_25", npc, creature, {count[playerId]})
			else
				npcHandler:sayLocalized("misc.bank_system.say_4", npc, creature)
			end
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_5", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
		-- Withdraw
	elseif MsgContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:sayLocalized("npclib.bank_system.say_24", npc, creature, {count[playerId]})
				npcHandler:setTopic(playerId, 7)
			else
				npcHandler:sayLocalized("misc.bank_system.say_6", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			npcHandler:sayLocalized("misc.bank_system.say_7", npc, creature)
			npcHandler:setTopic(playerId, 6)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_23", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 7)
		else
			npcHandler:sayLocalized("misc.bank_system.say_8", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			local totalValue = count[playerId]
			local crystalCoins = math.floor(totalValue / 10000)
			totalValue = totalValue % 10000
			local platinumCoins = math.floor(totalValue / 100)
			totalValue = totalValue % 100
			local goldCoins = math.floor(totalValue / 1)
			local crystalPiles = math.floor((crystalCoins + 99) / 100)
			local platinumPiles = math.floor((platinumCoins + 99) / 100)
			local goldPiles = math.floor((goldCoins + 99) / 100)
			local totalPiles = crystalPiles + platinumPiles + goldPiles
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if player:getFreeBackpackSlots() >= totalPiles then
					if not player:withdrawMoney(count[playerId]) then
						npcHandler:sayLocalized("misc.bank_system.say_9", npc, creature)
					else
						npcHandler:sayLocalized("npclib.bank_system.say_22", npc, creature, {count[playerId]})
					end
				else
					npcHandler:sayLocalized("npclib.bank_system.say_21", npc, creature, {crystalPiles, crystalCoins, platinumPiles, platinumCoins, goldPiles, goldCoins, totalPiles})
				end
			else
				npcHandler:sayLocalized("misc.bank_system.say_10", npc, creature)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_11", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
		-- Transfer
	elseif MsgContains(message, "transfer") then
		count[playerId] = getMoneyCount(message)
		transfer[playerId] = string.match(message, "[^transfer %d+ to ].+")
		if string.match(message, "%d+") then
			if player:getBankBalance() < count[playerId] then
				npcHandler:sayLocalized("misc.bank_system.say_12", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			if MsgContains(message, "to") then
				if player:getName():lower() == transfer[playerId]:lower() then
					npcHandler:sayLocalized("misc.bank_system.say_13", npc, creature)
					npcHandler:setTopic(playerId, 0)
					return true
				end
				local playerName = Game.getNormalizedPlayerName(transfer[playerId])
				if playerName then
					local arrayDenied = {
						"accountmanager",
						"rooksample",
						"druidsample",
						"sorcerersample",
						"knightsample",
						"paladinsample",
					}
					if table.contains(arrayDenied, string.gsub(transfer[playerId], " ", "")) then
						npcHandler:sayLocalized("misc.bank_system.say_14", npc, creature)
						npcHandler:setTopic(playerId, 0)
						return true
					end
					npcHandler:sayLocalized("npclib.bank_system.say_20", npc, creature, {count[playerId], string.titleCase(transfer[playerId])})
					npcHandler:setTopic(playerId, 13)
					return true
				else
					npcHandler:sayLocalized("misc.bank_system.say_15", npc, creature)
					npcHandler:setTopic(playerId, 0)
					return false
				end
			end
			if isValidMoney(count[playerId]) then
				npcHandler:sayLocalized("npclib.bank_system.say_19", npc, creature, {count[playerId]})
				npcHandler:setTopic(playerId, 12)
				return true
			end
		end
		npcHandler:sayLocalized("misc.bank_system.say_16", npc, creature)
		npcHandler:setTopic(playerId, 11)
	elseif npcHandler:getTopic(playerId) == 11 then
		count[playerId] = getMoneyCount(message)
		if not Bank.hasBalance(player, count[playerId]) then
			npcHandler:sayLocalized("misc.bank_system.say_17", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_18", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 12)
		else
			npcHandler:sayLocalized("misc.bank_system.say_18", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 12 then
		transfer[playerId] = message
		if player:getName():lower() == transfer[playerId]:lower() then
			npcHandler:sayLocalized("misc.bank_system.say_19", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		local playerName = Game.getNormalizedPlayerName(transfer[playerId])
		if playerName then
			local arrayDenied = {
				"accountmanager",
				"rooksample",
				"druidsample",
				"sorcerersample",
				"knightsample",
				"paladinsample",
			}
			if table.contains(arrayDenied, string.gsub(transfer[playerId], " ", "")) then
				npcHandler:sayLocalized("misc.bank_system.say_20", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return true
			end
			npcHandler:sayLocalized("npclib.bank_system.say_17", npc, creature, {count[playerId], playerName})
			npcHandler:setTopic(playerId, 13)
		else
			npcHandler:sayLocalized("misc.bank_system.say_21", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 13 then
		if MsgContains(message, "yes") then
			if not player:transferMoneyTo(transfer[playerId], count[playerId]) then
				npcHandler:sayLocalized("misc.bank_system.say_22", npc, creature)
			else
				npcHandler:sayLocalized("npclib.bank_system.say_16", npc, creature, {count[playerId], string.titleCase(transfer[playerId])})
				transfer[playerId] = nil
			end
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_23", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		-- Change money
	elseif MsgContains(message, "change gold") then
		npcHandler:sayLocalized("misc.bank_system.say_24", npc, creature)
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			npcHandler:sayLocalized("misc.bank_system.say_25", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:sayLocalized("npclib.bank_system.say_15", npc, creature, {count[playerId] * 100, count[playerId]})
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			if player:removeItem(ITEM_GOLD_COIN, count[playerId] * 100) then
				player:addItem(ITEM_PLATINUM_COIN, count[playerId])
				npcHandler:sayLocalized("misc.bank_system.say_26", npc, creature)
			else
				npcHandler:sayLocalized("misc.bank_system.say_27", npc, creature)
			end
		else
			npcHandler:sayLocalized("misc.bank_system.say_28", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change platinum") then
		npcHandler:sayLocalized("misc.bank_system.say_29", npc, creature)
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "gold") then
			npcHandler:sayLocalized("misc.bank_system.say_30", npc, creature)
			npcHandler:setTopic(playerId, 17)
		elseif MsgContains(message, "crystal") then
			npcHandler:sayLocalized("misc.bank_system.say_31", npc, creature)
			npcHandler:setTopic(playerId, 19)
		else
			npcHandler:sayLocalized("misc.bank_system.say_32", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			npcHandler:sayLocalized("misc.bank_system.say_33", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:sayLocalized("npclib.bank_system.say_14", npc, creature, {count[playerId] * 100, count[playerId]})
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			if player:removeItem(ITEM_PLATINUM_COIN, count[playerId]) then
				player:addItem(ITEM_GOLD_COIN, count[playerId] * 100)
				npcHandler:sayLocalized("misc.bank_system.say_34", npc, creature)
			else
				npcHandler:sayLocalized("misc.bank_system.say_35", npc, creature)
			end
		else
			npcHandler:sayLocalized("misc.bank_system.say_36", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			npcHandler:sayLocalized("misc.bank_system.say_37", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:sayLocalized("npclib.bank_system.say_13", npc, creature, {count[playerId] * 100, count[playerId]})
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if MsgContains(message, "yes") then
			if player:removeItem(ITEM_PLATINUM_COIN, count[playerId] * 100) then
				player:addItem(ITEM_CRYSTAL_COIN, count[playerId])
				npcHandler:sayLocalized("misc.bank_system.say_38", npc, creature)
			else
				npcHandler:sayLocalized("misc.bank_system.say_39", npc, creature)
			end
		else
			npcHandler:sayLocalized("misc.bank_system.say_40", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change crystal") then
		npcHandler:sayLocalized("misc.bank_system.say_41", npc, creature)
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			npcHandler:sayLocalized("misc.bank_system.say_42", npc, creature)
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:sayLocalized("npclib.bank_system.say_12", npc, creature, {count[playerId] * 100, count[playerId]})
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if MsgContains(message, "yes") then
			if player:removeItem(ITEM_CRYSTAL_COIN, count[playerId]) then
				player:addItem(ITEM_PLATINUM_COIN, count[playerId] * 100)
				npcHandler:sayLocalized("misc.bank_system.say_43", npc, creature)
			else
				npcHandler:sayLocalized("misc.bank_system.say_44", npc, creature)
			end
		else
			npcHandler:sayLocalized("misc.bank_system.say_45", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	end
end

function Npc:parseGuildBank(message, npc, creature, playerId, npcHandler)
	local player = Player(creature)
	-- Guild balance
	if MsgContains(message, "guild balance") then
		npcHandler:setTopic(playerId, 0)
		if not player:getGuild() then
			npcHandler:sayLocalized("misc.bank_system.say_46", npc, creature)
			return false
		end
		npcHandler:sayLocalized("npclib.bank_system.say_11", npc, creature, {Bank.balance(player:getGuild())})
		return true
		-- Guild deposit
	elseif MsgFind(message, "guild deposit") then
		if not player:getGuild() then
			npcHandler:sayLocalized("misc.bank_system.say_47", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if Bank.hasBalance(player, count[playerId]) then
				npcHandler:sayLocalized("misc.bank_system.say_48", npc, creature)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			npcHandler:sayLocalized("npclib.bank_system.say_10", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 123)
			return true
		else
			npcHandler:sayLocalized("misc.bank_system.say_49", npc, creature)
			npcHandler:setTopic(playerId, 122)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 122 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_9", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 123)
			return true
		else
			npcHandler:sayLocalized("misc.bank_system.say_50", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 123 then
		if MsgContains(message, "yes") then
			npcHandler:sayLocalized("npclib.bank_system.say_8", npc, creature, {count[playerId]})
			local guild = player:getGuild()
			local info = {
				type = "Guild Deposit",
				amount = count[playerId],
				owner = player:getName() .. " of " .. guild:getName(),
				recipient = guild:getName(),
			}
			local amount = tonumber(count[playerId])
			if Bank.hasBalance(player, amount) then
				info.message = "We are happy to inform you that your transfer request was successfully carried out."
				info.success = true
				Bank.transfer(player, guild, amount)
			else
				info.message = "We are sorry to inform you that we could not fulfill your request, \z
                                due to a lack of the required sum on your bank account."
				info.success = false
			end

			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_51", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
		return true
		-- Guild withdraw
	elseif MsgContains(message, "guild withdraw") then
		if not player:getGuild() then
			npcHandler:sayLocalized("misc.bank_system.say_52", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:sayLocalized("misc.bank_system.say_53", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end

		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:sayLocalized("misc.bank_system.say_54", npc, creature, {count[playerId]})
				npcHandler:setTopic(playerId, 125)
			else
				npcHandler:sayLocalized("misc.bank_system.say_55", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			npcHandler:sayLocalized("misc.bank_system.say_56", npc, creature)
			npcHandler:setTopic(playerId, 124)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 124 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_7", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 125)
		else
			npcHandler:sayLocalized("misc.bank_system.say_57", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 125 then
		if MsgContains(message, "yes") then
			local guild = player:getGuild()
			npcHandler:sayLocalized("npclib.bank_system.say_6", npc, creature, {count[playerId]})
			local info = {
				type = "Guild Withdraw",
				amount = count[playerId],
				owner = player:getName() .. " of " .. guild:getName(),
				recipient = player:getName(),
			}
			if Bank.hasBalance(guild, tonumber(count[playerId])) then
				info.message = "We are happy to inform you that your transfer request was successfully carried out."
				info.success = true
				Bank.transfer(guild, player, tonumber(count[playerId]))
			else
				info.message = "We are sorry to inform you that we could not fulfill your request, \z
                                due to a lack of the required sum on your guild account."
				info.success = false
			end

			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_58", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
		-- Guild transfer
	elseif MsgContains(message, "guild transfer") then
		if not player:getGuild() then
			npcHandler:sayLocalized("misc.bank_system.say_59", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		elseif player:getGuildLevel() < 2 then
			npcHandler:sayLocalized("misc.bank_system.say_60", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end

		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				transfer[playerId] = string.match(message, "to%s*(.+)$")
				local guildName = Game.getNormalizedGuildName(transfer[playerId])
				if Game.getNormalizedGuildName(transfer[playerId]) then
					npcHandler:sayLocalized("npclib.bank_system.say_5", npc, creature, {count[playerId], guildName})
					npcHandler:setTopic(playerId, 128)
				else
					npcHandler:sayLocalized("npclib.bank_system.say_4", npc, creature, {count[playerId]})
					npcHandler:setTopic(playerId, 127)
				end
			else
				npcHandler:sayLocalized("misc.bank_system.say_61", npc, creature)
				npcHandler:setTopic(playerId, 0)
			end
		else
			npcHandler:sayLocalized("misc.bank_system.say_62", npc, creature)
			npcHandler:setTopic(playerId, 126)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 126 then
		count[playerId] = getMoneyCount(message)
		local guild = player:getGuild()
		if not guild or not Bank.hasBalance(guild, count[playerId]) then
			npcHandler:sayLocalized("misc.bank_system.say_63", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		if isValidMoney(count[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_3", npc, creature, {count[playerId]})
			npcHandler:setTopic(playerId, 127)
		else
			npcHandler:sayLocalized("misc.bank_system.say_64", npc, creature)
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 127 then
		transfer[playerId] = message
		local guild = player:getGuild()
		if guild:getName() == transfer[playerId] then
			npcHandler:sayLocalized("misc.bank_system.say_65", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return true
		end
		local guildName = Game.getNormalizedGuildName(transfer[playerId])
		if Game.getNormalizedGuildName(transfer[playerId]) then
			npcHandler:sayLocalized("npclib.bank_system.say_2", npc, creature, {count[playerId], guildName})
			npcHandler:setTopic(playerId, 128)
		else
			npcHandler:sayLocalized("misc.bank_system.say_66", npc, creature)
			npcHandler:setTopic(playerId, 0)
			return false
		end
		return true
	elseif npcHandler:getTopic(playerId) == 128 then
		if MsgContains(message, "yes") then
			npcHandler:sayLocalized("npclib.bank_system.say_1", npc, creature, {count[playerId], string.titleCase(transfer[playerId])})
			local guild = player:getGuild()
			local info = {
				type = "Guild to Guild Transfer",
				amount = count[playerId],
				owner = player:getName() .. " of " .. guild:getName(),
				recipient = transfer[playerId],
			}
			local amount = tonumber(count[playerId])
			if Bank.transferToGuild(guild, transfer[playerId], amount) then
				logger.info("Guild {} transferred {} gold to guild {}.", guild:getName(), amount, transfer[playerId])
				info.success = true
				info.message = "We are happy to inform you that your transfer request was successfully carried out."
			else
				logger.info("Guild {} failed to transfer {} gold to guild {}.", guild:getName(), amount, transfer[playerId])
				info.message = "We are sorry to inform you that we could not fulfill your request, due to a lack of the required sum on your guild account."
				info.success = false
			end
			local inbox = player:getInbox()
			local receipt = GetReceipt(info)
			inbox:addItemEx(receipt, INDEX_WHEREEVER, FLAG_NOLIMIT)
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			npcHandler:sayLocalized("misc.bank_system.say_67", npc, creature)
		end
		npcHandler:setTopic(playerId, 0)
	end
end

-- Greet callback
function NpcBankGreetCallback(npc, creature)
	local playerId = creature:getId()
	count[playerId], transfer[playerId] = nil, nil
	return true
end
