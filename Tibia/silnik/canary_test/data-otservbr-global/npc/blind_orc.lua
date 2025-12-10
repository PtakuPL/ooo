local internalNpcName = "Blind Orc"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 5,
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

local function addBuyableKeyword(keywords, itemid, amount, price, text)
	local keyword
	if type(keywords) == "table" then
		keyword = keywordHandler:addKeyword({ "goshak", keywords[1], keywords[2] }, StdModule.say, { npcHandler = npcHandler, text = text })
	else
		keyword = keywordHandler:addKeyword({ "goshak", keywords }, StdModule.say, { npcHandler = npcHandler, text = text })
	end

	keyword:addChildKeyword({ "mok" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_1", reset = true }, function(player)
		return player:getMoney() + player:getBankBalance() >= price
	end, function(player)
		if player:removeMoneyBank(price) then
			player:addItem(itemid, amount)
		end
	end)
	keyword:addChildKeyword({ "mok" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_2", reset = true })
	keyword:addChildKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_3", reset = true })
end

-- Greeting and Farewell
keywordHandler:addGreetKeyword({ "charach" }, { npcHandler = npcHandler, text = "Ikem Charach maruk.", i18nKey = "npc.blind_orc.greet_1" })
keywordHandler:addFarewellKeyword({ "futchi" }, { npcHandler = npcHandler, text = "Futchi!", i18nKey = "npc.blind_orc.farewell_1" })

keywordHandler:addKeyword({ "" }, StdModule.say, { npcHandler = npcHandler, onlyUnfocus = true, i18nKey = "npc.blind_orc.stdmod_4" })

keywordHandler:addKeyword({ "ikem", "goshak" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_5" })
keywordHandler:addKeyword({ "goshak", "porak" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_6" })
keywordHandler:addKeyword({ "goshak", "bata" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_7" })
keywordHandler:addKeyword({ "goshak", "dora" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.blind_orc.stdmod_8" })

-- Bow
addBuyableKeyword("batuk", 3350, 1, 400, "Ahhhh, maruk, goshak batuk?")
-- 10 Arrows
addBuyableKeyword("pixo", 3447, 10, 30, "Maruk goshak tefar pixo ul batuk?")

-- Brass Shield
addBuyableKeyword("donga", 3411, 1, 65, "Maruk goshak ta?")

-- Leather Armor
addBuyableKeyword("bora", 3361, 1, 25, "Maruk goshak ta?")
-- Studded Armor
addBuyableKeyword({ "tulak", "bora" }, 3378, 1, 90, "Maruk goshak ta?")
-- Studded Helmet
addBuyableKeyword("grofa", 3376, 1, 60, "Maruk goshak ta?")

-- Sabre
addBuyableKeyword("charcha", 3273, 1, 25, "Maruk goshak ta?")
-- Sword
addBuyableKeyword({ "burka", "bata" }, 3264, 1, 85, "Maruk goshak ta?")
-- Short Sword
addBuyableKeyword("burka", 3294, 1, 30, "Maruk goshak ta?")
-- Hatchet
addBuyableKeyword("hakhak", 3276, 1, 85, "Maruk goshak ta?")

npcHandler:setMessage(MESSAGE_WALKAWAY, "Futchi.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
