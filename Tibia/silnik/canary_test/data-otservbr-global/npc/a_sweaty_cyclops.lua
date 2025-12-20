local internalNpcName = "A Sweaty Cyclops"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 22,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ i18nKey = "npc.a_sweaty_cyclops.voice_1" },
	{ i18nKey = "npc.a_sweaty_cyclops.voice_2" },
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

	-- uth'lokr (Bast Skirts)
	if MsgContains(message, "uth'lokr") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_3")
			if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops, 1)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(3560, 3) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_4")
				player:setStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_5")
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "bast skirt") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 1 then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_6")
			npcHandler:setTopic(playerId, 4)
		end
	end
	-- uth'lokr (Bast Skirts)
	if MsgContains(message, "uth'lokr") and player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheSweatyCyclops) < 1 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_7")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_8")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_9")
			if player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart) ~= 1 then
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.DefaultStart, 1)
			end
			player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheSweatyCyclops, 1)
			npcHandler:setTopic(playerId, 3)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(3560, 3) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_10")
				player:setStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheSweatyCyclops, 2)
				npcHandler:setTopic(playerId, 0)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_11")
				npcHandler:setTopic(playerId, 3)
			end
		end
	elseif MsgContains(message, "bast skirt") and player:getStorageValue(Storage.Quest.U7_8.FriendsAndTraders.TheSweatyCyclops) == 1 then
		if npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_12")
			npcHandler:setTopic(playerId, 4)
		end
	end

	-- Uth'kean (Crown Armor - Piece of Royal Steel)
	if MsgContains(message, "uth'kean") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_13")
		npcHandler:setTopic(playerId, 5)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 then
		if player:removeItem(3381, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_14")
			player:addItem(5887, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- uth'lokr (Dragon Shield - Piece of Draconian Steel)
	if MsgContains(message, "uth'lokr") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_15")
		npcHandler:setTopic(playerId, 6)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 6 then
		if player:removeItem(3416, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_16")
			player:addItem(5889, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- za'ralator (Devil Helmet - Piece of Hell Steel)
	if MsgContains(message, "za'ralator") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_17")
		npcHandler:setTopic(playerId, 7)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 7 then
		if player:removeItem(3356, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_18")
			player:addItem(5888, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- uth'prta (Giant Sword - Huge Chunk of Crude Iron)
	if MsgContains(message, "uth'prta") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_19")
		npcHandler:setTopic(playerId, 8)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 8 then
		if player:removeItem(3281, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_20")
			player:addItem(5892, 1)
			npcHandler:setTopic(playerId, 0)
		end
	end

	-- soul orb (soul orb - Infernal Bolts)
	if MsgContains(message, "soul orb") and player:getStorageValue(Storage.Quest.U7_8.FriendsandTraders.TheSweatyCyclops) == 2 then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_21")
		npcHandler:setTopic(playerId, 9)
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 9 then
		if player:getItemCount(5944) > 0 then
			local count = player:getItemCount(5944)
			for i = 1, count do
				if math.random(100) <= 1 then
					player:addItem(6528, 6)
					player:removeItem(5944, 1)
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_22")
				else
					player:addItem(6528, 3)
					player:removeItem(5944, 1)
					NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.a_sweaty_cyclops.say_23")
				end
			end
			npcHandler:setTopic(playerId, 0)
		end
	end

	return true
end

keywordHandler:addKeyword({ "job" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_1" })
keywordHandler:addKeyword({ "smith" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_2" })
keywordHandler:addKeyword({ "steel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_3" })
keywordHandler:addKeyword({ "zatragil" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_4" })
keywordHandler:addKeyword({ "uth'doon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_5" })
keywordHandler:addKeyword({ "za'kalortith" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_6" })
keywordHandler:addKeyword({ "mesh kaha rogh" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_7" })
keywordHandler:addKeyword({ "uth'byth" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_8" })
keywordHandler:addKeyword({ "uth'maer" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_9" })
keywordHandler:addKeyword({ "uth'amon" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_10" })
keywordHandler:addKeyword({ "ab'dendriel" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_11" })
keywordHandler:addKeyword({ "lil' lil'" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_12" })
keywordHandler:addKeyword({ "tibia" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_13" })
keywordHandler:addKeyword({ "teshial" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_14" })
keywordHandler:addKeyword({ "cenath" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_15" })
keywordHandler:addKeyword({ "name" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_16" })
keywordHandler:addKeyword({ "god" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_17" })
keywordHandler:addKeyword({ "fire sword" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_18" })
keywordHandler:addKeyword({ "dragon shield" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_19" })
keywordHandler:addKeyword({ "sword of valor" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_20" })
keywordHandler:addKeyword({ "warlord sword" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_21" })
keywordHandler:addKeyword({ "minotaurs" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_22" })
keywordHandler:addKeyword({ "elves" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_23" })
keywordHandler:addKeyword({ "excalibug" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_24" })
keywordHandler:addKeyword({ "cyclops" }, StdModule.say, { npcHandler = npcHandler, i18nKey = "npc.a_sweaty_cyclops.stdmod_25" })

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.a_sweaty_cyclops.greet_msg_1")
NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_FAREWELL, "npc.a_sweaty_cyclops.farewell_msg_1")

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
