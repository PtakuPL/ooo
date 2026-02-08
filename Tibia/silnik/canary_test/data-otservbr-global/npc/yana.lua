local internalNpcName = "Yana"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 471,
	lookHead = 0,
	lookBody = 57,
	lookLegs = 0,
	lookFeet = 68,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.yana.voice_1" },
}

npcConfig.currency = 22721

npcConfig.shop = {
	{ name = "axe of desctruction", clientId = 27451, buy = 50 },
	{ name = "blade of desctruction", clientId = 27449, buy = 50 },
	{ name = "bow of desctruction", clientId = 27455, buy = 50 },
	{ name = "chopper of desctruction", clientId = 27452, buy = 50 },
	{ name = "crossbow of desctruction", clientId = 27456, buy = 50 },
	{ name = "hammer of desctruction", clientId = 27454, buy = 50 },
	{ name = "mace of desctruction", clientId = 27453, buy = 50 },
	{ name = "rod of desctruction", clientId = 27458, buy = 50 },
	{ name = "slayer of desctruction", clientId = 27450, buy = 50 },
	{ name = "wand of desctruction", clientId = 27457, buy = 50 },
}
-- On buy npc shop message
npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end
-- On sell npc shop message
npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendLocalizedTextMessage(MESSAGE_TRADE, "system.trade.sold", {tostring(amount), name, tostring(totalCost)})
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

local products = {
	["strike"] = {
		["basic"] = {
			i18nKey = "npc.yana.voice_2",
			itens = {
				[1] = { id = 11444, amount = 20 },
			},
			value = 2,
		},
		["intricate"] = {
			i18nKey = "npc.yana.voice_3",
			itens = {
				[1] = { id = 11444, amount = 20 },
				[2] = { id = 10311, amount = 25 },
			},
			value = 4,
		},
		["powerful"] = {
			i18nKey = "npc.yana.voice_4",
			itens = {
				[1] = { id = 11444, amount = 20 },
				[2] = { id = 10311, amount = 25 },
				[3] = { id = 22728, amount = 5 },
			},
			value = 6,
		},
	},
	["vampirism"] = {
		["basic"] = {
			i18nKey = "npc.yana.voice_5",
			itens = {
				[1] = { id = 9685, amount = 25 },
			},
			value = 2,
		},
		["intricate"] = {
			i18nKey = "npc.yana.voice_6",
			itens = {
				[1] = { id = 9685, amount = 25 },
				[2] = { id = 9633, amount = 15 },
			},
			value = 4,
		},
		["powerful"] = {
			i18nKey = "npc.yana.voice_7",
			itens = {
				[1] = { id = 9685, amount = 25 },
				[2] = { id = 9633, amount = 15 },
				[3] = { id = 9663, amount = 5 },
			},
			value = 6,
		},
	},
	["void"] = {
		["basic"] = {
			i18nKey = "npc.yana.voice_8",
			itens = {
				[1] = { id = 11492, amount = 25 },
			},
			value = 2,
		},
		["intricate"] = {
			i18nKey = "npc.yana.voice_9",
			itens = {
				[1] = { id = 11492, amount = 25 },
				[2] = { id = 20200, amount = 25 },
			},
			value = 4,
		},
		["powerful"] = {
			i18nKey = "npc.yana.voice_10",
			itens = {
				[1] = { id = 11492, amount = 25 },
				[2] = { id = 20200, amount = 25 },
				[3] = { id = 22730, amount = 5 },
			},
			value = 6,
		},
	},
}

local answerType = {}
local answerLevel = {}

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

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	npcHandler:setTopic(playerId, 0)
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "information") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.yana.say_1", "npc.yana.say_2" }, 100)
	elseif MsgContains(message, "worth") then
		-- to do: check if Heart of Destruction was killed
		-- after kill message: 'You disrupted the Heart of Destruction, defeated the World Devourer and bought our world some time. You have proven your worth.'
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_3")
	elseif MsgContains(message, "tokens") then
		npc:openShopWindow(creature)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_4")
	elseif MsgContains(message, "trade") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_5")
		npcHandler:setTopic(playerId, 1)
	elseif npcHandler:getTopic(playerId) == 1 then
		local selectedType = message:lower()
		local imbueType = products[selectedType]
		if imbueType then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_6", { message })
			answerType[playerId] = selectedType
			npcHandler:setTopic(playerId, 2)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		local playerType = answerType[playerId]
		if not playerType then
			return true
		end
		local selectedLevel = message:lower()
		local imbueLevel = products[playerType][selectedLevel]
		if imbueLevel then
			answerLevel[playerId] = selectedLevel
			local neededCap = 0
			for i = 1, #products[playerType][selectedLevel].itens do
				neededCap = neededCap + ItemType(products[playerType][selectedLevel].itens[i].id):getWeight() * products[playerType][selectedLevel].itens[i].amount
			end
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {
				imbueLevel.i18nKey,
				{ key = "npc.yana.say_7", args = { tostring(#products[playerType][selectedLevel].itens), string.format("%.2f", neededCap / 100) } },
			}, 100)
			npcHandler:setTopic(playerId, 3)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			local playerType = answerType[playerId]
			local playerLevel = answerLevel[playerId]
			if not playerType or not playerLevel then
				return true
			end

			local neededCap = 0
			for i = 1, #products[playerType][playerLevel].itens do
				neededCap = neededCap + ItemType(products[playerType][playerLevel].itens[i].id):getWeight() * products[playerType][playerLevel].itens[i].amount
			end
			if player:getFreeCapacity() > neededCap then
				if player:getItemCount(npc:getCurrency()) >= products[playerType][playerLevel].value then
					for i = 1, #products[playerType][playerLevel].itens do
						player:addItem(products[playerType][playerLevel].itens[i].id, products[playerType][playerLevel].itens[i].amount)
					end
					player:removeItem(npc:getCurrency(), products[playerType][playerLevel].value)
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_8")
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_9", { ItemType(npc:getCurrency()):getPluralName():lower(), tostring(products[playerType][playerLevel].value) })
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_10", { string.format("%.2f", neededCap / 100) })
			end
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.yana.say_11")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

npcHandler:setCallback(CALLBACK_SET_INTERACTION, onAddFocus)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, false)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
