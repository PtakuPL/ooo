local internalNpcName = "Gnomally"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 507,
	lookHead = 52,
	lookBody = 90,
	lookLegs = 90,
	lookFeet = 90,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.shop = {
	{ itemName = "bell", clientId = 15832, buy = 50 },
	{ itemName = "gnomish crystal package", clientId = 15802, buy = 1000 },
	{ itemName = "gnomish extraction crystal", clientId = 15696, buy = 50 },
	{ itemName = "gnomish repair crystal", clientId = 15703, buy = 50 },
	{ itemName = "gnomish spore gatherer", clientId = 15821, buy = 50 },
	{ itemName = "little pig", clientId = 15828, buy = 150 },
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

local topic = {}
local renown = {}

local config = {
	["supply"] = { itemid = 15698, token = { type = "minor", id = 16128, count = 2 } },
	["muck"] = { itemid = 16101, token = { type = "minor", id = 16128, count = 8 } },
	["mission"] = { itemid = 16242, token = { type = "minor", id = 16128, count = 10 } },
	["lamp"] = { itemid = 16094, token = { type = "minor", id = 16128, count = 15 } },
	["backpack"] = { itemid = 16099, token = { type = "minor", id = 16128, count = 15 } },
	["addition to the soil guardian outfit"] = { itemid = 16253, token = { type = "minor", id = 16128, count = 70 } },
	["addition to the crystal warlord armor outfit"] = { itemid = 16256, token = { type = "minor", id = 16128, count = 70 } },
	["gill gugel"] = { itemid = 16104, token = { type = "major", id = 16129, count = 10 } },
	["gill coat"] = { itemid = 16105, token = { type = "major", id = 16129, count = 10 } },
	["gill legs"] = { itemid = 16106, token = { type = "major", id = 16129, count = 10 } },
	["spellbook"] = { itemid = 16107, token = { type = "major", id = 16129, count = 10 } },
	["prismatic helmet"] = { itemid = 16109, token = { type = "major", id = 16129, count = 10 } },
	["prismatic armor"] = { itemid = 16110, token = { type = "major", id = 16129, count = 10 } },
	["prismatic legs"] = { itemid = 16111, token = { type = "major", id = 16129, count = 10 } },
	["prismatic boots"] = { itemid = 16112, token = { type = "major", id = 16129, count = 10 } },
	["prismatic shield"] = { itemid = 16116, token = { type = "major", id = 16129, count = 10 } },
	["basic soil guardian outfit"] = { itemid = 16252, token = { type = "major", id = 16129, count = 20 } },
	["basic crystal warlord outfit"] = { itemid = 16255, token = { type = "major", id = 16129, count = 20 } },
	["iron loadstone"] = { itemid = 16153, token = { type = "major", id = 16129, count = 20 } },
	["glow wine"] = { itemid = 16154, token = { type = "major", id = 16129, count = 20 } },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "equipment") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_6")
	elseif MsgContains(message, "major") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_4")
	elseif MsgContains(message, "minor") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.multi_2")
	elseif config[message] then
		local itemType = ItemType(config[message].itemid)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_1", { (itemType:getArticle() ~= "" and itemType:getArticle() or ""), itemType:getName(), config[message].token.count, config[message].token.type })
		npcHandler:setTopic(playerId, 1)
		topic[playerId] = message
	elseif MsgContains(message, "relations") then
		local player = Player(creature)
		if player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.QuestLine) >= 25 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_1")
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_2", { math.max(0, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank)) })
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_2")
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		local amount = getMoneyCount(message)
		if amount > 0 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_3", { amount, amount * 5 })
			renown[playerId] = amount
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "items") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_4")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			local player, targetTable = Player(creature), config[topic[playerId]]
			if player:getItemCount(targetTable.token.id) < targetTable.token.count then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_4", { targetTable.token.type })
				npcHandler:setTopic(playerId, 0)
				return true
			end

			local item = Game.createItem(targetTable.itemid, 1)
			local weight = 0
			weight = ItemType(item.itemid):getWeight(item:getCount())

			if player:addItemEx(item) ~= RETURNVALUE_NOERROR then
				if player:getFreeCapacity() < weight then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_6")
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_7")
				end
				npcHandler:setTopic(playerId, 0)
				return true
			end

			player:removeItem(targetTable.token.id, targetTable.token.count)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_5", { item:getPluralName() })
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_8")
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 4 then
			local player = Player(creature)
			if player:removeItem(16128, renown[playerId]) then
				player:setStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank, math.max(0, player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank)) + renown[playerId] * 5)
				player:checkGnomeRank()
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_6", { player:getStorageValue(Storage.Quest.U9_60.BigfootsBurden.Rank) })
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_9")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			npc:openShopWindow(creature)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_10")
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") and table.contains({ 1, 3, 4, 5 }, npcHandler:getTopic(playerId)) then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.gnomally.say_11")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	topic[playerId], renown[playerId] = nil, nil
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.gnomally.greet_msg_1")
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
