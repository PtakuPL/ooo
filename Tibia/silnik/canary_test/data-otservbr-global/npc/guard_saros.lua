local internalNpcName = "Guard Saros"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 2000
npcConfig.walkRadius = 2

npcConfig.outfit = {
	lookType = 25,
	lookHead = 0,
	lookBody = 0,
	lookLegs = 0,
	lookFeet = 0,
	lookAddons = 0,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Praised be Suon, the Benevolent King!" },
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

local price = {}

local function greetCallback(npc, creature)
	local playerId = creature:getId()
	if Player(creature):getSex() == PLAYERSEX_FEMALE then
		npcHandler:setMessage(MESSAGE_GREET, "Suon's and Bastesh's blessings! Welcome to {Issavi}, traveller.")
		npcHandler:setTopic(playerId, 1)
	else
		npcHandler:setMessage(MESSAGE_GREET, "Suon's and Bastesh's blessings! Welcome to {Issavi}, traveller.")
		npcHandler:setTopic(playerId, nil)
	end
	price[playerId] = nil
	return true
end

local function creatureSayCallback(npc, creature, type, message)
	local player = Player(creature)
	local playerId = player:getId()

	if not npcHandler:checkInteraction(npc, creature) then
		return false
	end

	local Sex = player:getSex()
	if npcHandler:getTopic(playerId) == 1 then
		npcHandler:sayLocalized("npc.guard_saros.i_would_never_1", npc, creature)
		npcHandler:setTopic(playerId, nil)
	elseif npcHandler:getTopic(playerId) == 2 then
		if player:removeMoneyBank(price[playerId]) then
			npcHandler:sayLocalized("npc.guard_saros.oh_sorry_i_2", npc, creature)
		else
			npcHandler:sayLocalized("npc.guard_saros.oh_i_just_3", npc, creature)
			npcHandler:removeInteraction(npc, creature)
			npcHandler:resetNpc(creature)
		end
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
	elseif npcHandler:getTopic(playerId) == 3 and player:removeItem(2906, 1) then
		npcHandler:sayLocalized("npc.guard_saros.take_some_time_4", npc, creature)
		npcHandler:setTopic(playerId, nil)
	elseif npcHandler:getTopic(playerId) == 4 and (MsgContains(message, "spouse") or MsgContains(message, "girlfriend")) then
		npcHandler:sayLocalized("npc.guard_saros.well_i_have_5", npc, creature)
		npcHandler:setTopic(playerId, 5)
	elseif npcHandler:getTopic(playerId) == 5 and MsgContains(message, "fruit") then
		npcHandler:sayLocalized("npc.guard_saros.i_remember_that_6", npc, creature)
		npcHandler:setTopic(playerId, nil)
	elseif MsgContains(message, "how") and MsgContains(message, "are") and MsgContains(message, "you") then
		npcHandler:sayLocalized("npc.guard_saros.thank_you_very_7", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "sell") then
		npcHandler:sayLocalized("npc.guard_saros.this_is_the_8", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "job") or MsgContains(message, "issavi") then
		npcHandler:sayLocalized("npc.guard_saros.issavi_is_the_9", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "name") then
		if Sex == PLAYERSEX_FEMALE then
			npcHandler:sayLocalized("npc.guard_saros.i_am_aruda_10", npc, creature)
		else
			npcHandler:sayLocalized("npc.guard_saros.i_am_a_11", npc, creature)
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "aruda") then
		if Sex == PLAYERSEX_FEMALE then
			npcHandler:sayLocalized("npc.guard_saros.yes_thats_me_12", npc, creature)
		else
			npcHandler:sayLocalized("npc.guard_saros.oh_i_like_13", npc, creature)
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "time") then
		npcHandler:sayLocalized("npc.guard_saros.please_dont_be_14", npc, creature)
		npcHandler:setTopic(playerId, 3)
	elseif MsgContains(message, "help") then
		npcHandler:sayLocalized("npc.guard_saros.i_am_deeply_15", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "monster") or MsgContains(message, "dungeon") then
		npcHandler:sayLocalized("npc.guard_saros.uh_what_a_16", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "sewer") then
		npcHandler:sayLocalized("npc.guard_saros.what_gives_you_17", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "god") then
		npcHandler:sayLocalized("npc.guard_saros.you_should_ask_18", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "king") then
		npcHandler:sayLocalized("npc.guard_saros.the_king_that_19", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 10
	elseif MsgContains(message, "sam") then
		if Sex == PLAYERSEX_FEMALE then
			npcHandler:sayLocalized("npc.guard_saros.he_is_soooo_20", npc, creature)
		else
			npcHandler:sayLocalized("npc.guard_saros.he_is_soooo_21", npc, creature)
		end
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "benjamin") then
		npcHandler:sayLocalized("npc.guard_saros.he_is_a_22", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "gorn") then
		npcHandler:sayLocalized("npc.guard_saros.he_should_really_23", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "quentin") then
		npcHandler:sayLocalized("npc.guard_saros.i_dont_understand_24", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "bozo") then
		npcHandler:sayLocalized("npc.guard_saros.oh_isnt_he_25", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "oswald") then
		npcHandler:sayLocalized("npc.guard_saros.as_far_as_26", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "rumour") or MsgContains(message, "rumor") or MsgContains(message, "gossip") then
		npcHandler:sayLocalized("npc.guard_saros.i_am_a_27", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "kiss") and Sex == PLAYERSEX_MALE then
		npcHandler:sayLocalized("npc.guard_saros.oh_you_little_28", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 20
	elseif MsgContains(message, "weapon") then
		npcHandler:sayLocalized("npc.guard_saros.i_know_only_29", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "magic") then
		npcHandler:sayLocalized("npc.guard_saros.i_believe_that_30", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "thief") or MsgContains(message, "theft") then
		npcHandler:sayLocalized("npc.guard_saros.oh_sorry_i_31", npc, creature)
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	elseif MsgContains(message, "tibia") then
		npcHandler:sayLocalized("npc.guard_saros.i_would_like_32", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "castle") then
		npcHandler:sayLocalized("npc.guard_saros.i_love_this_33", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "muriel") then
		npcHandler:sayLocalized("npc.guard_saros.powerful_sorcerers_fright_34", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "elane") then
		npcHandler:sayLocalized("npc.guard_saros.i_personally_think_35", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "marvik") then
		npcHandler:sayLocalized("npc.guard_saros.druids_seldom_visit_36", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "gregor") then
		npcHandler:sayLocalized("npc.guard_saros.i_like_brave_37", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "noodles") then
		npcHandler:sayLocalized("npc.guard_saros.oh_he_is_38", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "dog") or MsgContains(message, "poodle") then
		npcHandler:sayLocalized("npc.guard_saros.i_like_dogs_39", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 5
	elseif MsgContains(message, "excalibug") then
		npcHandler:sayLocalized("npc.guard_saros.oh_i_am_40", npc, creature)
		npcHandler:setTopic(playerId, 2)
		price[playerId] = 10
	elseif MsgContains(message, "partos") then
		npcHandler:sayLocalized("npc.guard_saros.i_dont_know_41", npc, creature)
		npcHandler:setTopic(playerId, 4)
		price[playerId] = nil
	elseif MsgContains(message, "yenny") then
		npcHandler:sayLocalized("npc.guard_saros.yenny_i_know_42", npc, creature)
		npcHandler:setTopic(playerId, nil)
		price[playerId] = nil
		npcHandler:removeInteraction(npc, creature)
		npcHandler:resetNpc(creature)
	end
	return true
end

npcHandler:setMessage(MESSAGE_WALKAWAY, "I hope to see you soon.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Good bye, |PLAYERNAME|. I really hope we'll talk again soon.")

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

-- npcType registering the npcConfig table
npcType:register(npcConfig)
