local internalNpcName = "Ruprecht"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 153,
	lookHead = 59,
	lookBody = 115,
	lookLegs = 115,
	lookFeet = 38,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
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

local storeTable = {}
local itemsTable = {
	["gingerbreadman"] = { itemId = 6500, count = 1 },
	["christmas cookie tray"] = { itemId = 20310, count = 1 },
	["gingerbread recipe"] = { itemId = 174, count = 10 },
	["jewel case"] = { itemId = 7527, count = 25 },
	["santa hat"] = { itemId = 6531, count = 50 },
	["santa backpack"] = { itemId = 10346, count = 75 },
	["snow flake tapestry"] = { itemId = 20315, count = 75 },
	["santa doll"] = { itemId = 6511, count = 100 },
	["snowman doll"] = { itemId = 10339, count = 150 },
	["snow globe"] = { itemId = 20311, count = 150 },
	["frazzlemaw santa"] = { itemId = 20308, count = 250 },
	["leaf golem santa"] = { itemId = 20309, count = 250 },
	["santa music box"] = { itemId = 20313, count = 250 },
	["santa teddy"] = { itemId = 10338, count = 500 },
	["maxxen santa"] = { itemId = 21952, count = 250 },
	["present bag"] = { itemId = 6496, count = 1 },
	["ferumbras' teddy santa"] = { itemId = 22879, count = 250 },
	["nightmare beast santa"] = { itemId = 29947, count = 250 },
	["orclops santa"] = { itemId = 24394, count = 250 },
	["raccoon santa"] = { itemId = 35692, count = 250 },
	["santa fox"] = { itemId = 27591, count = 250 },
	["santa leech"] = { itemId = 32746, count = 250 },
}

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "offers") then
		local offersList = ""
		for i, v in pairs(itemsTable) do
			offersList = offersList .. "{" .. i .. "}, "
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_offers", { offersList })
	end

	if npcHandler:getTopic(playerId) == 0 then
		local table = itemsTable[message]
		if table then
			if table.itemId ~= 6496 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_1", { message, table.count })
				storeTable[playerId] = message
				npcHandler:setTopic(playerId, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_2", { message, table.count })
				storeTable[playerId] = 6526
				npcHandler:setTopic(playerId, 1)
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			if tonumber(storeTable[playerId]) == 6526 then
				if player:removeItem(6496, 1) then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_2")
					player:addItem(6526, 1)
					npcHandler:setTopic(playerId, 0)
				else
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_3")
					npcHandler:setTopic(playerId, 0)
				end
				return false
			end
			if player:removeItem(6526, itemsTable[storeTable[playerId]].count) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_3", { storeTable[playerId] })
				player:addItem(itemsTable[storeTable[playerId]].itemId, 1)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_5")
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif npcHandler:getTopic(playerId) > 0 then
		if MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.say_6")
		end
	end
	if MsgContains(message, "santa claus") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_1")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_2")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_3")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_4")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_5")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_6")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_7")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_8")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_9")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_10")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_11")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.ruprecht.multi_12")
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	storeTable[playerId] = nil
end

npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
