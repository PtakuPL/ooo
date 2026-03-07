local internalNpcName = "Padreia"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 138,
	lookHead = 0,
	lookBody = 87,
	lookLegs = 85,
	lookFeet = 95,
	lookAddons = 0,
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

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Tibia tales quest
	if MsgContains(message, "cough syrup") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_11")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.TibiaTales.TheExterminator) == -1 then
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { { "npc.padreia.say_12", { player:getName() } }, "npc.padreia.say_13" })
			npcHandler:setTopic(playerId, 2)
		elseif player:getStorageValue(Storage.Quest.U8_1.TibiaTales.TheExterminator) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_14")
		elseif player:getStorageValue(Storage.Quest.U8_1.TibiaTales.TheExterminator) == 2 then
			local itemId = { 3033, 3032, 3030, 3029 }
			for i = 1, #itemId do
				player:addItem(itemId[i], 1)
			end
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.TheExterminator, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_15")
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_16")
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			if not player:removeMoneyBank(50) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_17")
				return true
			end

			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_18")
			player:addItem(4828, 1)
		elseif npcHandler:getTopic(playerId) == 2 then
			player:addItem(135, 1)
			player:setStorageValue(Storage.Quest.U8_1.TibiaTales.TheExterminator, 1)
			NPC_LIB.i18n.npcSayMultiple(npcHandler, npc, creature, { "npc.padreia.say_19", "npc.padreia.say_20" })
		end
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_21")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_22")
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- The paradox tower quest
	if MsgContains(message, "crunor's caress") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_23")
		npcHandler:setTopic(playerId, 0)
	elseif MsgContains(message, "footnote") then
		if player:getStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo) == 2 then
			-- Questlog: The Feared Hugo (Lubo)
			player:setStorageValue(Storage.Quest.U7_24.TheParadoxTower.TheFearedHugo, 3)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.padreia.say_24")
		npcHandler:setTopic(playerId, 0)
	end
	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, text = "I am the grand druid of Carlin. I am responsible for the guild, the fields, and our citizens' health." , i18nKey = "npc.padreia.stdmod_8"})
keywordHandler:addKeyword({ "magic" }, StdModule.say, { npcHandler = npcHandler, text = "Every druid is able to learn the numerous spells of our craft." , i18nKey = "npc.padreia.stdmod_9"})
--keywordHandler:addKeyword({'spell'}, StdModule.say, {npcHandler = npcHandler, text = "Sorry, I don't teach spells for your vocation."})
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, text = "I am Padreia, grand druid of our fine city." , i18nKey = "npc.padreia.stdmod_10"})
keywordHandler:addKeyword({ "time" }, StdModule.say, { npcHandler = npcHandler, text = "Time is just a crystal pillar - the centre of creation and life." , i18nKey = "npc.padreia.stdmod_11"})
keywordHandler:addKeyword({ "druids" }, StdModule.say, { npcHandler = npcHandler, text = "We are druids, preservers of life. Our magic is about defence, healing, and nature." , i18nKey = "npc.padreia.stdmod_12"})
keywordHandler:addKeyword({ "sorcerers" }, StdModule.say, { npcHandler = npcHandler, text = "Sorcerers are destructive. Their power lies in destruction and pain." , i18nKey = "npc.padreia.stdmod_13"})

npcHandler:setMessage(MESSAGE_GREET, "Welcome to our humble guild, wanderer. May I be of any assistance to you?")
npcHandler:setMessage(MESSAGE_FAREWELL, "Farewell.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Farewell.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
