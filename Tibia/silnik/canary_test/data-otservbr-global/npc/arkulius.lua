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
	"...if the expected constant is higher than... Hmmm, who are you?? What do you want?",
	"...then I could transform a spell to bend... How can anyone expect me to work under these conditions?? What do you want?",
	"...if my calculations are correct, I will be able to revive... Arrgghh!! What do you want?",
}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	npcHandler:setMessage(MESSAGE_GREET, greetMsg[math.random(#greetMsg)])
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
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_4", "npc.arkulius.say_5", "npc.arkulius.say_6" })
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "shrine") then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_7", "npc.arkulius.say_8" })
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "sphere") and player:getLevel() >= 80 then
		NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_9", "npc.arkulius.say_10" })
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "mission") or MsgContains(message, "quest") then
		local value = player:getStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine)
		if value < 1 then
			if player:getLevel() >= 80 then
				if player:isSorcerer() then
					NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_11", "npc.arkulius.say_12", "npc.arkulius.say_13", "npc.arkulius.say_14" })
				elseif player:isDruid() then
					NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_15", "npc.arkulius.say_16", "npc.arkulius.say_17", "npc.arkulius.say_18" })
				elseif player:isPaladin() then
					NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_19", "npc.arkulius.say_20", "npc.arkulius.say_21", "npc.arkulius.say_22" })
				elseif player:isKnight() then
					NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.arkulius.say_23", "npc.arkulius.say_24", "npc.arkulius.say_25", "npc.arkulius.say_26" })
				end
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_27")
				npcHandler:setTopic(playerId, 0)
				return false
			end
			npcHandler:setTopic(playerId, 1)
		elseif value == 1 then
			if player:getItemCount(player:isSorcerer() and 946 or player:isDruid() and 947 or player:isPaladin() and 942 or player:isKnight() and 948) > 0 then
				player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 2)
				NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.arkulius.say_28", { (
							player:isSorcerer() and "an ETERNAL FLAME! Now you need to find a knight, a druid, and a paladin who also completed this first task. ..."
							or player:isDruid() and "MOTHER SOIL! Now you need to find a knight, a paladin, and a sorcerer who also completed this first task. ..."
							or player:isPaladin() and "a FLAWLESS ICE CRYSTAL! Now you need to find a knight, a druid, and a sorcerer who also completed this first task. ..."
							or player:isKnight() and "PURE ENERGY! Now you need to find a druid, a paladin, and a sorcerer who also completed this first task. ..."
						) } }, "npc.arkulius.say_29", "npc.arkulius.say_30" })
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_31", { (player:isSorcerer() and "Fire" or player:isDruid() and "Earth" or player:isPaladin() and "Ice" or player:isKnight() and "Energy") })
			end
			npcHandler:setTopic(playerId, 0)
		elseif value == 2 then
			if player:removeItem(954, 1) and player:getStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine) < 3 then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_32")
				player:addItem(player:isSorcerer() and 8039 or player:isDruid() and 8041 or player:isPaladin() and 8025 or player:isKnight() and 8055, 1)
				player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 3)
			end
		end
	elseif npcHandler:getTopic(playerId) == 1 and MsgContains(message, "yes") then
		player:setStorageValue(Storage.Quest.U8_2.ElementalSpheres.QuestLine, 1)
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.arkulius.say_33")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "How dare you asking me this?!? I'm Arkulius - Master of Elements, the HEADMASTER of this academy!!" , i18nKey = "npc.arkulius.stdmod_7"})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I'm Arkulius - Master of Elements, the headmaster of this academy." , i18nKey = "npc.arkulius.stdmod_8"})
keywordHandler:addKeyword({ "help" }, StdModule.say, { npcHandler = npcHandler, text = "I have better things to do than helping you. See that ice statue over there? My dear friend Alverus needs to be revived!" , i18nKey = "npc.arkulius.stdmod_9"})
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, text = "Time is an illusion and completely irrelevant to me." , i18nKey = "npc.arkulius.stdmod_10"})
keywordHandler:addKeyword({ "weapon" }, StdModule.say, { npcHandler = npcHandler, text = "Weapons are for those people who aren't able to use their heads or better what's INSIDE their heads. No offence <coughs>." , i18nKey = "npc.arkulius.stdmod_11"}) -- < Knight; FIXME !!!
keywordHandler:addKeyword({ "pits of inferno" }, StdModule.say, { npcHandler = npcHandler, text = "Yeye, I believe you almost feel like home among all those brainless creatures!" , i18nKey = "npc.arkulius.stdmod_12"})

npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye and please stay away, okay?")
npcHandler:setMessage(MESSAGE_FAREWELL, "At last! Good things come to those who wait.")
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
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end
-- On check npc shop message (look item)
npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
