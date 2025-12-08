local internalNpcName = "Bron"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 143,
	lookHead = 95,
	lookBody = 94,
	lookLegs = 132,
	lookFeet = 86,
	lookAddons = 2,
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

	if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 6 then
		npcHandler:setMessage(MESSAGE_GREET, "Oh no! Was that really me? This is so embarassing, I have no idea what has gotten into me. Was that the fighting spirit you gave me?")
	end

	return true
end

keywordHandler:addKeyword({ "gelagos" }, StdModule.say, { npcHandler = npcHandler, text = "This... person... makes me want to... say something bad... must... control myself. <sweats>" })

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	if table.contains({ "recruitment", "violence", "outfit", "addon" }, message) then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) < 1 then
			npcHandler:say({
				"Convincing Ajax that it is not always necessary to use brute force... this would be such an achievement. Definitely a hard task though. ...",
				"Listen, I simply have to ask, maybe a stranger can influence him better than I can. Would you help me with my brother?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 1)
		end
	elseif MsgContains(message, "brother is right. fist not always good.") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 3 then
			npcHandler:sayLocalized("npc.bron.oh_he_really_1", npc, creature)
			npcHandler:setTopic(playerId, 3)
		end
	elseif MsgContains(message, "person") then
		if npcHandler:getTopic(playerId) == 3 then
			npcHandler:say({
				"This... person... makes me want to... say something bad... must... control myself. <sweats> I really don't know what to do anymore. ...",
				"I wonder if Ajax has an idea. Could you ask him about Gelagos?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 4)
		end
	elseif MsgContains(message, "fighting spirit") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 5 then
			if player:removeItem(5884, 1) then
				npcHandler:sayLocalized("npc.bron.fighting_spirit_what_2", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 6)
				npcHandler:setTopic(playerId, 0)
			end
		end
	elseif MsgContains(message, "red piece of cloth") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 7 then
			npcHandler:sayLocalized("npc.bron.have_you_really_3", npc, creature)
			npcHandler:setTopic(playerId, 8)
		end
	elseif MsgContains(message, "rolls of spider silk") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 8 then
			npcHandler:sayLocalized("npc.bron.oh_did_you_4", npc, creature)
			npcHandler:setTopic(playerId, 9)
		end
	elseif MsgContains(message, "warriors sweat") then
		if player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 9 then
			npcHandler:sayLocalized("npc.bron.were_you_able_5", npc, creature)
			npcHandler:setTopic(playerId, 10)
		end
	elseif MsgContains(message, "yes") then
		if npcHandler:getTopic(playerId) == 1 then
			npcHandler:say({
				"Really! That is such an incredibly nice offer! I already have a plan. You have to teach him that sometimes words are stronger than fists. ...",
				"Maybe you can provoke him with something to get angry, like saying... 'MINE!' or something. But beware, I'm sure that he will try to hit you. ...",
				"Don't do this if you feel weak or ill. He will probably want to make you leave by using violence, but just stay strong and refuse to give up. ...",
				"If he should ask what else is necessary to make you leave, tell him to 'say please'. Afterwards, do leave and return to him one hour later. ...",
				"This way he might learn that violence doesn't always help, but that a friendly word might just do the trick. ...",
				"Have you understood everything I told you and are really willing to take this risk?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 2)
		elseif npcHandler:getTopic(playerId) == 2 then
			npcHandler:sayLocalized("npc.bron.you_are_indeed_6", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 1)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 4 then
			npcHandler:sayLocalized("npc.bron.again_i_have_7", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 4)
			npcHandler:setTopic(playerId, 0)
		elseif player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 6 and npcHandler:getTopic(playerId) == 0 then
			npcHandler:say({
				"I'm impressed... I am sure this was Ajax' idea. I would love to give him a present, but if I leave my hut to gather ingredients, hewill surely notice. ...",
				"Would you maybe help me again, one last time, my friend? I assure you that your efforts will not be in vain.",
			}, npc, creature)
			npcHandler:setTopic(playerId, 6)
		elseif npcHandler:getTopic(playerId) == 6 then
			npcHandler:say({
				"Great! You see, I really would love to sew a nice shirt for him. I just need a few things for that, so please listen closely: ...",
				"He loves green and red, so I will need about 50 pieces of red cloth - like the material heroes make their capes of - and 50 pieces of the green cloth Djinns like. ...",
				"Secondly, I need about 10 rolls of spider silk yarn. I think mermaids can yarn silk of large spiders to create a smooth thread. ...",
				"The only remaining thing needed would be a bottle of warrior's sweat to spray it over the shirt... he just loves this smell. ...",
				"Have you understood everything I told you and are willing to handle this task?",
			}, npc, creature)
			npcHandler:setTopic(playerId, 7)
		elseif npcHandler:getTopic(playerId) == 7 then
			npcHandler:sayLocalized("npc.bron.thank_you_my_8", npc, creature)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 7)
			npcHandler:setTopic(playerId, 0)
		elseif npcHandler:getTopic(playerId) == 8 then
			if player:getItemCount(5910) >= 50 and player:getItemCount(5911) >= 50 then
				npcHandler:sayLocalized("npc.bron.terrific_i_will_9", npc, creature)
				player:removeItem(5910, 50)
				player:removeItem(5911, 50)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 8)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 9 then
			if player:removeItem(5886, 10) then
				npcHandler:sayLocalized("npc.bron.im_impressed_you_10", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 9)
				npcHandler:setTopic(playerId, 0)
			end
		elseif npcHandler:getTopic(playerId) == 10 then
			if player:removeItem(5885, 1) then
				npcHandler:sayLocalized("npc.bron.good_work_playername_11", npc, creature)
				player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 10)
				npcHandler:setTopic(playerId, 0)
			end
		elseif player:getStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon) == 10 then
			npcHandler:sayLocalized("npc.bron.i_have_kept_12", npc, creature)
			player:addOutfitAddon(147, 2)
			player:addOutfitAddon(143, 2)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
			player:setStorageValue(Storage.Quest.U7_8.BarbarianOutfits.BarbarianAddon, 11)
			npcHandler:setTopic(playerId, 0)
		end
	end
	return true
end

npcHandler:setMessage(MESSAGE_GREET, "Welcome to my humble hut, |PLAYERNAME|.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:setMessage(MESSAGE_FAREWELL, "Take care, |PLAYERNAME|!")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Take care!")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
