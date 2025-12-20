local internalNpcName = "Wentworth"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 97,
	lookBody = 19,
	lookLegs = 124,
	lookFeet = 115,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.wentworth.voice_1" },
	{ i18nKey = "npc.wentworth.voice_2" },
	{ i18nKey = "npc.wentworth.voice_3" },
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
	count[playerId] = nil
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
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.wentworth.say_1", "npc.wentworth.say_2"}, 10)
		npcHandler:setTopic(playerId, 0)
		return true
		--Balance
	elseif MsgContains(message, "balance") then
		npcHandler:setTopic(playerId, 0)
		if player:getBankBalance() >= 100000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_1", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 10000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_2", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 1000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_3", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 100000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_4", { player:getBankBalance() })
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_5", { player:getBankBalance() })
			return true
		end
		--Deposit
	elseif MsgContains(message, "deposit") then
		count[playerId] = player:getMoney()
		if count[playerId] < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_1")
			npcHandler:setTopic(playerId, 0)
			return false
		elseif not isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_2")
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if MsgContains(message, "all") then
			count[playerId] = player:getMoney()
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_6", { count[playerId] })
			npcHandler:setTopic(playerId, 2)
			return true
		else
			if string.match(message, "%d+") then
				count[playerId] = getMoneyCount(message)
				if count[playerId] < 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_4")
					npcHandler:setTopic(playerId, 0)
					return false
				end
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_7", { count[playerId] })
				npcHandler:setTopic(playerId, 2)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_6")
				npcHandler:setTopic(playerId, 1)
				return true
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_8", { count[playerId] })
			npcHandler:setTopic(playerId, 2)
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_8")
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if player:getLevel() == 8 then
				if count[playerId] > 1000 or player:getBankBalance() >= 1000 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_9")
					npcHandler:setTopic(playerId, 0)
					return false
				end
			elseif player:getLevel() > 9 then
				if count[playerId] > 2000 or player:getBankBalance() >= 2000 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_10")
					npcHandler:setTopic(playerId, 0)
					return false
				end
			end
			if player:depositMoney(count[playerId]) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_9", { count[playerId] })
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_11")
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_12")
		end
		npcHandler:setTopic(playerId, 0)
		return true
		--Withdraw
	elseif MsgContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_10", { count[playerId] })
				npcHandler:setTopic(playerId, 7)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_14")
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_15")
			npcHandler:setTopic(playerId, 6)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_11", { count[playerId] })
			npcHandler:setTopic(playerId, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_17")
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if not player:withdrawMoney(count[playerId]) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_18")
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_12", { count[playerId] })
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_1")
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_19")
			npcHandler:setTopic(playerId, 0)
		end
		return true
		--Money exchange
	elseif MsgContains(message, "change gold") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_20")
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_21")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_13", { count[playerId] * 100, count[playerId] })
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			if player:removeItem(3031, count[playerId] * 100) then
				player:addItem(3035, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_22")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_23")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_24")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change platinum") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_25")
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "gold") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_26")
			npcHandler:setTopic(playerId, 17)
		elseif MsgContains(message, "crystal") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_27")
			npcHandler:setTopic(playerId, 19)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_28")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_29")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_14", { count[playerId], count[playerId] * 100 })
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId]) then
				player:addItem(3031, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_30")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_31")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_32")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_33")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_15", { count[playerId] * 100, count[playerId] })
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId] * 100) then
				player:addItem(3043, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_34")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_35")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_36")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change crystal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_37")
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_38")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_16", { count[playerId], count[playerId] * 100 })
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if MsgContains(message, "yes") then
			if player:removeItem(3043, count[playerId]) then
				player:addItem(3035, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_39")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_40")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.wentworth.say_41")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "money" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_1",
})
keywordHandler:addKeyword({ "change" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_2",
})
keywordHandler:addKeyword({ "bank" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_3",
})
keywordHandler:addKeyword({ "advanced" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_4",
})
keywordHandler:addKeyword({ "help" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_5",
})
keywordHandler:addKeyword({ "functions" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_6",
})
keywordHandler:addKeyword({ "basic" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_7",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_8",
})
keywordHandler:addKeyword({ "transfer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.wentworth.stdmod_9",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.wentworth.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.wentworth.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.wentworth.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
