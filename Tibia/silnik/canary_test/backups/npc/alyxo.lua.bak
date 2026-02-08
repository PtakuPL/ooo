local internalNpcName = "Alyxo"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 330,
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

local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Access) < 1 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.alyxo.greet_msg_1") -- It needs to be revised, it's not the same as the global
		npcHandler:setTopic(playerId, 1)
	elseif (player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.JamesfrancisTask) >= 0 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.JamesfrancisTask) <= 50) and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Mission) < 3 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.alyxo.greet_msg_2") -- It needs to be revised, it's not the same as the global
		npcHandler:setTopic(playerId, 15)
	elseif player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Mission) == 4 then
		NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_GREET, "npc.alyxo.greet_msg_3") -- It needs to be revised, it's not the same as the global
		player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.First.Mission, 5)
		npcHandler:setTopic(playerId, 20)
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	-- Mission 3 Steal The Ambassador Ring
	if MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 1 then
			npcHandler:setTopic(playerId, 1)
		end
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_1") -- needs review, this is not the speech of the global
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_2") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss, 2)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Bragrumol, 1)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Mozradek, 1)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Xogixath, 1)
			npcHandler:setTopic(playerId, 2)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_3")
			npcHandler:setTopic(playerId, 0)
		end
	end
	-- Mission 3 Steal The Ambassador Ring
	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 2 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_4") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 3 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 2 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Bragrumol) == 2 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Mozradek) == 2 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Xogixath) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_5") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss, 3)
			npcHandler:setTopic(playerId, 4)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_6")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 3 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_7") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 5)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 5 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 3 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_8") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Twelve.Boss, 4)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar, 1)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre, 1)
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente, 1)
			npcHandler:setTopic(playerId, 6)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_9")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "report") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 300 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 300 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_10") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 7)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 7 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 300 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 300 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_11") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar, 301)
			npcHandler:setTopic(playerId, 8)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_12")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "report") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 3 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_13") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 9 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 3 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre) == 3 and player:getItemById(31447, 1) then
			player:removeItem(31447, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_14") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Lyre, 4)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_15")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "report") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente) == 2 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_16") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 11)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 11 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente) == 2 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente) == 2 and player:getItemById(31445, 1) then
			player:removeItem(31445, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_17") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Presente, 3)
			npcHandler:setTopic(playerId, 12)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_18")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "small tortoise") then
		if player:getItemById(31445, 1) then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_19") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 15)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 15 then
		if player:getItemById(31445, 1) then
			player:removeItem(31445, 1)
			player:addItem(31446, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_20") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 16)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_21")
			npcHandler:setTopic(playerId, 0)
		end
	end
	if MsgContains(message, "mission") and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 301 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 301 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_22") -- needs review, this is not the speech of the global
			npcHandler:setTopic(playerId, 13)
		end
	elseif MsgContains(message, "yes") and npcHandler:getTopic(playerId) == 13 and player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 301 then
		if player:getStorageValue(Storage.Quest.U12_20.KilmareshQuest.Thirteen.Fafnar) == 301 then
			player:addAchievement("Sculptor Apprentice", 'Congratulations! You earned the achievement "Sculptor Apprentice".')
			player:addItem(31574, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_23") -- needs review, this is not the speech of the global
			player:setStorageValue(Storage.Quest.U12_20.KilmareshQuest.Fourteen.Remains, 1)
			npcHandler:setTopic(playerId, 14)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.alyxo.say_24")
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

NPC_LIB.i18n.setLocalizedMessage(npcHandler, MESSAGE_WALKAWAY, "npc.alyxo.walkaway_msg_1")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
