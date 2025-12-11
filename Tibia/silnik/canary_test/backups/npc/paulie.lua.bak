local internalNpcName = "Paulie"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,
	lookHead = 78,
	lookBody = 86,
	lookLegs = 114,
	lookFeet = 116,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Don't forget to deposit your money here in the Global Bank before you head out for adventure.", yell = false },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

local count = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	local player = Player(creature)
	-- Mission 8: The Rookie Guard Quest
	if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome |PLAYERNAME|! Special newcomer offer, today only! Deposit some money - or {deposit ALL} of your money! - and get 50 gold for free!")
	else
		npcHandler:setMessage(MESSAGE_GREET, "Yes? What may I do for you, |PLAYERNAME|? Bank business, perhaps?")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	--Help
	if MsgContains(message, "bank account") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.paulie.say_1", "npc.paulie.say_2"}, 10)
		npcHandler:setTopic(playerId, 0)
		return true
		--Balance
	elseif MsgContains(message, "balance") then
		npcHandler:setTopic(playerId, 0)
		if player:getBankBalance() >= 100000000 then
			npcHandler:say("I think you must be one of the richest inhabitants in the world! \z
				Your account balance is " .. player:getBankBalance() .. " gold.", npc, creature)
			return true
		elseif player:getBankBalance() >= 10000000 then
			npcHandler:say("You have made ten millions and it still grows! Your account balance is \z
				" .. player:getBankBalance() .. " gold.", npc, creature)
			return true
		elseif player:getBankBalance() >= 1000000 then
			npcHandler:say("Wow, you have reached the magic number of a million gp!!! \z
				Your account balance is " .. player:getBankBalance() .. " gold!", npc, creature)
			return true
		elseif player:getBankBalance() >= 100000 then
			npcHandler:say("You certainly have made a pretty penny. Your account balance is \z
				" .. player:getBankBalance() .. " gold.", npc, creature)
			return true
		else
			npcHandler:say("Your account balance is " .. player:getBankBalance() .. " gold.", npc, creature)
			return true
		end
		--Deposit
	elseif MsgContains(message, "deposit") then
		count[playerId] = player:getMoney()
		if count[playerId] < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_1")
			npcHandler:setTopic(playerId, 0)
			return false
		elseif not isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_2")
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if MsgContains(message, "all") then
			count[playerId] = player:getMoney()
			npcHandler:say("Would you really like to deposit " .. count[playerId] .. " gold?", npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		else
			if string.match(message, "%d+") then
				count[playerId] = getMoneyCount(message)
				if count[playerId] < 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_4")
					npcHandler:setTopic(playerId, 0)
					return false
				end
				npcHandler:say("Would you really like to deposit " .. count[playerId] .. " gold?", npc, creature)
				npcHandler:setTopic(playerId, 2)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_6")
				npcHandler:setTopic(playerId, 1)
				return true
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say("Would you really like to deposit " .. count[playerId] .. " gold?", npc, creature)
			npcHandler:setTopic(playerId, 2)
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_8")
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if player:getStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08) == 1 then
				player:depositMoney(count[playerId])
				Bank.credit(player, 50)
				npcHandler:say("Alright, we have added the amount of " .. count[playerId] .. " +50 gold to your {balance} - that is the money you deposited plus a bonus of 50 gold. \z
				Thank you! You can withdraw your money anytime.", npc, creature)
				player:setStorageValue(Storage.Quest.U9_1.TheRookieGuard.Mission08, 2)
				npcHandler:setTopic(playerId, 0)
				return false
			end
			if player:depositMoney(count[playerId]) then
				npcHandler:say("Alright, we have added the amount of " .. count[playerId] .. " gold to your {balance}. \z
				You can {withdraw} your money anytime you want to.", npc, creature)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_9")
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_10")
		end
		npcHandler:setTopic(playerId, 0)
		return true
		--Withdraw
	elseif MsgContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				npcHandler:say("Are you sure you wish to withdraw " .. count[playerId] .. " gold from your bank account?", npc, creature)
				npcHandler:setTopic(playerId, 7)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_12")
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_13")
			npcHandler:setTopic(playerId, 6)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			npcHandler:say("Are you sure you wish to withdraw " .. count[playerId] .. " gold from your bank account?", npc, creature)
			npcHandler:setTopic(playerId, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_15")
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if not player:withdrawMoney(count[playerId]) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_16")
				else
					npcHandler:say("Here you are, " .. count[playerId] .. " gold. \z
						Please let me know if there is something else I can do for you.", npc, creature)
				end
			else
				npcHandler:say(
					"Whoah, hold on, you have no room in your inventory to carry all those coins. \z
					I don't want you to drop it on the floor, maybe come back with a cart!",
					npc,
					creature
				)
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_17")
			npcHandler:setTopic(playerId, 0)
		end
		return true
		--Money exchange
	elseif MsgContains(message, "change gold") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_18")
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_19")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("So you would like me to change " .. count[playerId] * 100 .. " of your gold \z
				coins into " .. count[playerId] .. " platinum coins?", npc, creature)
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			if player:removeItem(3031, count[playerId] * 100) then
				player:addItem(3035, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_20")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_21")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_22")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change platinum") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_23")
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "gold") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_24")
			npcHandler:setTopic(playerId, 17)
		elseif MsgContains(message, "crystal") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_25")
			npcHandler:setTopic(playerId, 19)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_26")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_27")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("So you would like me to change " .. count[playerId] .. " of your platinum \z
				coins into " .. count[playerId] * 100 .. " gold coins for you?", npc, creature)
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId]) then
				player:addItem(3031, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_28")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_29")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_30")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_31")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("So you would like me to change " .. count[playerId] * 100 .. " of your platinum coins \z
				into " .. count[playerId] .. " crystal coins for you?", npc, creature)
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId] * 100) then
				player:addItem(3043, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_32")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_33")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_34")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change crystal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_35")
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_36")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			npcHandler:say("So you would like me to change " .. count[playerId] .. " of your crystal coins \z
				into " .. count[playerId] * 100 .. " platinum coins for you?", npc, creature)
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if MsgContains(message, "yes") then
			if player:removeItem(3043, count[playerId]) then
				player:addItem(3035, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_37")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_38")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.paulie.say_39")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Have a nice day.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Have a nice day.")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
