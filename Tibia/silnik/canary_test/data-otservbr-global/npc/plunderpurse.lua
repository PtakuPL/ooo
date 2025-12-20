local internalNpcName = "Plunderpurse"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 114,
	lookBody = 132,
	lookLegs = 0,
	lookFeet = 78,
	lookAddons = 1,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.plunderpurse.voice_1" },
	{ i18nKey = "npc.plunderpurse.voice_2" },
	{ i18nKey = "npc.plunderpurse.voice_3" },
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
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.plunderpurse.say_1", "npc.plunderpurse.say_2"}, 10)
		npcHandler:setTopic(playerId, 0)
		return true
		--Balance
	elseif MsgContains(message, "balance") then
		npcHandler:setTopic(playerId, 0)
		if player:getBankBalance() >= 100000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_1", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 10000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_2", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 1000000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_3", { player:getBankBalance() })
			return true
		elseif player:getBankBalance() >= 100000 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_4", { player:getBankBalance() })
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_5", { player:getBankBalance() })
			return true
		end
		--Deposit
	elseif MsgContains(message, "deposit") then
		count[playerId] = player:getMoney()
		if count[playerId] < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_1")
			npcHandler:setTopic(playerId, 0)
			return false
		elseif not isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_2")
			npcHandler:setTopic(playerId, 0)
			return false
		end
		if MsgContains(message, "all") then
			count[playerId] = player:getMoney()
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_6", { count[playerId] })
			npcHandler:setTopic(playerId, 2)
			return true
		else
			if string.match(message, "%d+") then
				count[playerId] = getMoneyCount(message)
				if count[playerId] < 1 then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_4")
					npcHandler:setTopic(playerId, 0)
					return false
				end
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_7", { count[playerId] })
				npcHandler:setTopic(playerId, 2)
				return true
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_6")
				npcHandler:setTopic(playerId, 1)
				return true
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_8", { count[playerId] })
			npcHandler:setTopic(playerId, 2)
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_8")
			npcHandler:setTopic(playerId, 0)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			if count[playerId] > 1500 or player:getBankBalance() >= 1500 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_9")
				npcHandler:setTopic(playerId, 0)
				return false
			end
			if player:depositMoney(count[playerId]) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_9", { count[playerId] })
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_10")
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_11")
		end
		npcHandler:setTopic(playerId, 0)
		return true
		--Withdraw
	elseif MsgContains(message, "withdraw") then
		if string.match(message, "%d+") then
			count[playerId] = getMoneyCount(message)
			if isValidMoney(count[playerId]) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_10", { count[playerId] })
				npcHandler:setTopic(playerId, 7)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_13")
				npcHandler:setTopic(playerId, 0)
			end
			return true
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_14")
			npcHandler:setTopic(playerId, 6)
			return true
		end
	elseif npcHandler:getTopic(playerId) == 6 then
		count[playerId] = getMoneyCount(message)
		if isValidMoney(count[playerId]) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_11", { count[playerId] })
			npcHandler:setTopic(playerId, 7)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_16")
			npcHandler:setTopic(playerId, 0)
		end
		return true
	elseif npcHandler:getTopic(playerId) == 7 then
		if MsgContains(message, "yes") then
			if player:getFreeCapacity() >= getMoneyWeight(count[playerId]) then
				if not player:withdrawMoney(count[playerId]) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_17")
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_12", { count[playerId] })
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_1")
			end
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_18")
			npcHandler:setTopic(playerId, 0)
		end
		return true
		--Money exchange
	elseif MsgContains(message, "change gold") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_19")
		npcHandler:setTopic(playerId, 14)
	elseif npcHandler:getTopic(playerId) == 14 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_20")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_13", { count[playerId] * 100, count[playerId] })
			npcHandler:setTopic(playerId, 15)
		end
	elseif npcHandler:getTopic(playerId) == 15 then
		if MsgContains(message, "yes") then
			if player:removeItem(3031, count[playerId] * 100) then
				player:addItem(3035, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_21")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_22")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_23")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change platinum") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_24")
		npcHandler:setTopic(playerId, 16)
	elseif npcHandler:getTopic(playerId) == 16 then
		if MsgContains(message, "gold") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_25")
			npcHandler:setTopic(playerId, 17)
		elseif MsgContains(message, "crystal") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_26")
			npcHandler:setTopic(playerId, 19)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_27")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 17 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_28")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_14", { count[playerId], count[playerId] * 100 })
			npcHandler:setTopic(playerId, 18)
		end
	elseif npcHandler:getTopic(playerId) == 18 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId]) then
				player:addItem(3031, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_29")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_30")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_31")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 19 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_32")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_15", { count[playerId] * 100, count[playerId] })
			npcHandler:setTopic(playerId, 20)
		end
	elseif npcHandler:getTopic(playerId) == 20 then
		if MsgContains(message, "yes") then
			if player:removeItem(3035, count[playerId] * 100) then
				player:addItem(3043, count[playerId])
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_33")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_34")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_35")
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "change crystal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_36")
		npcHandler:setTopic(playerId, 21)
	elseif npcHandler:getTopic(playerId) == 21 then
		if getMoneyCount(message) < 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_37")
			npcHandler:setTopic(playerId, 0)
		else
			count[playerId] = getMoneyCount(message)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_16", { count[playerId], count[playerId] * 100 })
			npcHandler:setTopic(playerId, 22)
		end
	elseif npcHandler:getTopic(playerId) == 22 then
		if MsgContains(message, "yes") then
			if player:removeItem(3043, count[playerId]) then
				player:addItem(3035, count[playerId] * 100)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_38")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_39")
			end
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.plunderpurse.say_40")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "dawnport" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_1",
})
keywordHandler:addKeyword({ "change" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_2",
})
keywordHandler:addKeyword({ "bank" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_3",
})
keywordHandler:addKeyword({ "advanced" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_4",
})
keywordHandler:addKeyword({ "name" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_5",
})
keywordHandler:addKeyword({ "functions" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_6",
})
keywordHandler:addKeyword({ "rookgaard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_7",
})
keywordHandler:addKeyword({ "job" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_8",
})
keywordHandler:addKeyword({ "mainland" }, StdModule.say, {
	npcHandler = npcHandler,
	text = {
		"Aye, Tibia is a vast world, my friend, with plenty of adventures, harbours, and loot! \z
			The Mainland is open to everyone; but there are many beautiful islands and more cities to explore, \z
			if you have premium rights and can use a ship.",
		"Once you have reached level 8 here on this isle, you can choose your definite vocation and leave for the Mainland.",
	},
})
keywordHandler:addKeyword({ "vocation" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_9",
})
keywordHandler:addKeyword({ "transfer" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_10",
})
keywordHandler:addKeyword({ "inigo" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_11",
})
keywordHandler:addKeyword({ "coltrayne" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_12",
})
keywordHandler:addKeyword({ "garamond" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_13",
})
keywordHandler:addKeyword({ "hamish" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_14",
})
keywordHandler:addKeyword({ "richard" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_15",
})
keywordHandler:addKeyword({ "mr morris" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_16",
})
keywordHandler:addKeyword({ "oressa" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_17",
})
keywordHandler:addKeyword({ "plunderpurse" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_18",
})
keywordHandler:addKeyword({ "quest" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_19",
})
keywordHandler:addKeyword({ "ser tybald" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_20",
})
keywordHandler:addKeyword({ "wentworth" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.plunderpurse.stdmod_21",
})

npcHandler:setMessage(
	MESSAGE_GREET,
	"Welcome, young adventurer! Harr! {Deposit} your gold or {withdraw} \z
	your money from your bank account. I can also explain the functions of your {bank} account to ya."
)
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.plunderpurse.farewell_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.plunderpurse.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
