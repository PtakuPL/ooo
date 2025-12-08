local internalNpcName = "Santiago"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 151,
	lookHead = 38,
	lookBody = 115,
	lookLegs = 87,
	lookFeet = 114,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Evil little beasts... I hope someone helps me fight them." },
	{ text = "Nasty creepy crawlies!" },
	{ text = "Hey! You over there, could you help me with a little quest? Just say 'hi' or 'hello' to talk to me!" },
	{ text = "Don't be shy, can't hurt to greet me with 'hello' or 'hi'!" },
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

local storeTalkCid = {}
local function greetCallback(npc, creature)
	local player = Player(creature)
	local playerId = player:getId()

	if player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) < 1 then
		player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 1)
		player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 1)
		npcHandler:setMessage(MESSAGE_GREET, "Hello |PLAYERNAME|, nice to see you on Rookgaard! I saw you walking by and wondered if you could help me. Could you? Please, say {yes}!")
		storeTalkCid[playerId] = 0
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 1 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh, |PLAYERNAME|, it's you again! It's probably impolite to disturb a busy adventurer like you, but I really need help. Please, say {yes}!")
		storeTalkCid[playerId] = 0
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 2 then
		npcHandler:sayLocalized("npc.santiago.oh_whats_wrong_1", npc, creature)
		Position(32033, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
		return false
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 3 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back, |PLAYERNAME|! Ahh, you found my chest. Let me take a look at you. You put on that coat, {yes}?")
		storeTalkCid[playerId] = 2
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 4 then
		npcHandler:setMessage(MESSAGE_GREET, "Hey, I want to give you a weapon for free! You should not refuse that, in fact you should say '{yes}'!")
		storeTalkCid[playerId] = 2
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 5 then
		npcHandler:sayLocalized("npc.santiago.ive_forgotten_to_2", npc, creature)
		return false
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 6 then
		if player:removeItem(7882, 3) then
			npcHandler:setMessage(MESSAGE_GREET, "Good job! For that, I'll grant you 100 experience points! Oh - what was that? I think you advanced a level, {right}?")
			player:addExperience(100, true)
			player:getPosition():sendMagicEffect(CONST_ME_GIFT_WRAPS)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 5)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 7)
			storeTalkCid[playerId] = 4
		else
			npcHandler:sayLocalized("npc.santiago.ive_forgotten_to_3", npc, creature)
			return false
		end
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 7 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I asked you if you saw your 'level up'! You did, {right}?")
		storeTalkCid[playerId] = 4
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 8 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I asked you if those nasty cockroaches {hurt} you! Did they?")
		storeTalkCid[playerId] = 5
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 9 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I asked you if I should demonstrate some damage on you. Let's do it, {okay}?")
		storeTalkCid[playerId] = 6
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 10 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I was about to show you how you regain health, right?")
		storeTalkCid[playerId] = 7
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 11 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I gave you a fish to eat?")
		storeTalkCid[playerId] = 8
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 12 then
		npcHandler:setMessage(MESSAGE_GREET, "Welcome back! Where were we... ? Ah, right, I asked you if you saw Zirella! Did you?")
		storeTalkCid[playerId] = 9
	elseif player:getStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage) == 13 then
		npcHandler:setMessage(MESSAGE_GREET, "Hello again, |PLAYERNAME|! It's great to see you. If you like, we can chat a little. Just use the highlighted {keywords} again to choose a {topic}.")
	end
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "yes", "right", "ok" }, message) then
		if storeTalkCid[playerId] == 0 then
			npcHandler:sayLocalized("npc.santiago.great_please_go_4", npc, creature)
			Position(32033, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			storeTalkCid[playerId] = 1
		elseif storeTalkCid[playerId] == 1 then
			npcHandler:sayLocalized("npc.santiago.alright_do_you_5", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 2)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 2)
			player:sendTutorial(3)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif storeTalkCid[playerId] == 2 then
			if player:getItemCount(3562) > 0 then
				local coatSlot = player:getSlotItem(CONST_SLOT_ARMOR)
				if coatSlot then
					npcHandler:sayLocalized("npc.santiago.ah_no_need_6", npc, creature)
					player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 4)
					storeTalkCid[playerId] = 3
				else
					npcHandler:sayLocalized("npc.santiago.oh_you_dont_7", npc, creature)
					player:sendTutorial(5)
					storeTalkCid[playerId] = 2
				end
			else
				player:addItem(3562, 1)
				npcHandler:sayLocalized("npc.santiago.oh_no_did_8", npc, creature)
				storeTalkCid[playerId] = 3
			end
		elseif storeTalkCid[playerId] == 3 then
			npcHandler:sayLocalized("npc.santiago.i_knew_i_9", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 5)
			Position(32036, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			player:addItem(3270, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		elseif storeTalkCid[playerId] == 4 then
			npcHandler:sayLocalized("npc.santiago.thats_just_great_10", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 8)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 6)
			storeTalkCid[playerId] = 5
		elseif storeTalkCid[playerId] == 5 then
			npcHandler:sayLocalized("npc.santiago.really_you_look_11", npc, creature)
			player:sendTutorial(19)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 9)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 7)
			storeTalkCid[playerId] = 6
		elseif storeTalkCid[playerId] == 6 then
			npcHandler:sayLocalized("npc.santiago.this_is_an_12", npc, creature)
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			npc:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:addHealth(-20, COMBAT_PHYSICALDAMAGE)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 10)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 8)
			player:sendTutorial(19)
			storeTalkCid[playerId] = 7
		elseif storeTalkCid[playerId] == 7 then
			npcHandler:say({
				"Here, take this fish which I've caught myself. Find it in your inventory, then 'Use' it to eat it. This will slowly refill your health. ...",
				"By the way: If your hitpoints are below 150, you will regenerate back to 150 hitpoints after few seconds as long as you are not hungry, outside a protection zone and do not have a battle sign. {Easy}, yes?",
			}, npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 9)
			player:addItem(3578, 1)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 11)
			storeTalkCid[playerId] = 8
		elseif storeTalkCid[playerId] == 8 then
			npcHandler:sayLocalized("npc.santiago.i_knew_youd_13", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 12)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 10)
			storeTalkCid[playerId] = 9
		elseif storeTalkCid[playerId] == 9 then
			npcHandler:sayLocalized("npc.santiago.really_she_was_14", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 13)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 11)
			player:addMapMark(Position(32045, 32270, 6), MAPMARK_GREENSOUTH, "To Zirella")
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "hurt") then
		if storeTalkCid[playerId] == 6 then
			npcHandler:sayLocalized("npc.santiago.this_is_an_15", npc, creature)
			player:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			npc:getPosition():sendMagicEffect(CONST_ME_MORTAREA)
			player:addHealth(-20, COMBAT_PHYSICALDAMAGE)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 8)
			player:sendTutorial(19)
			storeTalkCid[playerId] = 7
		end
	elseif MsgContains(message, "action") then
		if storeTalkCid[playerId] == 3 then
			npcHandler:sayLocalized("npc.santiago.i_knew_i_16", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 4)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 5)
			Position(32036, 32277, 6):sendMagicEffect(CONST_ME_TUTORIALARROW)
			player:addItem(3270, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
	elseif MsgContains(message, "easy") then
		if storeTalkCid[playerId] == 8 then
			npcHandler:sayLocalized("npc.santiago.i_knew_youd_17", npc, creature)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoNpcGreetStorage, 11)
			player:setStorageValue(Storage.Quest.U8_2.TheBeginningQuest.SantiagoQuestLog, 10)
			storeTalkCid[playerId] = 9
		end
	end
	return true
end

local function onReleaseFocus(npc, creature)
	local playerId = creature:getId()
	storeTalkCid[playerId] = nil
end

npcHandler:setCallback(CALLBACK_REMOVE_INTERACTION, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Take care, |PLAYERNAME|!.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Good bye traveller, and enjoy your stay on Rookgaard.")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
