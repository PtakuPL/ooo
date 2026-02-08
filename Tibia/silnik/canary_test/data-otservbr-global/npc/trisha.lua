local internalNpcName = "Trisha"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 142,
	lookHead = 94,
	lookBody = 67,
	lookLegs = 38,
	lookFeet = 95,
	lookAddons = 1,
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

local config = {
	["hardened bones"] = {
		value = 1,
		messageKey = {
			wrongValue = "npc.trisha.bones_wrong",
			deliever = "npc.trisha.bones_deliver",
			success = "npc.trisha.bones_success",
		},
		itemId = 5925,
		count = 100,
	},
	["turtle shells"] = {
		value = 2,
		messageKey = {
			wrongValue = "npc.trisha.turtle_wrong",
			deliever = "npc.trisha.turtle_deliver",
			success = "npc.trisha.turtle_success",
		},
		itemId = 5899,
		count = 100,
	},
	["fighting spirit"] = {
		value = 3,
		messageKey = {
			wrongValue = "npc.trisha.spirit_wrong",
			deliever = "npc.trisha.spirit_deliver",
			success = "npc.trisha.spirit_success",
		},
		itemId = 5884,
	},
	["dragon claw"] = {
		value = 4,
		messageKey = {
			wrongValue = "npc.trisha.claw_wrong",
			deliever = "npc.trisha.claw_deliver",
			success = "npc.trisha.claw_success",
		},
		itemId = 5919,
	},
}

local topic = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.trisha.greet_msg_1")
	topic[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local player, storage = Player(creature), Storage.Quest.U7_8.WarriorOutfits.WarriorShoulderAddon
	if npcHandler:getTopic(playerId) == 0 then
		if table.contains({ "outfit", "addon" }, message) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_1")
		elseif MsgContains(message, "earn") then
			if player:getStorageValue(storage) < 1 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_2")
				npcHandler:setTopic(playerId, 1)
			elseif player:getStorageValue(storage) >= 1 and player:getStorageValue(storage) < 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_3")
			elseif player:getStorageValue(storage) == 5 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_4")
			end
		elseif config[message:lower()] then
			local targetMessage = config[message:lower()]
			if player:getStorageValue(storage) ~= targetMessage.value then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.wrongValue)
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.deliever)
			npcHandler:setTopic(playerId, 3)
			topic[playerId] = targetMessage
		end
	elseif npcHandler:getTopic(playerId) == 1 then
		if MsgContains(message, "yes") then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, {"npc.trisha.say_1", "npc.trisha.say_2", "npc.trisha.say_3", "npc.trisha.say_4", "npc.trisha.say_5", "npc.trisha.say_6", "npc.trisha.say_7"}, 100)
			npcHandler:setTopic(playerId, 2)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_5")
			npcHandler:setTopic(playerId, 0)
		end
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "yes") then
			player:setStorageValue(storage, 1)
			-- This for default start of outfit and addon quests
			player:setStorageValue(Storage.OutfitQuest.DefaultStart, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_6")
			npcHandler:setTopic(playerId, 0)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_7")
			npcHandler:setTopic(playerId, 1)
		end
	elseif npcHandler:getTopic(playerId) == 3 then
		if MsgContains(message, "yes") then
			local targetMessage = topic[playerId]
			if not player:removeItem(targetMessage.itemId, targetMessage.count or 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_8")
				return true
			end

			player:setStorageValue(storage, player:getStorageValue(storage) + 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, targetMessage.messageKey.success)
		elseif MsgContains(message, "no") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.trisha.say_9")
		end
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addSpellKeyword({ "find", "person" }, {
	npcHandler = npcHandler,
	spellName = "Find Person",
	price = 80,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "light" }, {
	npcHandler = npcHandler,
	spellName = "Light",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "cure", "poison" }, {
	npcHandler = npcHandler,
	spellName = "Cure Poison",
	price = 150,
	level = 10,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "wound", "cleansing" }, {
	npcHandler = npcHandler,
	spellName = "Wound Cleansing",
	price = 0,
	level = 8,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addSpellKeyword({ "great", "light" }, {
	npcHandler = npcHandler,
	spellName = "Great Light",
	price = 500,
	level = 13,
	vocation = VOCATION.BASE_ID.KNIGHT,
})
keywordHandler:addKeyword({ "healing", "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.trisha.stdmod_1",
})
keywordHandler:addKeyword({ "support", "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.trisha.stdmod_2",
})
keywordHandler:addKeyword({ "spells" }, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.trisha.stdmod_3",
})

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.trisha.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.trisha.farewell_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
