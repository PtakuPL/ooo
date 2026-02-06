-- ============================================
-- EXAMPLE NPC WITH FULL I18N SUPPORT
-- ============================================
-- This is a template showing how to properly
-- internationalize an NPC using the i18n system.
--
-- Key features:
-- 1. All text uses NPC_LIB.i18n.npcSay()
-- 2. Voices use i18nKey parameter
-- 3. Greeting uses i18n key
-- ============================================

local internalNpcName = "Example Merchant"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 128,  -- citizen male
	lookHead = 78,
	lookBody = 69,
	lookLegs = 58,
	lookFeet = 76,
}

npcConfig.flags = {
	floorchange = false,
}

-- ============================================
-- VOICES (with i18n keys)
-- Format: addVoice(text, interval, chance, yell, i18nKey)
-- ============================================
npcConfig.voices = {
	interval = 15000,  -- 15 seconds
	chance = 50,       -- 50% chance
	{
		i18nKey = "npc.example_merchant_i18n.voice_1",  -- Fallback for old clients
		yell = false,
		i18nKey = "nv.example_merchant.1"  -- Key for translation
	},
	{
		i18nKey = "npc.example_merchant_i18n.voice_2",
		yell = false,
		i18nKey = "nv.example_merchant.2"
	},
	{
		i18nKey = "npc.example_merchant_i18n.voice_3",
		yell = true,  -- This is a yell
		i18nKey = "nv.example_merchant.3"
	},
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

-- ============================================
-- GREETING CALLBACK (with i18n)
-- ============================================
local function greetCallback(npc, creature)
	local player = Player(creature)
	if not player then
		return false
	end
	
	-- Check if player has enough level for this shop
	if player:getLevel() < 8 then
		-- I18N: Use localized message for low level
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.example_merchant.low_level")
		npcHandler:resetNpc(creature)
		return false
	end
	
	-- Normal greeting - set dynamic greeting with player name
	npcHandler:setLocalizedMessage(MESSAGE_GREET, "npc.example_merchant_i18n.greet_msg_1", {
		args = function(targetPlayer)
			return { targetPlayer:getName() }
		end,
	})
	return true
end

-- ============================================
-- CONVERSATION CALLBACK (with i18n)
-- ============================================
local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	if not player then
		return false
	end
	
	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end
	
	local playerId = player:getId()
	
	-- Handle "help" keyword
	if MsgContains(message, "help") then
		-- I18N: Send localized help message
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.example_merchant.help")
		return true
	end
	
	-- Handle "job" keyword
	if MsgContains(message, "job") then
		-- I18N: Send localized job description
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.example_merchant.job")
		return true
	end
	
	-- Handle "name" keyword
	if MsgContains(message, "name") then
		-- I18N: Send localized name response
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.example_merchant.name")
		return true
	end
	
	-- Handle "news" keyword
	if MsgContains(message, "news") or MsgContains(message, "rumors") then
		-- I18N: Send multiple localized messages
		NPC_LIB.i18n.npcSayTable(npcHandler, npc, creature, {
			"npc.example_merchant.news_1",
			"npc.example_merchant.news_2"
		})
		return true
	end
	
	-- Handle "special" keyword - demonstrate dynamic text
	if MsgContains(message, "special") then
		-- For dynamic text with variables, we can either:
		-- 1. Use server-side formatting (less optimal but more flexible)
		-- 2. Send key + variables to client (more optimal)
		
		-- Option 1: Server formats, sends plain text
		local discount = 20
		local itemName = "Magic Sword"
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.example_merchant_i18n.say_1", { itemName, discount })
		
		-- Option 2 (future): Send key with args to client
		-- player:sendLocalizedTextMessage(MESSAGE_NPC_FROM, "npc.example_merchant.special", {discount, itemName})
		return true
	end
	
	return false
end

-- ============================================
-- NPC HANDLER SETUP
-- ============================================
npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

-- Add basic keywords with i18n
keywordHandler:addKeyword({"bye"}, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.example_merchant_i18n.stdmod_1",
	i18nKey = "npc.example_merchant.farewell"  -- I18N key for this response
})

keywordHandler:addKeyword({"trade"}, StdModule.say, {
	npcHandler = npcHandler,
	i18nKey = "npc.example_merchant_i18n.stdmod_2",
	i18nKey = "npc.example_merchant.trade",
	-- This would also open trade window
	-- onSay = function(npc, creature)
	-- 	npcHandler:openTrade(npc, creature, shopModule)
	-- end
})

-- ============================================
-- FINISH NPC SETUP
-- ============================================
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType:register(npcConfig)

-- ============================================
-- REQUIRED I18N KEYS (to add to locale files)
-- ============================================
--[[
The following keys should be added to:
- Server: i18n/en/npc.json and i18n/pl/npc.json
- Client: testyy/data/locales/game_i18n_*.lua

ENGLISH (en):
{
  "npc.example_merchant.greeting": "Hello %s! Welcome to my shop. Say {trade} to see my offers.",
  "npc.example_merchant.low_level": "Sorry, but you are too inexperienced. Come back when you reach level 8.",
  "npc.example_merchant.farewell": "Farewell, %s. Visit me again!",
  "npc.example_merchant.help": "I can sell you potions, weapons and armor. Say {trade} to browse my goods.",
  "npc.example_merchant.job": "I am a merchant. I sell various goods to adventurers.",
  "npc.example_merchant.name": "My name is Marcus. I run this shop.",
  "npc.example_merchant.trade": "Of course! Here are my offers.",
  "npc.example_merchant.news_1": "Have you heard? Dragons were spotted near the mountains!",
  "npc.example_merchant.news_2": "The king is looking for brave adventurers.",
  "nv.example_merchant.1": "Best potions in town!",
  "nv.example_merchant.2": "Quality weapons and armor!",
  "nv.example_merchant.3": "SPECIAL OFFERS TODAY!"
}

POLISH (pl):
{
  "npc.example_merchant.greeting": "Witaj %s! Zapraszam do mojego sklepu. Powiedz {trade} aby zobaczyć ofertę.",
  "npc.example_merchant.low_level": "Przepraszam, ale jesteś zbyt niedoświadczony. Wróć gdy osiągniesz poziom 8.",
  "npc.example_merchant.farewell": "Żegnaj, %s. Odwiedź mnie ponownie!",
  "npc.example_merchant.help": "Mogę sprzedać ci mikstury, bronie i zbroje. Powiedz {trade} żeby przejrzeć towary.",
  "npc.example_merchant.job": "Jestem kupcem. Sprzedaję różne towary poszukiwaczom przygód.",
  "npc.example_merchant.name": "Mam na imię Marcus. Prowadzę ten sklep.",
  "npc.example_merchant.trade": "Oczywiście! Oto moja oferta.",
  "npc.example_merchant.news_1": "Słyszałeś? Smoki zostały zauważone w pobliżu gór!",
  "npc.example_merchant.news_2": "Król szuka dzielnych poszukiwaczy przygód.",
  "nv.example_merchant.1": "Najlepsze mikstury w mieście!",
  "nv.example_merchant.2": "Bronie i zbroje wysokiej jakości!",
  "nv.example_merchant.3": "DZISIEJSZE PROMOCJE!"
}
--]]
