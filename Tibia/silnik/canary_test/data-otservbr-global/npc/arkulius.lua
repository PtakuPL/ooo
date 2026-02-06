local internalNpcName = "Arkulius"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 130,
	lookHead = 0,
	lookBody = 79,
	lookLegs = 90,
	lookFeet = 117,
	lookAddons = 3,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.arkulius.voice_1" },
	{ i18nKey = "npc.arkulius.voice_2" },
	{ i18nKey = "npc.arkulius.voice_3" },
	{ i18nKey = "npc.arkulius.voice_4" },
	{ i18nKey = "npc.arkulius.voice_5" },
	{ i18nKey = "npc.arkulius.voice_6" },
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

local greetMsg = {
	"npc.arkulius.greet_msg_1",
	"npc.arkulius.greet_msg_2",
	"npc.arkulius.greet_msg_3",
}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	npcHandler:setLocalizedMessage(MESSAGE_GREET, greetMsg[math.random(#greetMsg)])
	npcHandler:setTopic(playerId, 0)
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "alverus") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_28")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_29")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_30")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "shrine") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_26")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_27")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "sphere") and player:getLevel() >= 80 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_24")
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_25")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") or MsgContains(message, "quest") then
		local value = player:getStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine)
		if value < 1 then
			if player:getLevel() >= 80 then
				if player:isSorcerer() then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_20")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_21")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_22")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_23")
				elseif player:isDruid() then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_16")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_17")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_18")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_19")
				elseif player:isPaladin() then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_12")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_13")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_14")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_15")
				elseif player:isKnight() then
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_8")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_9")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_10")
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_11")
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_1")
				npcHandler:setTopic(playerId, 0)
				return false
			end
			npcHandler:setTopic(playerId, 1)
		elseif value == 1 then
			if player:getItemCount(player:isSorcerer() and 946 or player:isDruid() and 947 or player:isPaladin() and 942 or player:isKnight() and 948) > 0 then
				player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 2)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_1")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_2")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_3")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_4")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_5")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_6")
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.multi_7")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_1", { (player:isSorcerer() and "Fire" or player:isDruid() and "Earth" or player:isPaladin() and "Ice" or player:isKnight() and "Energy") })
			end
			npcHandler:setTopic(playerId, 0)
		elseif value == 2 then
			if player:removeItem(954, 1) and player:getStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine) < 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_2")
				player:addItem(player:isSorcerer() and 8039 or player:isDruid() and 8041 or player:isPaladin() and 8025 or player:isKnight() and 8055, 1)
				player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 3)
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 and MsgContains(message, "yes") then
		player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_3")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_1" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_2" })
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_3" })
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_4" })
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_5" }) -- < Knight; FIXME !!!
keywordHandler:addKeyword({ "pits of inferno" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.arkulius.stdmod_6" })

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.arkulius.walkaway_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.arkulius.farewell_msg_1")
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcConfig.shop = {
	{ itemName = "energy soil", clientId = 945, sell = 2000 },
	{ itemName = "eternal flames", clientId = 946, sell = 5000 },
	{ itemName = "flawless ice crystal", clientId = 942, sell = 5000 },
	{ itemName = "glimmering soil", clientId = 941, sell = 2000 },
	{ itemName = "iced soil", clientId = 944, sell = 2000 },
	{ itemName = "mother soil", clientId = 947, sell = 5000 },
	{ itemName = "natural soil", clientId = 940, sell = 2000 },
	{ itemName = "neutral matter", clientId = 954, sell = 5000 },
	{ itemName = "pure energy", clientId = 948, sell = 5000 },
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

npcType:register(npcConfig)
