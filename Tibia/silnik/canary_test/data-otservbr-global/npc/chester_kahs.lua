local internalNpcName = "Chester Kahs"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 131,
	lookHead = 9,
	lookBody = 28,
	lookLegs = 47,
	lookFeet = 95,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Too many possibilities to become a servant of darkness to trust ANYONE!" },
	{ text = "Don't tell me I didn't warn you." },
	{ text = "It's all a big conspiracy, mark my words." },
	{ text = "Not everything that walks our streets is human ... or even living." },
	{ text = "We are surrounded by myths, living and dead." },
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

local fire = Condition(CONDITION_FIRE)
fire:setParameter(CONDITION_PARAM_DELAYED, true)
fire:setParameter(CONDITION_PARAM_FORCEUPDATE, true)
fire:addDamage(25, 9000, -10)

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if MsgContains(message, "gamel") or MsgContains(message, "rebel") or MsgContains(message, "gamel rebel") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_1")
		npcHandler:setTopic(playerId, 1)
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_2")
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 3 then
			if player:removeItem(3061, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_3")
				player:addItem(3052, 1)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_4")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			if player:removeItem(3052, 1) then
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_5")
				player:addHealth(player:getMaxHealth())
				npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_6")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 1)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_7")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 6 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 3)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_8")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 7 then
			if player:removeItem(5956, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 5)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_9")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_10")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:removeItem(5952, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03, 3)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 7)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_11")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_12")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(348, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 9)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_13")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_14")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 10 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 11)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_15")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06, 3)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 13)
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_16")
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 12 then
			if player:removeMoneyBank(1000) then
				player:addItem(397, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_17")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_18")
			end
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 13 then
			if player:removeItem(396, 1) then
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 2)
				player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 15)
				player:addItem(897, 1)
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_19")
			else
				NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_20")
			end
			npcHandler:setTopic(playerId, 0)
		end
	elseif MsgContains(message, "no") then
		if npcHandler:getTopic(playerId) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_21")
		elseif npcHandler:getTopic(playerId) == 3 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_22")
			player:addCondition(fire)
			player:getPosition():sendMagicEffect(CONST_ME_EXPLOSIONHIT)
			npc:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
			player:removeItem(3061, 1)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_23")
		end
		npcHandler:setTopic(playerId, 0)
	elseif npcHandler:getTopic(playerId) == 2 then
		if MsgContains(message, "magic") and MsgContains(message, "crystal") and MsgContains(message, "lugri") and MsgContains(message, "deathcurse") then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_24")
			npcHandler:setTopic(playerId, 3)
		else
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_25")
		end
	elseif MsgContains(message, "heal") then
		NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_26")
		npcHandler:setTopic(playerId, 4)
	elseif MsgContains(message, "join") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) < 1 then
			npcHandler:say({
				"Our bureau is an old and traditional branch of the Thaian government. It takes more than lip service to join our ranks ...",
				"Absolute loyalty to the crown and the Thaian cause as well as courage face-to-face with the enemy is the least we expect from our members ...",
				"You will swear allegiance to Thais alone and abandon the service of any other city. So is it really your wish to become one of our field agents?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 5)
		end
	elseif MsgContains(message, "mission") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.AVINMission01) < 1 and player:getStorageValue(Storage.Quest.U8_1.SecretService.CGBMission01) < 1 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 2)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01, 1)
			npcHandler:say({
				"Your first task is to deliver a warning. Illegally, the Venoreans are crafting more ships than the Thaian authorities have allowed them ...",
				"Our sources have told us that those ships often end up in the hands of pirates or smugglers ...",
				"An official note would strain the relationship between Thais and Venore too much as this would mean that we had to admit officially that we know about those activities ...",
				"Still, we can't allow them to continue like this. It will be your task to let them know that we do not tolerate such behaviour. Get a fire bug from Liberty Bay and set their shipyard on fire ...",
				"Use the fire bug on some flammable material there to start the fire. It might take a while to find some wood that's dry enough for the fire to spread. Just keep trying ... ",
				"If you get captured or killed during your mission, we will deny any contact with you.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_27")
			npcHandler:setTopic(playerId, 6)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission01) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 3 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 4)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02, 1)
			npcHandler:say({
				"Your next mission concerns an internal matter for our agency. Some decades ago, one of our most talented field agents vanished in the Green Claw Swamp ...",
				"Nowadays, that more and more adventurers are swarming this area, there is an increasing number of reports on some sinister goings-on and mysterious ruins in the middle of the swamp ...",
				"We got some credible clues that there might be a connection between the ruins and the disappearance of our agent ...",
				"As he is already missing since decades it is unlikely that he is still alive. Nevertheless, we want you to find out something about the whereabouts of our agent in the ruins in the Green Claw Swamp, north west of Venore ...",
				"He used to write diaries, maybe you can find one of those, or some other hints, or even his remains. You have to understand that he was a member of a prestigious Thaian family. Very influential people are interested in his whereabouts ...",
				"The Green Claw Swamp is treacherous and dangerous. You will have a hard time to find any clues ...",
				"As a small incentive I think its worthy to mention that he was wearing a quite impressive armor. You may keep it for yourself if you stumble across it.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_28")
			npcHandler:setTopic(playerId, 7)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission02) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 5 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 6)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03, 1)
			npcHandler:say({
				"One of our agents is missing. He was investigating the cause for the slow growth of our colony Port Hope ...",
				"You will continue these investigations at the point where the information that the lost agent has sent us ends. Some of the traders in Port Hope must have connections to persons who are interested in sabotaging our efforts in Tiquanda ...",
				"Search their personal belongings to find some sort of evidence that we could need!",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_29")
			npcHandler:setTopic(playerId, 8)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission03) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 7 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 8)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04, 1)
			npcHandler:say({
				"Just recently we were able to secretly help our elven friends to exposure an agitator sent by Carlin to poison our connections with them. The elves' reaction wasswift and without compromise ...",
				"They banished the delinquent in a place they call 'Hellgate'. Unfortunately, we learnt later that the convict was sent there with several of his belongings and it is very likely that he took vital papers with him ...",
				"These papers can tell us much about Carlin's plans in the North. We need you to enter 'Hellgate' and to retrieve the papers for us ...",
				"We don't care how you get them. Do whatever you think is necessary.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_30")
			npcHandler:setTopic(playerId, 9)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission04) == 2 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 9 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 10)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05, 1)
			player:addItem(349, 1)
			npcHandler:say({
				"It's bad enough that Carlin got a solid foothold in the far North but now the Venoreans also try to move in. They try to gain influence on the barbarian raiders by bribing their leaders or making them great promises ...",
				"We want you to cause some bad blood in this relationship. Travel to their most southern camp, enter the ice tower of their leaders and kill some of them ...",
				"Here is a signet ring that the Venorean emissaries use to wear. 'Lose' the ring in the north-western corner of the highest level of the tower. They will surely find it there.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_31")
			npcHandler:setTopic(playerId, 10)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission05) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 11 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 12)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06, 1)
			player:addItem(397, 1)
			npcHandler:say({
				"The women of Carlin have the northern city Svargrond in the firm grip of her manicured hands. At the moment, there is little we can do about it but there is one thing that plays into our hands ...",
				"The barbarians have surely at least heard about the fact that alcohol is outlawed in Carlin ...",
				"If some amazonian warrior would smash a beer or ale cask in front of some witnesses, the relationship would surely suffer a bit. So go and disguise yourself as an amazon. Then use a crowbar to destroy a cask.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 2 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_32")
			npcHandler:setTopic(playerId, 11)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Quest) == 13 then
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Quest, 14)
			player:setStorageValue(Storage.Quest.U8_1.SecretService.Mission07, 1)
			npcHandler:say({
				"Great, you are here. We need your service in a mission of utmost urgency ...",
				"A mad dwarven technomancer that listens to the name of Blowbeard sent us a blackmailing letter. He demands to deliver all of Thais's gold to him. Else he will destroy the city with an artificial earthquake caused by one of his machines! ...",
				"We need you to find his base in Kazordoon and to kill him before he can use his infernal machine. Bring us his beard as proof of your success.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 3 and player:getStorageValue(Storage.Quest.U8_1.SecretService.Mission07) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_33")
			npcHandler:setTopic(playerId, 13)
		end
	elseif MsgContains(message, "disguise") then
		if player:getStorageValue(Storage.Quest.U8_1.SecretService.TBIMission06) == 1 then
			NPC_LIB.i18n.npcSay(npcHandler, npc, creature, "npc.chester_kahs.say_34")
			npcHandler:setTopic(playerId, 12)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Salutations, stranger.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Take care out there!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Take care out there!")

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)

npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
